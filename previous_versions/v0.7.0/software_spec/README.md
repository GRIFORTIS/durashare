# Schiavinato Sharing - Software Specification (`software_spec`)

> ## WARNING: EXPERIMENTAL SOFTWARE
>
> DO NOT USE IT FOR REAL FUNDS.
>
> Schiavinato Sharing specifications and prototype implementations have not been audited. Use for testing, learning, and review only. See the organization security policy for private disclosures.

This document defines the v0.7.0 software-assisted workflow and digital envelope for Schiavinato Sharing.

Normative keywords **MUST**, **MUST NOT**, **SHOULD**, **MAY** are used as requirements.

## Scope

This spec covers:

- software-assisted ceremony boundaries;
- resume modes and coefficient sourcing;
- Full and Compact Output Profiles;
- byte-level share Payloads;
- RBT derivation;
- Transport Hash and Manifest Audit Hash checks;
- artifact rendering and printer tiers;
- decode and validation pipeline;
- cleanup and versioning rules.

The whitepaper is the security and protocol-analysis reference. `manual_spec/` is authoritative for `GF(2053)` arithmetic, row/column/GIC validation, manual recovery, Share Audit, and MAT calculations.

## Terminology

- **Payload**: the self-identifying byte sequence carried by a share QR or exact text export.
- **Output Profile**: Full or Compact.
- **Full**: serializes the complete canonical arithmetic Share table and includes a Transport Hash.
- **Compact**: serializes word-share values only and relies on recomputation against the printed table for row, column, and GIC checks.
- **RBT**: Recovery Binding Tag, a protocol-input-bound post-recovery warning tag.
- **Manifest Audit Hash**: a Manifest-held commitment to one Share Payload.
- **Resume artifact**: temporary sharing-continuity material. It is not recovery material.
- **MAT**: Manual Authentication Layer. MAT tags and keys are human-readable artifact fields and are not serialized in any Payload.

## Artifact Classes

Implementations SHOULD distinguish:

1. **Arithmetic Share content**: word shares, row checksums, column checksums, printed GIC, and optional MAT tags rendered on the Share.
2. **Share-local recovery metadata**: BIP39 language, passphrase presence/hint, derivation hint, RVA, label/date, threshold, Share index, layer path, and MAT selection.
3. **Manifest material**: session metadata, per-share Audit Hashes, MAT keys or Split-Key halves, custody notes, and copied wallet-context hints.
4. **Resume artifacts**: temporary encrypted or hand-transcribed material used only to continue an interrupted Sharing Ceremony.

Manifests MUST NOT contain plaintext Share values and SHOULD NOT contain printed GIC maps. MAT key material is secret material and follows the selected Whole-Key or Split-Key custody model.

## Software-Assisted Ceremony Boundary

Software-assisted sharing is split into two application roles:

- **Air-Gapped App**: handles mnemonic entry, coefficient generation or decryption, share evaluation, MAT generation, artifact rendering, and all plaintext secret-bearing output.
- **Companion App**: may handle ciphertext resume artifacts and non-secret or operationally sensitive print material. It MUST NOT see the mnemonic, plaintext coefficients, plaintext Share values, complete MAT keys, Split-Key reconstruction values, the Encryption Passphrase, or decrypted resume material.

Any printer, scanner, camera, calculator, or peripheral that receives secret-bearing material is part of the trusted environment for that workflow.

## Setup Inputs

Before mnemonic entry, implementations collect non-secret setup context:

- backup label/date;
- original word count;
- BIP39 wordlist language, or Pre-Encrypted Numeric Input mode;
- threshold topology and Share indices;
- Output Profile: Full or Compact;
- MAT selection: none, single, or dual;
- Manifest custody: none, Whole-Key, or Split-Key;
- printer/output tier;
- resume mode;
- wallet/derivation hint;
- BIP39 passphrase presence/hint, never the passphrase itself;
- optional RVA.

The BIP39 wordlist language MUST be rendered prominently on every Share and Manifest in BIP39 mode.

## Output Profiles

| Property | Full | Compact |
|---|---|---|
| Share data | Complete canonical arithmetic table | Word shares only |
| Serialized checksums | Row checksums, column checksums, printed GIC | None |
| Transport Hash | Present, 16 bytes | Omitted |
| RBT length | 12 bytes | 6 bytes |
| Session Batch ID | 8 bytes | 4 bytes |
| Active nesting depth | Up to 4 layers | Up to 2 layers |
| Representative 24-word QR | 99-byte Payload, V6-M | 53-byte Payload, V3-L |

