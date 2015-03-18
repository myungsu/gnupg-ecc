﻿#summary AESWRAP HOWTO as it applies to OpenPGP and typical key wrapping
#labels Phase-Deploy,Featured

# Introduction #

Most of the time, as is the case with the [ECC in OpenPGP RFC6637](http://tools.ietf.org/html/rfc6637), AESWRAP is used to wrap an AES key. The maximum size of such a payload is 32 bytes. In OpenPGP case the symmetric key contains 3 additional bytes of metadata. AESWRAP algorithms expects the payload to be multiple of 8 bytes, thus the total size of payload is increased to 40 bytes.

Let's focus on the OpenPGP case. AESWRAP expands the output by 8 bytes; these 8 bytes contain the integrity data. Thus, the input is limited to 40 bytes and the output to 48 bytes. The small payload and output sizes which are capped at 48 bytes allow us to simplify the implementation of the algorithm by avoiding inner loops and we can use fixed-size buffers too.

This description is based on my year 2008 implementation that I placed in public domain. It currently shows up as a second hit if you simply search for [aeswrap](http://www.google.com/search?q=aeswrap&oe=utf-8), the first hit being the [RFC3394](http://tools.ietf.org/html/rfc3394). It must have been useful.

Final note. The following code uses on-the-stack buffers. It's a good idea to move these buffers into a data structure that is dynamically allocated in non-swappable memory.

# Implementation Code #

AESWRAP is built using AES as a building block. The code bellow uses PGP SDK as an API, but any API that implements AES (in ECB mode) will do the job as well.

## Wrap function ##

```

PGPError nist_aes_wrap(
        PGPContextRef c,
        PGPCipherAlgorithm KEK_id,
        const void *kek, unsigned kek_size,
        const void *data, unsigned data_size,
        void *out, int out_size, unsigned *out_actual_size )
{
        const unsigned n = ((data_size + 7)/8 );

        PGPUInt64 A[2];
        PGPUInt64 B[2];
        /* the max for 32 bit key + 1 byte alg ID is 40 bytes */
        PGPUInt64 R[5+1];
        PGPUInt64 t;

        unsigned i, j;

        PGPSymmetricCipherContextRef cipher;
        PGPSize keySize;
        PGPSize blockSize;
        PGPError err;

        *out_actual_size = 0;

        if( n >= sizeof(R)/sizeof(R[0]) )
                return kPGPError_BufferTooSmall;
        if( n==0 )
                return kPGPError_BadParams;

        if( out_size < (n+1) * sizeof(PGPUInt64) )
                return kPGPError_BadParams;

        /* Initialize AES object */
        err = PGPNewSymmetricCipherContext(c, KEK_id, &cipher);
        PGPGetSymmetricCipherSizes( cipher, &keySize, &blockSize );
        if( keySize != kek_size )
                return kPGPError_BadParams;
        if( IsntPGPError(err) )
                err = PGPInitSymmetricCipher( cipher, kek );
        if( IsPGPError(err) ) {
                PGPFreeSymmetricCipherContext( cipher );
                return err;
        }

        // 1) Initialize variables.
        A[0] = 0xA6A6A6A6A6A6A6A6ULL;
        R[n] = 0;
        memcpy( R+1, data, data_size );
                
        // 2) Calculate intermediate values.
        for( j=0; j<6; j++ )  {
                for( i=1; i<=n; i++ )  {

                        //printf("%d,%d in:", j, i);
                        //dump_hex( A, sizeof(A[0]) );
                        //putchar(' ');
                        //dump_hex( R+1, sizeof(R[0])*4 );
                        //putchar('\n');

                        A[1] = R[i];
                        PGPSymmetricCipherEncrypt( cipher, A, B );

                        //printf("%d,%d enc:", j, i);
                        //dump_hex( A, sizeof(A[0]) );
                        //putchar(' ');
                        //dump_hex( B, sizeof(B[0])*2 );
                        //putchar('\n');

#if PGP_WORDSLITTLEENDIAN
                        ((unsigned char *)B)[7] ^= n*j+i;
#else
                        *(unsigned *)B ^= n*j+i;
#endif

                        A[0] = B[0];
                        R[i] = B[1];

                        //printf("%d,%d out:", j, i);
                        //dump_hex( A, sizeof(A[0]) );
                        //putchar(' ');
                        //dump_hex( R+1, sizeof(R[0])*2 );
                        //putchar('\n');
                }
        }

        // 3) Output the results.
        memcpy( out, &A, sizeof(A) );
        memcpy( (char*)out + sizeof(PGPUInt64), R+1, n*sizeof(R[0]) );

        /* Clear internal buffers */
        memset( A, 0, sizeof(A) );
        memset( B, 0, sizeof(B) );
        memset( R, 0, sizeof(R) );

        PGPFreeSymmetricCipherContext( cipher );

        *out_actual_size = (n+1)*sizeof(PGPUInt64);

        return kPGPError_NoErr;
}

```

## Unwrap function ##

```

PGPError nist_aes_unwrap(
        PGPContextRef c,
        PGPCipherAlgorithm KEK_id,
        const void *kek, unsigned kek_size,
        const void *data, unsigned data_size,
        void *out, int out_size, unsigned *out_actual_size )
{
        unsigned n = data_size / sizeof(PGPUInt64);

        PGPUInt64 A[2];
        PGPUInt64 B[2];
        /* the max for 32 bit key + 1 byte alg ID is 40 bytes */
        PGPUInt64 R[5+1];

        unsigned i, j;

        PGPSymmetricCipherContextRef cipher;
        PGPSize keySize;
        PGPSize blockSize;
        PGPError err;

        *out_actual_size = 0;
        
        if( data_size % sizeof(PGPUInt64) != 0 )
                return kPGPError_BadParams;
        
        if( n < 2 )
                return kPGPError_CorruptData;

        if( n > sizeof(R)/sizeof(R[0]) )
                return kPGPError_BufferTooSmall;

        n --;

        /* Initialize AES object */
        err = PGPNewSymmetricCipherContext(c, KEK_id, &cipher);
        PGPGetSymmetricCipherSizes( cipher, &keySize, &blockSize );
        if( keySize != kek_size )
                return kPGPError_BadParams;
        if( IsntPGPError(err) )
                err = PGPInitSymmetricCipher( cipher, kek );
        if( IsPGPError(err) ) {
                PGPFreeSymmetricCipherContext( cipher );
                return err;
        }

        // 1) Initialize variables.
        memcpy( A, data, sizeof(A[0]) );
        memcpy( R+1, (const PGPByte *)data+sizeof(PGPUInt64), data_size - sizeof(PGPUInt64) );

        // 2) Compute intermediate values.
        for( j = 6; j>0; j-- )  {
                for( i=n; i>0; i-- )  {
                        //printf("%d,%d in:", j, i);
                        //dump_hex( A, sizeof(A[0]) );
                        //putchar(' ');
                        //dump_hex( R+1, sizeof(R[0])*2 );
                        //putchar('\n');
                        
#if PGP_WORDSLITTLEENDIAN
                        ((unsigned char *)A)[7] ^= ((n*(j-1))+i);
#else
                        *(unsigned *)A ^= ((n*(j-1))+i);
#endif

                        A[1] = R[i];

                        //printf("%d,%d xor:", j, i);
                        //dump_hex( A, sizeof(A[0]) );
                        //putchar(' ');
                        //dump_hex( R+1, sizeof(R[0])*2 );
                        //putchar('\n');

                        PGPSymmetricCipherDecrypt( cipher, A, B );

                        A[0] = B[0];
                        R[i] = B[1];

                        //printf("%d,%d dec:", j, i);
                        //dump_hex( A, sizeof(A[0]) );
                        //putchar(' ');
                        //dump_hex( R+1, sizeof(R[0])*2 );
                        //putchar('\n');
                }
        }
        
        /* Clear internal buffers */
        memset( B, 0, sizeof(B) );

        PGPFreeSymmetricCipherContext( cipher );

        // 3) Output results.
        if( A[0] == 0xA6A6A6A6A6A6A6A6ULL )  {
                *out_actual_size = n*sizeof(PGPUInt64);
                memcpy( out, R+1, n*sizeof(PGPUInt64) );
                /* Clear internal buffers */
                A[1] = 0;
                memset( R, 0, sizeof(R) );
                return kPGPError_NoErr;
        }
        else  {
                /* Clear internal buffers */
                memset( A, 0, sizeof(A) );
                memset( R, 0, sizeof(R) );
                return kPGPError_CorruptData;
        }
}

```

# Testing Code #


```

void dump_hex( const void *p, unsigned  n )  {
        unsigned i;
        const unsigned char *pp = (unsigned char *)p;

        printf("[%d] ", n);
        for( i=0; i<n; i++ )  {
                printf("%02x", *pp);
                pp++;
                if( (i%8) == 7 )
                        putchar( ' ' );
        }
}

int main( int argc, char *argv[] )  {
        PGPContextRef   context                 = NULL;
        PGPError                err     = kPGPError_NoErr;

        err = PGPsdkInit( kPGPFlags_ForceLocalExecution | kPGPFlags_SuppressCacheThread );
        if ( IsPGPError( err ) )
        {
                printf ("Initialization error: %d\n", err );
                return -1;
        }

        err = PGPNewContext( kPGPsdkAPIVersion, &context );
        if ( IsPGPError( err ) )  {
                printf ("Error acquiring SDK context: %d\n", err );
                (void)PGPsdkCleanup( );
                return -1;
        }

        
        {       // 128 KEK, 128 data
                unsigned char out[24];
                unsigned l;
                nist_aes_wrap( context, kPGPCipherAlgorithm_AES128,
                        "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F", 16,
                        "\x00\x11\x22\x33\x44\x55\x66\x77\x88\x99\xAA\xBB\xCC\xDD\xEE\xFF", 16,
                        out, sizeof(out), &l );
                if( l > 16 && memcmp( out, "\x1F\xA6\x8B\x0A\x81\x12\xB4\x47" "\xAE\xF3\x4B\xD8\xFB\x5A\x7B\x82" "\x9D\x3E\x86\x23\x71\xD2\xCF\xE5", l )==0 )
                        printf("AESWrap Match #1, l=%d\n", l);
                else  {
                        printf("AESWrap Failed #1\n");
                        dump_hex( out, l );
                }

                nist_aes_unwrap( context, kPGPCipherAlgorithm_AES128,
                        "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F", 16,
                        "\x1F\xA6\x8B\x0A\x81\x12\xB4\x47" "\xAE\xF3\x4B\xD8\xFB\x5A\x7B\x82" "\x9D\x3E\x86\x23\x71\xD2\xCF\xE5", 24,
                        out, sizeof(out), &l );
                if( l == 16 && memcmp( out, "\x00\x11\x22\x33\x44\x55\x66\x77\x88\x99\xAA\xBB\xCC\xDD\xEE\xFF", 16 )==0 )  {
                        printf("AESUNWrap Match #1, l=%d\n", l);
                }
                else  {
                        printf("AESUNWrap Failed #1\n");
                }
        }

        {       // 256 KEK, 128 data
                unsigned char out[24];
                unsigned l;
                nist_aes_wrap( context, kPGPCipherAlgorithm_AES256,
                        "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F", 32,
                        "\x00\x11\x22\x33\x44\x55\x66\x77\x88\x99\xAA\xBB\xCC\xDD\xEE\xFF", 16,
                        out, sizeof(out), &l );
                if( l > 16 && memcmp( out, "\x64\xE8\xC3\xF9\xCE\x0F\x5B\xA2" "\x63\xE9\x77\x79\x05\x81\x8A\x2A" "\x93\xC8\x19\x1E\x7D\x6E\x8A\xE7", l )==0 )
                        printf("AESWrap Match #2, l=%d\n", l);
                else  {
                        printf("AESWrap Failed #2\n");
                        dump_hex( out, l );
                }

                nist_aes_unwrap( context, kPGPCipherAlgorithm_AES256,
                        "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F", 32,
                        "\x64\xE8\xC3\xF9\xCE\x0F\x5B\xA2" "\x63\xE9\x77\x79\x05\x81\x8A\x2A" "\x93\xC8\x19\x1E\x7D\x6E\x8A\xE7", 24,
                        out, sizeof(out), &l );
                if( l == 16 && memcmp( out, "\x00\x11\x22\x33\x44\x55\x66\x77\x88\x99\xAA\xBB\xCC\xDD\xEE\xFF", 16 )==0 )  {
                        printf("AESUNWrap Match #2, l=%d\n", l);
                }
                else  {
                        printf("AESUNWrap Failed #2\n");
                }
        }

        {       // 256 KEK, 256 data
                unsigned char out[40];
                unsigned l;
                err = nist_aes_wrap( context, kPGPCipherAlgorithm_AES256,
                        "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F", 32,
                        "\x00\x11\x22\x33\x44\x55\x66\x77\x88\x99\xAA\xBB\xCC\xDD\xEE\xFF\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F", 32,
                        out, sizeof(out), &l );
                if( l > 32 && memcmp( out,
                        "\x28\xC9\xF4\x04\xC4\xB8\x10\xF4" "\xCB\xCC\xB3\x5C\xFB\x87\xF8\x26" "\x3F\x57\x86\xE2\xD8\x0E\xD3\x26" 
                        "\xCB\xC7\xF0\xE7\x1A\x99\xF4\x3B" "\xFB\x98\x8B\x9B\x7A\x02\xDD\x21", 40 )==0 )
                {
                        printf("AESWrap Match #3, l=%d\n", l);
                }
                else  {
                        printf("AESWrap Failed #3, l=%d, err=%d \n", l, err);
                        dump_hex( out, l );
                }

                nist_aes_unwrap( context, kPGPCipherAlgorithm_AES256,
                        "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F", 32,
                        "\x28\xC9\xF4\x04\xC4\xB8\x10\xF4" "\xCB\xCC\xB3\x5C\xFB\x87\xF8\x26" "\x3F\x57\x86\xE2\xD8\x0E\xD3\x26" 
                        "\xCB\xC7\xF0\xE7\x1A\x99\xF4\x3B" "\xFB\x98\x8B\x9B\x7A\x02\xDD\x21", 40,
                        out, sizeof(out), &l );
                if( l == 32 && memcmp( out,
                        "\x00\x11\x22\x33\x44\x55\x66\x77\x88\x99\xAA\xBB\xCC\xDD\xEE\xFF\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F", 32 
                        )==0 )  
                {
                        printf("AESUNWrap Match #3, l=%d\n", l);
                }
                else  {
                        printf("AESUNWrap Failed #3, l=%d, err=%d \n", l, err);
                }
        }
                
        PGPFreeContext( context );
        PGPsdkCleanup();

        return err;
}

```