#summary libgcrypt interface
#labels Phase-Deploy,Featured

# Introduction #

This document gives an overview of the interface between libgcrypt and gnupg. libgcrypt and gnupg are distributed as separate binary modules by UNIX distributors, for example, these are RPMs in Fedora Core (with names like libgcrypt-1.4.5-4.fc13.x86\_64 and gnupg2-2.0.14-7.fc13.x86\_64). Thus, there is desire to maintain stable binary interface between the libgcrypt and gnupg. libgcrypt was separated from the gnupg in the 2.0 release.

ECC is known for its greater complexity of configuration parameters. It takes more data fields to fully define the ECC field than needed to define traditional modp field. For example, the following parameters are implicitly known (don't exist or trivial) for the traditional cryptography:
  * type of curve
  * definition of the curve
  * field generator
  * field order
  * field element representation

This implementation's primary goal is to hide this complexity, in other words, to match the simplicity set forth by the [ECC in OpenPGP](http://sites.google.com/site/brainhub/pgp). What came out as a result of this effort is the libgcrypt interface that can compete with the RSA key operations in its simplicity, yet it doesn't deny extensibility.

## Field encoding ##

Every field in the interface between gnupg and libgcyrpt is encoded as an MPI, except for small integers. For example, a sequence of bytes to be encrypted with a public key is passed as an MPI. This project continues to use MPIs to pass around any sequence of octets, even though in many cases the data passed inside of MPIs are not strictly large integers, or in different words, will not be used as large integers in arithmetic operations.

## size+body field encoding ##

OpenPGP ECC draft makes extensive use of the following method to encode a sequence of octets. When N octets that are not MPIs are written into any stream, they are written as N+1 octets with the first octet having the value N. For example, the OID sequence `2B 81 04 00 22`, representing ASN.1 value of the curve P-384, is encoded as

| Data:          |            | ` 2B 81 04 00 22` |
|:---------------|:-----------|:------------------|
| Encoded value: | **`05`** | ` 2B 81 04 00 22` |

The same representation is used internally in this project. In some cases this representation is further encoded into an MPI for the sake of uniformity of interface. For the most part libgcrypt is not aware of this representation (only gnupg layer is), except when it needs to determine the ECC curve OID. To put it differently, MPI is the internal format of the data container in this project.

## ECC public key definitions ##

The first parameter of the ECC public key (ECDSA or ECDH) defines the curve by its ASN.1 OID, the approach favoured at the OpenPGP mailing list. The second parameter is the field element.

Note the following 4 structures are very similar to each other and even to traditional cryptographic algorithms. For example, it helps that the private key is just a single MPI, similar to the private exponent of an RSA key.

The definitions are summarised in the following table, each explained in details later.

| **Key type** | **Fields** |
|:-------------|:-----------|
| ECDSA public | "cq" |
| ECDSA private | "cqd" |
| ECDH public | "cqp" |
| ECDH private | "cqpd" |


### ECC public key header ###

This is the common portion for both ECDSA and ECDH keys, defined as follows:

| **Field index** | **Field name** | **Description** |
|:----------------|:---------------|:----------------|
| 0 | c | ECC curve OID |
| 1 | q | ECC curve point |

#### ECDSA public key ####

Identical to the ECC public key header (2 fields)

#### ECDH public key ####

| **Field index** | **Field name** | **Description** |
|:----------------|:---------------|:----------------|
| _ECC public key header, 2 fields_ |
| 2 | p | KEK parameters, currently 4 bytes |

### ECC private keys ###

| **Field index** | **Field name** | **Description** |
|:----------------|:---------------|:----------------|
| _ECDSA/ECDH public key portion, 2/3 fields_ |
| 2/3 | d | ECC private scalar |

For instance, the exact definition of the ECDH key is :

| **Field index** | **Field name** | **Description** |
|:----------------|:---------------|:----------------|
| 0 | c | ECC curve OID |
| 1 | q | ECC curve point |
| 2 | p | KEK parameters, currently 4 bytes |
| 3 | d | ECC private scalar |

## ECC public key operations ##

### ECDSA signature and verification ###

Same as with DSA signature and verification.

### ECDH encryption ###

The separation of the gnupg and libgcrypt in version 2.0 introduces additional complexity for ECC encryption implementation. ECC encryption is not as straightforward as RSA encryption and there is less universal agreement on exactly what the encryption method should be.

Fortunately, there is a good solution that this project employs. These issues are solved by moving encryption to the gnupg layer, while exposing only standard ECDH operation operation at the libgcrypt layer. This design assures the stability of libgcrypt binary interface layer.

Input to encryption operation:

| **Field name** | **Description** |
|:---------------|:----------------|
| data | ECC scalar |
| _ECDH public key portion, 3 fields_  |

Output from the encryption operation:

| result 0 | `ECC curve point = data * q` |
|:---------|:-----------------------------|
| result 1 | always set to 0 |

The ECDH encryption is used with the long-term ECDH public key as well as with ephemeral public keys. Because of the symmetry of DH operations, the decryption routine of libgcrypt is not called by gnupg layer.

## ECC key generation parameters ##

### ECDSA and ECDH key generation ###

| **Field name** | **Possible values** | **Description** |
|:---------------|:--------------------|:----------------|
| qbits | 256, 384, 521 | Curve size in bits |
| nbits | 256, 384, 521| always equals to qbits |


The qbits determines which default curve will be used. The choice of the curve will be made according to the [ECC in OpenPGP](http://sites.google.com/site/brainhub/pgp).

### Additional parameters for ECDH key generation ###

| **Field name** | **Possible values** | **Description** |
|:---------------|:--------------------|:----------------|
| ephemeral | 0 - a key needed for each encrypted message, 1 - long-term key | mostly a performance-optimization parameter |
| kek-params | 4 octets | KEK parameters |