Full is recommended for long-term, high-value custody. Compact is for constrained-output workflows where QR size, small displays, or hand transcription materially dominate operational risk.

## Shared Payload Fields

Both profiles use:

- profile prefix;
- protocol version;
- flags;
- Language/Input byte;
- threshold path;
- Share-index path;
- Session Batch ID;
- RBT;
- ShareData.

Full appends a Transport Hash.

### Protocol Version

`0x01` identifies the active v0.7.0 payload format.

Unknown versions are STOP unless an implementation explicitly supports them.

### Flags Byte

Layout:

- bits `0..2`: word count code:
  - `0 = 12`
  - `1 = 15`
  - `2 = 18`
  - `3 = 21`
  - `4 = 24`
  - `5..7` reserved
- bits `3..5`: wallet/derivation hint:
  - `000 = BIP44 Legacy`
  - `001 = BIP49 Nested SegWit`
  - `010 = BIP84 Native SegWit`
  - `011 = BIP86 Taproot`
  - `100 = Hardware default`
  - `101 = Generic/Custom`
  - `110..111` reserved
- bits `6..7`: nesting depth:
  - Full: `00` flat, `01` two layers, `10` three layers, `11` four layers
  - Compact: bit `6` only; bit `7` MUST be zero

The wallet hint is a coarse recovery aid. It does not replace share-local wallet context needed for RVA verification.

### Language/Input Byte

| Value | Meaning |
|---:|---|
| `0x00` | Pre-Encrypted Numeric Input |
| `0x01` | BIP39 English |
| `0x02` | BIP39 Japanese |
| `0x03` | BIP39 Chinese Simplified |
| `0x04` | BIP39 Chinese Traditional |
| `0x05` | BIP39 Spanish |
| `0x06` | BIP39 French |
| `0x07` | BIP39 Italian |
| `0x08` | BIP39 Korean |
| `0x09` | BIP39 Czech |
| `0x0A` | BIP39 Portuguese |

This byte is included in the RBT canonical material. In BIP39 mode it selects the wordlist language that defines the input indices. In Pre-Encrypted Numeric Input mode, recovered output is encrypted numeric material and is not wallet-ready until decrypted outside the protocol.

### Threshold and Share-Index Paths

All Share indices are nonzero. Per-layer recovery indices must be distinct.

Full allocates two bytes each for threshold path and Share-index path:

- depth 0: byte 0 = layer 0, byte 1 = zero;
- depth 1: byte 0 = layer 0, byte 1 = layer 1;
- depth 2: four-bit packing for layers 0, 1, 2, with the fourth nibble zero;
- depth 3: four-bit packing for layers 0, 1, 2, 3.

Compact allocates one byte each:

- depth 0: byte = layer 0;
- depth 1: low nibble = layer 0, high nibble = layer 1.

## Value Packing

All `GF(2053)` values are packed as 12-bit unsigned integers in the range `0..2052`.

Packing is MSB-first. Compact ShareData is padded with zero bits to the next byte boundary. Full canonical table sizes are exact byte multiples and require no ShareData padding.

## Full Payload

Full Payload:

```text
SF || V || F || L || K || X || B || R || ShareData || H
```

Fields:

| Field | Length | Meaning |
|---|---:|---|
| `SF` | 2 | Full profile prefix |
| `V` | 1 | protocol version |
| `F` | 1 | flags |
| `L` | 1 | Language/Input |
| `K` | 2 | threshold path |
| `X` | 2 | Share-index path |
| `B` | 8 | Session Batch ID |
| `R` | 12 | RBT |
| `ShareData` | variable | complete canonical arithmetic table |
| `H` | 16 | Transport Hash |

Full ShareData encodes, in order:

1. all word-share values;
2. all row checksums;
3. the three column checksums;
4. the printed GIC.

Full payload sizes:

| Word count | Elements | ShareData bytes | Payload bytes |
|---:|---:|---:|---:|
| 12 | 20 | 30 | 75 |
| 15 | 24 | 36 | 81 |
| 18 | 28 | 42 | 87 |
| 21 | 32 | 48 | 93 |
| 24 | 36 | 54 | 99 |

Baseline QR:

- 12/15 words: V5-M
- 18/21/24 words: V6-M

## Compact Payload

Compact Payload:

```text
SC || V || F || L || K || X || B || R || ShareData
```

Fields:

| Field | Length | Meaning |
|---|---:|---|
| `SC` | 2 | Compact profile prefix |
| `V` | 1 | protocol version |
| `F` | 1 | flags |
| `L` | 1 | Language/Input |
| `K` | 1 | threshold path |
| `X` | 1 | Share-index path |
| `B` | 4 | Session Batch ID |
| `R` | 6 | RBT |
| `ShareData` | variable | word-share values only |

