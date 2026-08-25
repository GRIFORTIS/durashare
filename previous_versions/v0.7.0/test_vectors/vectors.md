# Schiavinato Sharing - v0.7.0 Test Vectors

These public vectors are for interoperability testing only. Never use the mnemonic, coefficients, Session Batch IDs, MAT keys, DRKs, or derived values for real funds.

Machine-readable data lives in [`vectors.json`](vectors.json).

## Status

- Version: `v0.7.0`
- Main fixture: `2-of-3`, 12-word BIP39 mnemonic
- Profiles covered: Full and Compact
- Audit features covered: RBT, Transport Hash, Manifest Audit Hash, dual MAT sample
- Removed from active vectors: Reduced Mode, BI/MKI, `SCHI` prefix, 11-bit share packing

## Mnemonic

```text
spin result brand ahead poet carpet unusual chronic denial festival toy autumn
```

1-based BIP39 indices:

```text
1680, 1471, 217, 42, 1338, 279, 1907, 324, 468, 682, 1844, 126
```

## Shamir Coefficients

Threshold: `2-of-3`

Share indices: `1, 2, 3`

Degree-1 coefficients:

```text
1, 2052, 1126, 2012, 710, 571, 146, 1728, 2000, 130, 122, 383
```

## Base Arithmetic Values

Row checksums:

```text
1316, 1661, 649, 603
```

Column tags:

```text
100, 200, 300
```

Column checksums:

```text
305, 1071, 1390
```

Base GIC:

```text
723
```

## RBT

Canonical secret material:

```text
016905BF0D902A53A1177731441D42AA73407E
```

Full Session Batch ID:

```text
A1B2C3D4E5F60708
```

Full RBT:

```text
3DE50771B03A018838A0D18E
```

Compact Session Batch ID:

```text
0A1B2C3D
```

Compact RBT:

```text
D9A9E72E3568
```

RBT derivation uses PBKDF2-HMAC-SHA512 with 16,384 iterations.

## Share 1

Word values:

```text
1681, 1470, 1343, 1, 2048, 850, 0, 2052, 415, 812, 1966, 509
```

Row checksums:

```text
389, 848, 417, 1238
```

Column checksums:

```text
541, 1577, 1364
```

Printed GIC:

```text
1440
```

Full Payload:

```text
534601280102000100A1B2C3D4E5F607083DE50771B03A018838A0D18E6915BE53F00180035200080419F32C7AE1FD1853501A14D621D6295545A0A9815442E1C5ED59F685D71611C15CAC
```

Full Transport Hash:

```text
A9815442E1C5ED59F685D71611C15CAC
```

Full Manifest Audit Hash:

```text
698D7209F3E5521C0EB054E8B44B0AE9252E8FE38F32C41BD48F6DF5A658F917
```

Compact Payload:

```text
534301280102010A1B2C3DD9A9E72E35686915BE53F00180035200080419F32C7AE1FD
```

Compact Manifest Audit Hash:

```text
AEFBB13028461385620DF5D0BA941589BB7ED402F8C76DDF9B957A6AFA51AD3A
```

## Share 2

Word values:

```text
1682, 1469, 416, 2013, 705, 1421, 146, 1727, 362, 942, 35, 892
```

Row checksums:

```text
1515, 35, 185, 1873
```

Column checksums:

```text
777, 30, 1338
```

Printed GIC:

```text
104
```

Full Payload:

```text
534601280102000200A1B2C3D4E5F607083DE50771B03A018838A0D18E6925BD1A07DD2C158D0926BF16A3AE02337C5EB0230B975130901E53A0683B3E1825BBBFE4EB122AD74D405CA3F8
```

Full Manifest Audit Hash:

```text
A2F949C72E7C0681A3B44715016026B0428450A1C00544A4555A234D56F89ADB
```

Compact Payload:

```text
534301280102020A1B2C3DD9A9E72E35686925BD1A07DD2C158D0926BF16A3AE02337C
```

Compact Manifest Audit Hash:

```text
908AD30DDBF9E6CA196BC4F01A683D4970EEC2823BBF155CD6B059249DC77F57
```

## Share 3

Word values:

```text
1683, 1468, 1542, 1972, 1415, 1992, 292, 1402, 309, 1072, 157, 1275
```

Row checksums:

```text
588, 1275, 2006, 455
```

Column checksums:

```text
1013, 536, 1312
```

Printed GIC:

```text
821
```

Full Payload:

```text
534601280102000300A1B2C3D4E5F607083DE50771B03A018838A0D18E6935BC6067B45877C812457A13543009D4FB24C4FB7D61C73F5218520335BB20C37BBA6BE2C7E75FED4BB2E901E7
```

Full Manifest Audit Hash:

```text
3F8E8F27537DC85D91B371F6289382F890E5AF43D3E11A1335F69F8A5D701FE1
```

Compact Payload:

```text
534301280102030A1B2C3DD9A9E72E35686935BC6067B45877C812457A13543009D4FB
```

Compact Manifest Audit Hash:

```text
3491EEBC80B78401CFEA7B40505BFE578B9D41D183FB2164AE8A35E18D0AAE2C
```

## Recovery Check

Using Shares `{1, 2}`:

```text
gamma = (2, 2052)
```

Lagrange sanity:

```text
2*1 + 2052*2 = 0 mod 2053
```

Recovered word indices:

```text
1680, 1471, 217, 42, 1338, 279, 1907, 324, 468, 682, 1844, 126
```

Recovered row checksums:

```text
1316, 1661, 649, 603
```

Recovered column checksums:

```text
305, 1071, 1390
```

Recovered base GIC:

```text
723
```

## MAT Sample

The MAT sample uses Share 1.

Row values:

```text
[1681, 1470, 1343]
[1, 2048, 850]
[0, 2052, 415]
[812, 1966, 509]
```

MAT column 1:

```text
weights = 2, 4, 7
row pads = 6, 8, 10, 12
tags = 172, 1834, 858, 745
```

MAT column 2:

```text
weights = 11, 13, 17
row pads = 19, 23, 29, 31
tags = 914, 48, 912, 61
```
