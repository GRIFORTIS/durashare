# manual_spec changelog

All notable changes to `manual_spec` will be documented here.

## [Unreleased]

## [0.7.0] - 2026-07-23

### Added
- Share Audit ceremony guidance for validating one stored Share without combining a threshold set.
- Manual Authentication Layer (MAT) semantics, including Single MAT and Dual MAT, Whole-Key and Split-Key Manifest custody, and manual verification flow.
- BIP39 wordlist language handling and Pre-Encrypted Numeric Input guidance for manual artifacts.

### Changed
- Manual specification is now recovery-first, with Share Audit and Recovery before Manual Sharing.
- Production column tags now use `100, 200, 300`, with updated row/column/GIC totals and validation examples.
- Manual artifact terminology now uses Share and Manifest consistently and aligns with the v0.7.0 Full / Compact Output Profile model.

## [0.6.0] - 2026-05-10

### Changed
- Manual specification header now targets v0.6.0.
- Manual coefficient generation now samples each Shamir coefficient independently from the full field range `0..2052`; the highest-power coefficient is no longer forced to be nonzero.
- Optional manifest guidance now documents sensitivity and leakage from aggregating at least `k` printed GIC values from one session.
- No manual share-table format change from v0.5.0; v0.6.0 manual behavior keeps position-bound row checksums, column checksums, row/column-total GIC, nested sharing, and RVA guidance.

## [0.5.0] - 2026-04-09

### Added
- **Column checksums** with position-bound column tags (\(\tau^C_1 = 10\), \(\tau^C_2 = 20\), \(\tau^C_3 = 30\)).
- **Row tags** (\(\tau^R_j = j\)) added to row checksum formulas for positional binding.
- **Row total** \(T_R = r(r+1)/2\) and **column total** \(T_C = 60\) added to GIC formula.
- **Three equivalent GIC validation paths** (words, rows, columns).
- **Recovery Verification Address (RVA)** as recommended share header field.
- Explicit \(n \leq 2052\) constraint.
- Redundant-share consistency check observation (\(k+1\) shares).
- Nesting section.
- Domain separators table (\(T_R\), \(T_C\) by word count).

### Changed
- Row checksum formula: \(R_j[x] = (w_{3j-2}[x] + w_{3j-1}[x] + w_{3j}[x] + j) \bmod 2053\) (was without \(+j\)).
- GIC formula: now includes \(T_R + T_C\) in addition to word sum and share index.
- Share table layout: footer row now contains 3 column checksums + printed GIC (was GIC only).
- Share assembly: \(\ell + r + 3 + 1\) elements per share (was \(\ell + r + 1\)).
- STOP conditions: column checksum mismatch added.
- Recovery Step 4: column checksum interpolation and validation added.
- Share generation: column checksum computation added as Step 3.

### Breaking
- Row checksum values differ from v0.4.x due to row tag addition.
- GIC values differ from v0.4.x due to \(T_R + T_C\) addition.
- Share table format changes (column checksums in footer row).
- Existing v0.4.x shares are **not** compatible with v0.5.0 recovery.

## [0.4.1] - 2026-02-03
- Initial published draft (row checksums, GIC with share-index binding, no column checksums, no row/column tags).