Compact ShareData encodes word-share values only. Row checksums, column checksums, and printed GIC are not serialized and must be recomputed from the scanned words and compared against the paper Share.

Compact payload sizes:

| Word count | Elements | ShareData bytes | Payload bytes |
|---:|---:|---:|---:|
| 12 | 12 | 18 | 35 |
| 15 | 15 | 23 | 40 |
| 18 | 18 | 27 | 44 |
| 21 | 21 | 32 | 49 |
| 24 | 24 | 36 | 53 |

Baseline QR:

- 12/15 words: V3-M
- 18/21/24 words: V3-L

## RBT Derivation

RBT is a warning tag for the recovered protocol object. It is not part of Shamir secrecy.

Inputs:

- password: canonical secret material;
- salt: Session Batch ID;
- KDF: PBKDF2-HMAC-SHA512;
- iterations: `16,384`;
- output: 32 bytes.

RBT bytes:

- Full: first 12 bytes;
- Compact: first 6 bytes.

Canonical secret material:

```text
Language/Input byte || pack12(input symbols at x=0)
```

In BIP39 mode, input symbols are the original 1-based BIP39 word indices. In Pre-Encrypted Numeric Input mode, input symbols are the externally encrypted field elements. The canonical secret material is never serialized outside the RBT derivation.

After recovery, software recomputes the RBT from the recovered object and compares it to the payload value. A mismatch is WARN: possible wrong shares, corruption, substitution, or wrong protocol input.

## Transport Hash

Full includes a 16-byte Transport Hash:

```text
H = first 16 bytes of SHA-256(SF || V || F || L || K || X || B || R || ShareData)
```

Transport Hash mismatch is STOP.

Compact omits the Transport Hash. Compact transport integrity relies on QR error correction plus paper-table validation.

## Manifest Audit Hash

A Manifest Audit Hash commits to one Share Payload.

Recommended rule:

```text
AuditHash = SHA-256(Payload)
```

If a constrained Compact audit artifact uses a truncated hash, the truncation length MUST be explicit in the artifact version and UI. The conservative default is full SHA-256.

Audit Hash mismatch is STOP.

MAT fields are not included in Payload or AuditHash input. They are checked separately during Share Audit.

## Resume Modes

All resume modes are available under both Output Profiles.

Resume is mid-sharing continuity only. Recovery never consumes resume artifacts.

### Digital Resume

Generate the exact true-random coefficient material before mnemonic entry. Encrypt the coefficient material and non-secret session context with an Encryption Passphrase. Offer encrypted QR and/or text export.

### Hand-Transcribed Table

Generate true-random coefficients and display coefficient tables for paper transcription and re-entry validation. No Encryption Passphrase is used.

### Hand-Transcribed QR

Generate a 256-bit Deterministic Resume Key (DRK), encrypt it with the Encryption Passphrase, and display it as a compact QR with non-secret Extra Data.

Coefficients are derived from the DRK using domain-separated HMAC-SHA256 over public ceremony context:

```text
HMAC-SHA256(DRK, domain || version || profile || layer_path || scheme || element_position || coefficient_index) mod 2053
```

This is the only active resume mode that adds a computational coefficient-generation assumption.

### No Resume

Generate true-random coefficients in volatile memory only. No resume artifact is produced.

## Resume Encryption Envelope

Digital Resume and Hand-Transcribed QR require an Encryption Passphrase distinct from any BIP39 passphrase.

Recommended encryption:

- KDF: Argon2id with random salt; scrypt acceptable as fallback;
- encryption: XChaCha20-Poly1305; AES-256-GCM acceptable as fallback;
- authenticated data should bind protocol version, resume artifact type, word count, scheme, Output Profile, and resume mode.

Failed decryption or authentication is STOP. Implementations MUST NOT reveal partial decrypted data.

## Artifact Rendering

Each Share artifact SHOULD render:

- protocol name and version;
- backup label/date, if provided;
- BIP39 wordlist language in BIP39 mode;
- original word count;
- threshold and Share index;
- layer path, if nested;
- MAT selection;
- passphrase presence/hint, without the passphrase itself;
- wallet/derivation hint and RVA, when used;
- human-readable Share table, including MAT columns when selected;
- QR Payload and optional text export when supported.

Out-of-range Share values `0, 2049, 2050, 2051, 2052` must be rendered as numeric `GF(2053)` field elements, not missing BIP39 words.

