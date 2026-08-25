# Schiavinato Sharing - Manual Specification (`manual_spec`)

[Jump to Share Audit](#share-audit) | [Jump to Manual Recovery](#manual-recovery) | [Jump to Manual Sharing](#manual-sharing)

> ## WARNING: EXPERIMENTAL SOFTWARE
>
> DO NOT USE IT FOR REAL FUNDS.
>
> Schiavinato Sharing specifications and prototype implementations have not been audited. Use for testing, learning, and review only. See the organization security policy for private disclosures.

This document defines the manual execution protocol for Schiavinato Sharing v0.7.0. It is recovery-first: recovery and audit are the continuity-critical procedures, while fully manual sharing is a fallback for cases where software cannot be trusted or used.

Normative keywords **MUST**, **MUST NOT**, **SHOULD**, **MAY** are used as requirements.

## Scope

This spec covers:

- field arithmetic over `GF(2053)`;
- human-readable Share and Manifest semantics;
- Share Audit without combining Shares;
- manual recovery from a valid threshold set;
- optional MAT generation and verification;
- fully manual share generation;
- STOP / WARN / INFO failure semantics.

Digital-envelope byte layouts, QR encodings, text exports, and software decode pipelines belong in `software_spec/`. The whitepaper is the protocol analysis and security reference.

## Non-Negotiable Constraints

- Field operations are modulo `2053`.
- BIP39 input and recovered output use 1-based word indices: `abandon = 1`, `zoo = 2048`.
- Supported BIP39 word counts are `12, 15, 18, 21, 24`.
- Threshold `(k, n)` satisfies `2 <= k <= n <= 2052`, except the degenerate replication case `k = 1`.
- Share indices `x` are distinct nonzero field elements.
- Shamir coefficients are sampled independently and uniformly from `0..2052`; no coefficient has a "must be nonzero" exception.
- The BIP39 passphrase ("25th word") is external. It is never encoded in Shares and must be backed up separately.
- Intermediate Share values may be `0, 2049, 2050, 2051, 2052`. These are valid `GF(2053)` field elements, not BIP39 words.
- In BIP39 mode, the selected BIP39 wordlist language MUST be printed prominently on each Share and Manifest.

## Human-Readable Representation

### Index-First Rule

The canonical written value is the decimal field element. A word label MAY be appended for readability.

Examples:

- In range: `0699-firm` or `699`
- Out of range: `0000-0000`, `2049-2049`, `2050-2050`, `2051-2051`, `2052-2052`

Out-of-range values SHOULD be visually labeled or explained as numeric `GF(2053)` field elements, not missing BIP39 words.

When parsing a written value, the leading decimal integer is authoritative; suffixes are annotations.

### Share Header

Each Share MUST identify:

- protocol name and version;
- threshold `k`;
- Share index `x`;
- original word count;
- BIP39 wordlist language in BIP39 mode;
- MAT selection: none, single, or dual.

Each Share SHOULD also include:

- backup label and creation date;
- passphrase presence/hint, without the passphrase itself;
- wallet or derivation hint;
- RVA, if used;
- layer path for nested sharing, if applicable.

These fields are recovery metadata. They are not part of the Shamir arithmetic.

### Share Table Layout

Let `r = word_count / 3`.

Without MAT, the human-readable Share table has 4 columns:

- three word-share values;
- one row checksum.

The footer row contains:

- three column checksums;
- printed GIC.

With single MAT, the table has one additional MAT column. With dual MAT, it has two additional MAT columns. MAT applies only to word rows; footer cells under MAT columns are marked not applicable.

MAT values are not interpolated and are not part of the arithmetic Share.

## Constants and Notation

### Layout

- Word values: `w_1, ..., w_l`
- Row count: `r = l / 3`
- Row `j` contains `w_{3j-2}, w_{3j-1}, w_{3j}`
- Column `c` is one of `1, 2, 3`

### Domain Separators

- Row tags: `tauR_j = j`
- Column tags: `tauC_1 = 100`, `tauC_2 = 200`, `tauC_3 = 300`
- Row total: `T_R = r(r+1)/2`
- Column total: `T_C = 100 + 200 + 300 = 600`

| Word count | Rows `r` | `T_R` | `T_C` |
|---:|---:|---:|---:|
| 12 | 4 | 10 | 600 |
| 15 | 5 | 15 | 600 |
| 18 | 6 | 21 | 600 |
| 21 | 7 | 28 | 600 |
| 24 | 8 | 36 | 600 |

### Share-State Notation

- `A[x]`: value `A` as printed on Share `x`
- `A`: recovered value at `x = 0`

## Failure Semantics

- **STOP**: do not proceed until the problem is corrected.
- **WARN**: strong warning; proceed only with explicit acknowledgement.
- **INFO**: informational only.

Minimum STOP conditions:

- duplicate Share indices in a recovery set;
- any Share index `x = 0`;
- row checksum mismatch;
- column checksum mismatch;
- printed GIC mismatch;
- Lagrange sanity-check failure;
- recovered final BIP39 index outside `1..2048`;
- MAT mismatch for a required MAT column;
- Manifest Audit Hash mismatch, when that check is being performed;
- unresolved mismatch between paper reading and digital payload.

## Lagrange Coefficients

Lagrange coefficients depend only on public Share indices and contain no secret information. They may be computed on any device, including an untrusted one, or copied from a verified table.

| Scheme | Shares | Coefficients `gamma` |
|---|---|---|
| 2-of-3 | `{1,2}` | `(2, 2052)` |
|  | `{1,3}` | `(1028, 1026)` |
|  | `{2,3}` | `(3, 2051)` |
| 2-of-4 | `{1,2}` | `(2, 2052)` |
|  | `{1,3}` | `(1028, 1026)` |
|  | `{1,4}` | `(1370, 684)` |
|  | `{2,3}` | `(3, 2051)` |
|  | `{2,4}` | `(2, 2052)` |
|  | `{3,4}` | `(4, 2050)` |
| 3-of-5 | `{1,2,3}` | `(3, 2050, 1)` |
|  | `{1,2,4}` | `(687, 2051, 1369)` |
|  | `{1,2,5}` | `(1029, 1367, 1711)` |
|  | `{1,3,4}` | `(2, 2051, 1)` |
|  | `{1,3,5}` | `(1285, 512, 257)` |
|  | `{1,4,5}` | `(686, 1367, 1)` |
|  | `{2,3,4}` | `(6, 2045, 3)` |
|  | `{2,3,5}` | `(5, 2048, 1)` |
|  | `{2,4,5}` | `(1372, 2048, 687)` |
|  | `{3,4,5}` | `(10, 2038, 6)` |

For any recovery set `{x_1, ..., x_k}`, the coefficient for Share `x_j` is:

```text
gamma_j = product over i != j of x_i / (x_i - x_j) mod 2053
```

Validate the coefficients before recovery:

```text
sum(gamma_j * x_j) mod 2053 = 0
```

Failure is STOP.

## Share Audit

Share Audit validates exactly one physical Share before recovery. It does not combine Shares and does not recover the mnemonic.

Inputs may include:

- one physical Share;
- its matching Manifest entry;
- Whole-Key MAT material, or both Split-Key Manifest halves;
- digital payload / Audit QR when available.

Procedure:

1. Confirm protocol version, word count, Share index, threshold, BIP39 language, layer path, and MAT selection.
2. Capture one fixed reading of the physical Share.
3. Validate every row checksum.
4. Validate every column checksum.
5. Validate the printed GIC.
6. If MAT is selected, reconstruct MAT keys privately when needed and verify every required MAT tag.
7. If a digital payload and Manifest Audit Hash are available, validate the payload against the fixed paper reading and compare the hash.

Repeating arithmetic over the same fixed reading is allowed to exclude operator error. A failed artifact is never edited, retagged, or resubmitted with altered values. An unresolved missing, unreadable, corrupted, substituted, or inconsistent Share triggers Recovery followed by a new Sharing Ceremony.

## Row, Column, and GIC Validation

### Row Check

For row `j` on Share `x`:

```text
R_j[x] = (w_{3j-2}[x] + w_{3j-1}[x] + w_{3j}[x] + j) mod 2053
```

### Column Check

For column `c` on Share `x`:

```text
C_c[x] = (sum of word values in column c on Share x + tauC_c) mod 2053
```

where `tauC = 100, 200, 300`.

### Printed GIC Check

The printed GIC is share-bound by adding the Share index `x`.

Any of these equivalent checks may be used:

```text
GIC[x] = (sum all word values on Share x + T_R + T_C + x) mod 2053
GIC[x] = (sum all row checksums on Share x + T_C + x) mod 2053
GIC[x] = (sum all column checksums on Share x + T_R + x) mod 2053
```

## Manual Recovery

Inputs:

- any valid threshold set of `k` Shares from the same session and layer;
- BIP39 wordlist in the printed language;
- Lagrange coefficients for the selected Share indices;
- row/column constants for the word count.

Recommended precondition: complete Share Audit for each available Share when MAT or Manifest audit data exists.

### Step 1: Validate Each Share

For each Share:

1. Confirm header fields and Share index.
2. Validate all row checksums.
3. Validate all column checksums.
4. Validate the printed GIC.

Any mismatch is STOP.

### Step 2: Validate Lagrange Coefficients

Check:

```text
sum(gamma_j * x_j) mod 2053 = 0
```

Any mismatch is STOP.

### Step 3: Recover Row by Row

For any value position `A`, recover:

```text
A = sum(gamma_j * A[x_j]) mod 2053
```

For each row:

1. Recover the three word values and row checksum.
2. Immediately validate the recovered row checksum:

```text
(w_{3j-2} + w_{3j-1} + w_{3j} + j) mod 2053 = R_j
```

Mismatch is STOP. Recompute or re-read that row before continuing.

### Step 4: Global Validation

After all rows pass:

1. Recover the three column checksums by interpolation.
2. Validate each recovered column checksum.
3. Recover the share-bound GIC values by interpolation if available.

The `+x` terms cancel because of the Lagrange sanity check. The recovered base GIC must satisfy:

```text
G = (sum recovered words + T_R + T_C) mod 2053
G = (sum recovered row checksums + T_C) mod 2053
G = (sum recovered column checksums + T_R) mod 2053
```

The row and column tags do not cancel; they are embedded in the constant terms.

### Step 5: Convert to BIP39 Words

Every recovered final mnemonic index must be in `1..2048`. Any value outside that range is STOP.

Use the printed BIP39 wordlist language to convert indices to words. If the target wallet rejects the mnemonic, STOP and redo recovery arithmetic/transcription before assuming wallet-context failure.

### Step 6: Post-Recovery Checks

If recorded:

- verify the BIP39 checksum;
- verify RBT in software-assisted recovery;
- verify RVA by deriving the intended target wallet address;
- verify passphrase and derivation context.

RVA mismatch is WARN: possible wrong passphrase, wrong derivation path, share substitution, or wallet-context error.

## Manual Authentication Layer (MAT)

MAT authenticates word rows before recovery. It is optional and independent of the Shamir arithmetic.

Modes:

- no MAT;
- single MAT: one tag column;
- dual MAT: two independently keyed tag columns.

MAT applies only to word rows. It does not tag the footer row. MAT values are not interpolated.

For Share `x`, row `j`, and MAT column `c`, let the three word values be:

```text
W_j = (W_{j,1}, W_{j,2}, W_{j,3})
```

For each Share and MAT column, sample independent weights:

```text
u_1, u_2, u_3 in 0..2052
```

For each word row, sample an independent Row Pad:

```text
b_j in 0..2052
```

The printed MAT tag is:

```text
MAT_j = (u_1*W_{j,1} + u_2*W_{j,2} + u_3*W_{j,3} + b_j) mod 2053
```

Calculator-friendly execution:

```text
T0 = b_j
T1 = (T0 + u_1*W_{j,1}) mod 2053
T2 = (T1 + u_2*W_{j,2}) mod 2053
MAT_j = (T2 + u_3*W_{j,3}) mod 2053
```

The largest multiply-add intermediate is `2052^2 + 2052 = 4,212,756`, within an eight-digit calculator.

### MAT Key Counts

Per MAT column:

- 12-word Share: `3` weights + `4` Row Pads = `7` key values
- 24-word Share: `3` weights + `8` Row Pads = `11` key values

Dual MAT doubles the tag and key counts.

### MAT Placement

- MAT tags are printed on the Share beside word rows.
- Complete MAT keys or Split-Key halves are stored on the Manifest, never on the Share.
- A Whole-Key Manifest contains complete MAT keys and is secret material.
- Split-Key Manifest A and B contain additive shares of each MAT key value.

### Split-Key MAT

For each complete key value `z`, draw random `rho` in `0..2052`:

```text
z_A = rho
z_B = z - rho mod 2053
```

During Share Audit:

```text
z = z_A + z_B mod 2053
```

One half alone reveals no complete MAT key, but either half can be withheld or corrupted to cause denial.

### MAT Failure

If any required MAT tag fails verification, STOP. Do not edit the Share, rewrite tags, or retry with altered values. If the mismatch cannot be resolved as an operator reading error over the same fixed artifact, treat the Share as failed and proceed to Recovery followed by a new Sharing Ceremony.

## Manual Sharing

Manual sharing is possible but demanding. The recommended path is software-assisted on an offline device. Fully manual sharing is a continuity fallback.

Inputs:

- valid BIP39 mnemonic;
- selected threshold scheme;
- BIP39 wordlist language;
- share indices;
- uniform random source for `GF(2053)` values;
- optional MAT mode and Manifest custody model.

### Manual Randomness

All Shamir coefficients and MAT key values are sampled uniformly from `0..2052`.

Valid physical approaches include:

- DuraDice-39;
- the 4-bag DIY token method;
- another auditable method that samples uniformly from `0..2052`.

For DIY token methods, tokens within each bag must be indistinguishable by touch and sufficiently uniform in size, weight, and texture. Bags and token sets should be matching-color coded. Tokens must never migrate to the wrong bag.

### Step 1: Word Polynomials

For each BIP39 word index `w_i`, sample `k-1` independent coefficients:

```text
f_i(x) = w_i + a_1*x + ... + a_{k-1}*x^{k-1} mod 2053
```

Evaluate each polynomial at every Share index.

### Step 2: Row Checksums

For each row `j`, compute:

```text
R_j[x] = (w_{3j-2}[x] + w_{3j-1}[x] + w_{3j}[x] + j) mod 2053
```

Validate immediately for every Share.

### Step 3: Column Checksums

For each column:

```text
C_1[x] = (sum column 1 values + 100) mod 2053
C_2[x] = (sum column 2 values + 200) mod 2053
C_3[x] = (sum column 3 values + 300) mod 2053
```

Validate for every Share.

### Step 4: Printed GIC

For each Share:

```text
GIC[x] = (sum all word values + T_R + T_C + x) mod 2053
```

Validate using word, row, and column paths.

### Step 5: MAT, If Selected

For each Share and MAT column:

1. Generate the Share Weights.
2. Generate one Row Pad per word row.
3. Compute the MAT tag for each word row.
4. Record MAT tags on the Share.
5. Record complete MAT keys or split MAT key halves on the Manifest.

### Step 6: Transcription Validation

After transcribing each Share:

- validate every row;
- validate every column;
- validate printed GIC;
- validate every MAT tag if MAT is selected.

After creating a Manifest:

- confirm it is separate from all Shares;
- confirm it contains no plaintext Share values;
- confirm it contains no printed GIC map;
- confirm MAT key material follows the selected Whole-Key or Split-Key custody model.

## Nesting

At layer `L > 0`, the values being shared are `GF(2053)` elements from the parent layer, not BIP39 word indices. Values `0, 2049, 2050, 2051, 2052` are valid inputs at nonzero layers.

BIP39 wordlist language, RBT, and RVA binding apply at the outermost protocol object as specified by the whitepaper and software profile.

For `k = 1`, the polynomial is constant and all shares are identical copies. This provides replication without threshold protection.

## Conformance

Canonical vectors are in `test_vectors/`. Implementations claiming v0.7.0 compatibility must validate against the current v0.7.0 vectors and clearly state which vector coverage they implement.
