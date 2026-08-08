# DuraShare (Specification)

**Current version:** v0.7.0

[![Security: Unaudited](https://img.shields.io/badge/Security-Unaudited-orange)](https://github.com/GRIFORTIS/.github/blob/main/SECURITY.md)
[![CI](https://github.com/GRIFORTIS/durashare/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/GRIFORTIS/durashare/actions/workflows/ci.yml)
[![CodeQL](https://github.com/GRIFORTIS/durashare/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/GRIFORTIS/durashare/actions/workflows/codeql.yml)
[![Whitepaper: CC BY 4.0](https://img.shields.io/badge/Whitepaper-CC%20BY%204.0-green.svg)](LICENSE-WHITEPAPER.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## About DuraShare

**In one line:** DuraShare lets you split a standard **BIP39** recovery phrase into **k-of-n** durable, human-readable backup shares, with optional **per-share audit** before recovery. The normal experience is **offline, software-assisted sharing and recovery**; the same core math can also be executed fully manually when software is unavailable or untrusted.

### Typical lifecycle

![DuraShare operational flow](docs/protocol-lifecycle.png)

Non-normative overview: Sharing → geographic custody with per-share audit → Recovery (software-assisted or fully manual). The whitepaper and specs remain authoritative. Vector source: [`docs/protocol-lifecycle.svg`](docs/protocol-lifecycle.svg).

## Problem

Self-custody often depends on one recovery phrase. If it is lost, funds may be gone forever; if it is exposed, funds may be stolen. A good backup needs more than secrecy: it should survive missing people, damaged artifacts, copying mistakes, unavailable devices, expired subscriptions, unavailable services, and future recovery by someone who may not have the original setup.

DuraShare focuses on **cold storage and disaster recovery** for an existing BIP39 phrase. It is meant for people, families, businesses, advisors, and organizations that want threshold backup without permanently depending on one app, hardware vendor, custodian, paid subscription, hosted recovery service, software implementation, or custom share alphabet.

## What DuraShare is

At the technical layer, DuraShare is a **Shamir-style** secret sharing scheme applied directly to the words of a valid BIP39 mnemonic. Each word is treated as its **1-based index** in the BIP39 word list (`abandon` = 1, `zoo` = 2048), and the sharing math runs modulo **2053**, the smallest prime larger than the word list.

Any **k** of **n** shares reconstruct the original mnemonic. Fewer than **k** shares reveal no information about it, under the standard information-theoretic secrecy claim of Shamir sharing. The optional **BIP39 passphrase** ("25th word") is **NOT** stored in the shares and must be backed up and re-entered separately if you use one.

In practice, the protocol is **software-assisted first**. In the normal path, an offline tool handles the arithmetic, guides the **Sharing**, **Share Audit**, and **Recovery** ceremonies, validates intermediate checks, and produces printable or hand-transcribable share and manifest artifacts. The intended reference path is a single PGP-verified HTML file that can run locally on an air-gapped computer; high-assurance runs of those ceremonies can use a [Tails OS](https://tails.boum.org/) USB session.

DuraShare **modifies existing, well-established cryptographic techniques** so threshold backup and recovery remain human-friendly — including fully manual execution with simple arithmetic aids when needed. Reference implementations are thoroughly tested, published in good faith **as is**, and have **not** been independently audited. **Do not use with real funds.** See [Disclaimer](#disclaimer).

## Why Manual Fallback Matters

Manual fallback is not the recommended everyday workflow. It is the sovereignty backstop.

The software should make Sharing and Recovery easier, faster, and less error-prone. But a backup meant for serious self-custody should not become useless just because the original app is gone, a vendor disappears, a subscription lapses, a hosted service shuts down, an app store is blocked, an operating system changes, or Recovery happens years later in a constrained environment. DuraShare keeps the software-assisted workflow practical while keeping the arithmetic readable from durable artifacts such as paper, metal, or other long-lived media.

The same shares can be generated or recovered using printed or engraved tables, a basic calculator, modular arithmetic, and precomputed Lagrange coefficients. In other words: use software when you can; keep the fully manual ceremony path specified for when you cannot.

## Why Per-Share Audit Matters

Long-term, geographically distributed backups should be checkable before the day they are needed. DuraShare defines a separate **Share Audit Ceremony**: one physical share can be audited at a time, wherever it is stored, without gathering a threshold set, combining shares, or exposing the mnemonic. In many backup systems, a meaningful audit effectively becomes a recovery drill: enough shares must be brought together to reconstruct or nearly reconstruct the secret, increasing coordination burden and creating an unnecessary exposure event. Here, Share Audit and Recovery are separate ceremonies.

In the manual Share Audit Ceremony, public row/column/GIC checks detect passive damage or transcription errors, while optional MAT tags can authenticate the word rows against separately stored Manifest key material. In the software-assisted Share Audit Ceremony, Full and Compact payloads plus Manifest Audit Hashes add computational checks when a separate Manifest is available. The result is a practical pre-recovery check: each geographically distributed custodian artifact can be inspected periodically without gathering a threshold set or turning Share Audit into Recovery.

## Why Not Just Use Multisig?

Multisig is a strong answer to a different question.

On-chain multisig and related threshold-signing designs decide **who may spend** under a policy. DuraShare decides how to **back up a BIP39 mnemonic** into durable k-of-n shares, with optional per-share audit and a path that does not permanently depend on one app or vendor. You can use both: multisig (or singlesig) for spending, and a threshold backup protocol for the seed material behind it.

“2-of-3 seeds rebuild the wallet” matches secret sharing. It does not fully match script multisig. Spending usually needs a threshold of private keys; rebuilding often also needs the **wallet definition**—descriptor, script template, derivation, and the full set of public keys. That material is easy to leave in an app or an encrypted file and discover only when a cosigner device is already gone. Checking that a vault still signs (message or PSBT) is also not the same as checking that a dormant seed backup is intact.

Longer note: [`docs/authorization-vs-backup`](docs/authorization-vs-backup.md).

## Who This Is For

DuraShare is for people and organizations that want threshold backup of an existing BIP39 phrase without turning one vendor, device, custodian, subscription, hosted service, or software stack into a permanent dependency. Common use cases include:

- **Security-conscious self-custodians** who want a smoother way to split and later recover a seed without locking themselves into a proprietary backup format.
- **Individuals and families** setting up backup, succession, or inheritance plans where recovery may involve relatives, heirs, or trusted advisors.
- **Businesses, family offices, and Bitcoin treasury holders** that need durable backup for seed material, whether the spending setup uses single-sig, multisig, dedicated hardware wallets, or a combination of custody controls.
- **Professional advisors and service providers** helping clients run Sharing, Share Audit, and Recovery ceremonies while keeping the advisor out of the secret-handling path.
- **Non-Governmental Organizations, civil-society groups, journalists, activists, and human-rights defenders** that hold Bitcoin across people or jurisdictions and need recovery arrangements that do not rely on a single account, app store, vendor, or country.
- **Cross-border custody arrangements** where shares are held in different locations and recovery should remain possible even when travel, infrastructure, or access to specific services is disrupted.

## What it does and how

- **Threshold backup:** Split one BIP39 phrase into **n** shares and choose how many are needed to recover it. Typical examples are 2-of-3, 2-of-4, or 3-of-5.
- **Human-readable shares:** A share is a table of numbers and word indices with checksums, optionally paired with a QR payload for software-assisted validation. Artifacts may be paper, metal, or other long-lived media. A separate optional Manifest can track the shares, their destinations, and audit fingerprints without containing the mnemonic or plaintext share contents.
- **Offline-first workflow:** The recommended path for any ceremony uses an air-gapped tool to do the math, guide the user, create share tables, and optionally produce QR payloads and Manifests.
- **Full manual path:** The same protocol can be executed without software: Sharing, Share Audit and Recovery can be done with durable tables, modular arithmetic, random coefficients, checksums, and precomputed Lagrange coefficients. Software is helpful, not mandatory forever.
- **Error detection:** Row checksums, column checksums, and a **Global Integrity Check** help catch arithmetic mistakes, transcription errors, damaged entries, and wrong share labels before they silently become a bad recovery.
- **Output profiles:** Two profiles available, Full and Compact. The first serializes the complete canonical arithmetic table and includes a Transport Hash. The second serializes word shares only, reducing QR size and hand-transcription burden while checking against the printed table.
- **Per-share audit:** The protocol defines a separate **Share Audit Ceremony**, so one physical share can be checked before Recovery without combining it with other shares. Public row/column/GIC checks catch passive corruption, optional MAT tags provide bounded manual substitution detection, and a separately stored Manifest Audit Hash can commit to each share payload.
- **Post-recovery validation:** After the Recovery ceremony, software can check the BIP39 checksum, compare the protocol-input-bound **Recovery Binding Tag (RBT)**, and optionally compare a truncated **Recovery Verification Address (RVA)** re-derived offline from the intended wallet setup.
- **Nested custody:** A share can itself be shared again, enabling layered arrangements such as family, business, trustee, or inheritance structures. Full Output Profile supports up to **four active layers** and Compact up to **two active layers**, while single-layer Sharing remains the baseline workflow.
- **Output choices:** The protocol distinguishes printer trust levels, so secret-bearing material is only sent to devices appropriate for the Sharing ceremony. When printing is not trusted or not available, users can hand-transcribe the share tables and, where used, copy or paint the QR grids by hand.
- **Pause and resume:** Longer software-assisted Sharing ceremonies can be paused and resumed with encrypted resume artifacts. A companion app may help store or transport those encrypted artifacts and non-secret print materials without seeing the mnemonic, plaintext shares, random coefficients, or recovery secret.

## What it is not

- **Not** multisig, MPC, or a spending policy. It protects recovery material; it does not decide who may sign transactions.
- **Not** protection against every real-world threat. Physical security, custodian selection, ceremony hygiene, and malware resistance still matter.
- **Not** magic against **k or more compromised shares**. If enough valid shares are exposed, the mnemonic can be recovered.
- **Not** authentication by checksums alone. A malicious party who can rewrite a whole share may also recompute its arithmetic checks; substitution detection comes from custody practice, Manifests, identity checks, and wallet-context checks where used.
- **Not** independently audited production software; implementations are published as-is.

## Comparison with related approaches

MPC wallets, on-chain multisig, and social-recovery contracts mostly answer **who may spend** and **under what online policy**. DuraShare answers a narrower backup question: how to split an **existing BIP39 mnemonic** into durable threshold share artifacts, optionally run a Share Audit Ceremony on one share at a time, and later run Recovery for the **same standard mnemonic** ordinary wallets already import—with a software-assisted path and a fully manual path.

**Manual-capable mnemonic backup schemes**

Codex32 uses BCH codes and paper aids such as volvelles and tables. It provides strong manual error handling, but it does not round-trip a standard BIP39 mnemonic. SeedXOR is deliberately minimal: XOR splitting has a simple mental model and BIP39-shaped output, but it is n-of-n only and offers little structured detection when something is wrong. Neither defines a per-share audit: a meaningful backup check still requires assembling enough shares for a full recovery.

| Feature | DuraShare | Codex32 | SeedXOR |
| --- | --- | --- | --- |
| Primary scope | BIP39 | Bitcoin/BIP32 only | BIP39 |
| Threshold flexibility | Full *k-of-n* | *k-of-n* (k<=9, n<=31) | *n-of-n* only |
| Manual procedure | Integer arithmetic mod 2053 | BCH + volvelles/tables | XOR |
| Error handling | Detection (*d*=4 linear layer) | Correction (BCH) | Weak / none |
| Per-share pre-recovery check | Yes (a) | Error detection only | No |
| Post-recovery verification | BIP39 + RBT + optional RVA (b) | Not BIP39-native output | BIP39 only |
| BIP39 round-trip | Native I/O | No | Yes |
| Share representation | Durable table + optional QR | Custom bech32 strings | BIP39 words |
| Recursive composition | Yes | Flat | Flat |

**(a)** Public row/column/GIC checks validate passive consistency; optional MAT adds manual pre-recovery substitution detection; Manifest Audit Hashes add computational commitment checks when a separate Manifest is available. **(b)** RBT binds the recovered protocol object to the original session; RVA is a truncated wallet witness recorded at setup and re-derived after recovery.

**Software-oriented threshold schemes**

SLIP39 and SSKR are built for software-led recovery. Both use sound finite-field sharing, but neither specifies a plain pencil-and-paper prime-field path for the full sharing and recovery flow. SLIP39 uses a different derivation model than BIP39, so the same underlying material does not restore the same wallet as a normal BIP39 mnemonic. SSKR preserves BIP39 round-trip behavior by operating on raw entropy and packaging shares as Bytewords or UR; recovery still assumes the decoding stack is available. Share checksums catch transport damage, but a meaningful backup check still requires assembling a threshold set and running a full recovery.

| Feature | DuraShare | SLIP39 | SSKR |
| --- | --- | --- | --- |
| Arithmetic domain | Prime GF(2053) | GF(2^8) + RS1024 checksum | Extension GF(2^8) |
| Wallet compatibility | Native BIP39 | Different derivation (a) | BIP39 round-trip via raw entropy (b) |
| Share encoding | Table + optional QR | Custom 20-word encoding | Bytewords / UR |
| Per-share pre-recovery check | Yes (c) | Share checksum only | Share checksum only |
| Post-recovery verification | BIP39 + RBT + RVA (d) | Reconstruction digest in polynomial (e) | BIP39 checksum |
| Non-software path | Yes, Sharing and Recovery | No | No |
| Manual arithmetic | Integer mod 2053 | No | No |

**(a)** SLIP39 restoration does not reproduce a standard BIP39 wallet from the same encoded material. **(b)** SSKR preserves the usual BIP39 seed when round-tripped through its documented encodings; the share transport is not aimed at hand evaluation of GF arithmetic. **(c)** Public consistency checks, optional MAT, and Manifest Audit Hashes support single-share verification without recombination. **(d)** RBT tests the recovered protocol object; RVA tests the intended wallet context, including derivation and optional passphrase. **(e)** SLIP39 embeds a four-byte reconstruction digest in the polynomial so the reconstructed master secret self-checks.

## Canonical documents
- **Whitepaper**: [PDF](whitepaper/WHITEPAPER.pdf) | [LaTeX](whitepaper/WHITEPAPER.tex)
- **Current manual execution specification**: [`manual_spec/README`](manual_spec/README.md)
- **Current software (digital envelope) specification**: [`software_spec/README`](software_spec/README.md)
- **Test vectors**: [`test_vectors/README`](test_vectors/README.md)
- **Previous version archives**: [`previous_versions/README`](previous_versions/README.md)
- **Security policy**: [SECURITY](https://github.com/GRIFORTIS/.github/blob/main/SECURITY.md)
- **Standing review guide**: [`docs/review`](docs/review.md)
- **Proposals**: [`proposals/`](proposals/)

## Implementations
Reference implementations may lag the current specification. Treat each repository as conformant only when it explicitly declares support for the current spec and vectors:
- **HTML (single-file, air-gapped)**: [`durashare-html`](https://github.com/GRIFORTIS/durashare-html)
- **JavaScript/TypeScript**: [`durashare-js`](https://github.com/GRIFORTIS/durashare-js)
- **Python**: [`durashare-py`](https://github.com/GRIFORTIS/durashare-py)

**Deployment note:** For higher-assurance Sharing, Share Audit, or Recovery ceremonies, the single-file HTML tool can be verified by PGP signature, loaded from a USB stick, and run in a [Tails OS](https://tails.boum.org/) session on a laptop with networking disabled. Share artifacts are then printed, engraved, or hand-transcribed according to the chosen printer-trust tier and media.

## People

**Renato Schiavinato Lopez** — Founder & Protocol Author · [LinkedIn](https://www.linkedin.com/in/renato-agile-coach/) · [GitHub](https://github.com/renatoslopes)

**Jeroen van de Graaf** — Chief Scientist; Advisory Board · Professor, DCC–UFMG · [Google Scholar](https://scholar.google.com/citations?user=-w8olWwAAAAJ) · [UFMG / T-REX](https://trex.dcc.ufmg.br/en/author/jeroen-van-de-graaf/)

Full bios: [GRIFORTIS](https://github.com/GRIFORTIS).

## Licenses
- **Code**: [MIT License](LICENSE)
- **Whitepaper**: [CC BY 4.0](LICENSE-WHITEPAPER.md)

## Release authenticity
- Release source state is anchored on signed git tags.
- Release assets such as `WHITEPAPER.pdf` and `CHECKSUMS.txt` are intended to be signed locally and published with detached `.asc` signatures.
- Use [`RELEASE.md`](RELEASE.md) for the maintainer workflow and [`docs/release-verification.md`](docs/release-verification.md) for public verification guidance.

## Engagement

### Informal technical review

Feedback on earlier drafts of the protocol or related specification material (not a formal audit). Details are in the whitepaper Acknowledgments.

- Jean Martina — LabSEC, INE–UFSC
- Julio López — LASCA, IC–UNICAMP
- Edil Medeiros — ENE–UnB; Vinteum/Casa21
- jaonoctus — ZBD; Vinteum/Casa21

### Public record

Dated public discussion of the protocol. This is not an endorsement.

- 2026-07-23 — [São Paulo BitDevs, Seminário Socrático 046](https://saopaulobitdevs.org/2026-07-23-socratic-seminar-046) — protocol discussion

## Disclaimer

Software has been thoroughly tested and is not known to contain errors. It is made available in good faith, as is, so use at your own risk. The author does not assume any responsibility for any damage, financial or other, that may result from using this software. Reference implementations have not been independently audited. **Do not use with real funds.** See [SECURITY](https://github.com/GRIFORTIS/.github/blob/main/SECURITY.md).

---

**Maintained by**: [GRIFORTIS](https://github.com/GRIFORTIS)