MAT tags and complete or split MAT keys are human-readable artifact fields. They are never serialized in the Payload.

## Manifest Rendering

A Manifest MAY contain:

- protocol name and version;
- backup label/date;
- Session Batch ID;
- RBT reference or display value;
- scheme and Output Profile metadata;
- BIP39 language and wallet-context hints;
- per-share Audit Hashes;
- custodian or storage notes;
- Whole-Key MAT material, or Split-Key Manifest half material.

A Manifest MUST NOT contain plaintext Share values. A Manifest SHOULD NOT contain printed GIC maps.

If using Split-Key MAT, Manifest A and Manifest B are complete operational counterparts except for the MAT key half fields.

## Share Audit Pipeline

Share Audit validates one physical Share without combining Shares or recovering the mnemonic.

Recommended order:

1. Capture one fixed reading of the physical Share.
2. Validate the paper row checksums, column checksums, and printed GIC.
3. If a Payload exists, decode it.
4. Validate version, profile, field lengths, word count, threshold, Share index, and Session Batch ID.
5. In Full, validate Transport Hash.
6. Compare serialized Payload values against the fixed paper reading:
   - Full: complete canonical arithmetic table;
   - Compact: every word-share value, then recompute row/column/GIC from paper.
7. If a Manifest Audit Hash exists, compare it to the Payload hash.
8. If MAT exists, verify every required MAT tag using the matching Manifest key material.

Any unresolved mismatch is STOP. A failed Share is never edited, retagged, or resubmitted with changed values.

## Recovery Decode Pipeline

For each selected Share:

1. Decode Payload, if present.
2. Validate profile, version, field lengths, and metadata.
3. Validate Transport Hash in Full.
4. Compare Payload to the physical Share.
5. Validate Manifest Audit Hash if available.
6. Validate row/column/GIC via `manual_spec`.
7. Verify MAT if selected and available.

For the recovery set:

1. Confirm word count, threshold, BIP39 language, layer path, and Session Batch ID match where applicable.
2. Interpolate using `manual_spec`.
3. Validate recovered rows, columns, and base GIC.
4. Convert recovered indices to the selected BIP39 wordlist.
5. Validate BIP39 checksum.
6. Recompute RBT and compare.
7. Verify RVA when recorded.

RBT and RVA mismatch are WARN. Arithmetic, format, Transport Hash, Manifest Audit Hash, and required MAT failures are STOP.

## Printer and Output Tiers

Printer choice affects artifact handling, not arithmetic.

- **Tier 1 - offline non-network printer:** secret-bearing output allowed.
- **Tier 2 - user-controlled network-capable printer:** secret-bearing fields must be blank; user hand-transcribes secrets.
- **Tier 3 - untrusted printer:** blank structure only.
- **Tier 4 - no printer:** all output hand-transcribed from the air-gapped display.

Secret-bearing material includes Share values, row checksums, column checksums, printed GIC, MAT tags, MAT keys, complete or split MAT key halves, Payload QRs, and secret-bearing text exports.

Non-secret but operationally sensitive material includes Session Batch ID, RBT, Audit Hashes, labels, custodian notes, and wallet-context hints.

## Runtime Integrity Assertion

Before output, implementations MUST run an internal consistency assertion:

- Path A: compute row checksums, column checksums, and GIC from the polynomial/coefficient state.
- Path B: compute the same values from the rendered Share values by direct summation.

Any disagreement is STOP. The implementation MUST refuse to output artifacts.

## Draft Session Model

Sharing and recovery flows SHOULD be draft sessions until explicit export/print/finish confirmation.

Implementations SHOULD support:

- editing/removing one Share without restarting the whole session;
- recomputing from the last validated checkpoint;
- explicit reset/clear session action;
- visible cleanup checklist.

## Cleanup

After successful share creation and validation:

- application-managed resume artifacts MUST be deleted;
- decrypted coefficient material and DRK values MUST be cleared on a best-effort basis;
- user-held resume artifacts SHOULD be destroyed or separately secured according to the selected workflow;
- the Encryption Passphrase is no longer needed and SHOULD be forgotten/destroyed.

Browser and general-purpose OS memory clearing is best-effort only.

## Versioning

Implementations MUST reject unknown payload versions by default.

New versions must document:

- byte-level changes;
- compatibility and migration rules;
- vector version used for conformance.

## Conformance

Implementations claiming v0.7.0 support MUST validate against the current v0.7.0 vectors and clearly state which vector coverage they implement.

Implementations MUST NOT claim full v0.7.0 conformance beyond the published vector coverage they actually validate.
