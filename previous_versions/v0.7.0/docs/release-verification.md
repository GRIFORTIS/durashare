# Release Verification

This document explains what the release signatures and checksums do, what they do not do, and how to verify a published Schiavinato Sharing release.

## What is signed

For a tagged release, the trust anchors are:
- The signed git tag, which authenticates the repository state.
- Detached GPG signatures for release files:
  - `WHITEPAPER.pdf.asc`
  - `WHITEPAPER-vX.Y.Z.pdf.asc`
  - `CHECKSUMS.txt.asc`

The corresponding files are:
- `WHITEPAPER.pdf`
- `WHITEPAPER-vX.Y.Z.pdf`
- `CHECKSUMS.txt`

## What each layer proves

### Signed git tag
The signed tag proves:
- which exact repository commit was released
- that the tagged release state was approved by the maintainer signing identity

It does **not** prove:
- that a downloaded standalone file is authentic by itself
- that the contents are bug-free or secure

### Detached GPG signatures
The `.asc` files prove:
- the specific downloaded file was signed by the maintainer's GPG key
- the file has not changed since it was signed

They do **not** prove:
- the file contents are correct
- the protocol is safe or audited

### Checksums
`CHECKSUMS.txt` proves:
- a local file matches the expected published hash

It does **not** prove:
- who created the file
- whether the file is authentic, unless you also verify `CHECKSUMS.txt.asc`

## Recommended verification order

1. Verify the signed git tag.
2. Verify `CHECKSUMS.txt.asc` against `CHECKSUMS.txt`.
3. Verify the detached signature for the exact file you downloaded.
4. Verify the file hash against `CHECKSUMS.txt`.

## Verify the signed tag

After fetching tags:

```bash
git fetch --tags
git tag -v v0.7.0
```

## Verify the checksum file signature

```bash
gpg --verify CHECKSUMS.txt.asc CHECKSUMS.txt
```

## Verify the whitepaper signature

```bash
gpg --verify WHITEPAPER-v0.7.0.pdf.asc WHITEPAPER-v0.7.0.pdf
```

Or for the stable filename:

```bash
gpg --verify WHITEPAPER.pdf.asc WHITEPAPER.pdf
```

## Verify the file hashes

```bash
sha256sum -c CHECKSUMS.txt
```

## Public key

The public key currently published with this repository is:
- Fingerprint: `7921 FD56 9450 8DA4 020E 671F 4CFE 6248 C57F 15DF`
- UID: `GRIFORTIS <security@grifortis.com>`

## Practical interpretation

If all checks pass, you can conclude:
- the release tag is authentic
- the published files were signed by the expected GPG key
- the files you downloaded match the published hashes

You still cannot conclude:
- the protocol is audited
- the whitepaper is free of mistakes
- the implementation or specification is safe for real funds
