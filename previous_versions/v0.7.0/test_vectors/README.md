# Test vectors

> **This is the frozen test-vectors tree for v0.7.0.** It is preserved for reference only. The live test-vectors workspace is in [`../../../test_vectors/README.md`](../../../test_vectors/README.md).

This directory contains the canonical test vectors for Schiavinato Sharing.

## Goals
- Provide stable, version-scoped references for protocol semantics.
- Support future cross-implementation conformance testing as the HTML / JS / Python implementations catch up to the current specification.

## Layout
- `schema.json`: JSON schema for the machine-readable vectors format.
- Live current-protocol vectors live directly in `test_vectors/` at the repository root:
  - `test_vectors/vectors.json`: machine-readable live vectors for the current protocol
  - `test_vectors/vectors.md`: human-readable live companion for the current protocol
- Released historical vectors live under [`../../`](../../README.md), inside each archived version's `test_vectors/` subtree:
  - `vectors.json`: machine-readable vectors
  - `vectors.md`: optional human-readable companion

## Notes
- The live `test_vectors/` pair tracks the current protocol, and its internal `version` field identifies the targeted spec version.
- Once a version is released, its vectors MUST be copied into `previous_versions/vX.Y.Z/test_vectors/` and treated as immutable there.
- Implementations are currently work in progress and may lag the current vectors. To claim compatibility with a vectors version, an implementation MUST declare which `manual_spec` and `software_spec` versions it supports and validate against the matching vectors before release.
- Archived releases currently available:
  - Partial vectors-only snapshot: [`../../v0.4.0/`](../../v0.4.0/README.md)
  - Full archived snapshot: [`../../v0.4.1/`](../../v0.4.1/README.md)
  - Vectors-only snapshot: [`../../v0.5.0/`](../../v0.5.0/README.md)
  - Paper-only snapshot: [`../../v0.6.0/`](../../v0.6.0/README.md)
- Security policy (private disclosures): https://github.com/GRIFORTIS/.github/blob/main/SECURITY.md
- Some human-readable companion docs inside version folders may reference `SECURITY.md`; treat that as a reference to the org-wide security policy link above.

## Quick test mnemonics (FOR TESTING ONLY)

⚠️ **FOR TESTING ONLY** — these are public example mnemonics for running tests and demos. **NEVER** use them for real funds.

### 12 words

```
spin result brand ahead poet carpet unusual chronic denial festival toy autumn
```

### 24 words

```
abandon zoo enhance young join maximum fancy call minimum code spider olive alcohol system also share birth profit horn bargain beauty media rapid tattoo
```

## Conformance requirements

For any implementation to claim compatibility with the current protocol vectors, it MUST:

- **Declare support**: document which `manual_spec` and `software_spec` versions are supported, and which vectors `version` field is used for conformance.
- **Validate in CI**: run vector-based conformance tests in CI (or equivalent automation) before publishing a release.
- **Archive releases immutably**: once a vectors set is released, snapshot it under `previous_versions/vX.Y.Z/test_vectors/` rather than continuing to evolve that archived copy.

## Current v0.7.0 coverage

The live root vectors currently cover:

- 12-word BIP39, 2-of-3 arithmetic over `GF(2053)`
- production column tags `100, 200, 300`
- Full and Compact Payload bytes
- RBT derivation
- Transport Hash
- Manifest Audit Hash
- Lagrange recovery
- deterministic dual-MAT sample for one Share

Additional conformance vectors should be added for 24-word 3-of-5, DRK coefficient derivation, and nested sharing before implementation claims move beyond this coverage.

