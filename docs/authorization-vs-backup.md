# Why Multisig Is Not a Backup Protocol

When people first see DuraShare, a frequent question is: why not just use multisig?

Because those tools answer different questions.

- **Multisig** (and related threshold signing) answers: who may spend, under what policy.
- **DuraShare** answers: how do you back up a BIP39 mnemonic so it can survive lost devices, missing people, and recovery years later—without depending forever on one app or vendor.

You can use both. One does not replace the other.

## The silent SPOF

For spending, multisig avoids putting one private key in sole control. That part is solid.

For recovery, many setups still have a quiet single point of failure: the **wallet definition**—descriptor, script template, derivation, and the full set of public keys—not just “enough seeds.”

People remember: *if I keep 2 of 3 seeds, I can rebuild.* That matches secret sharing. It does not fully match script multisig.

Classical multisig scripts usually commit to **all** cosigner public keys. Having a threshold of private keys lets you sign. It does not always let you rebuild the wallet if a cosigner’s xpub was never saved and that device is gone. The descriptor (or equivalent export) is what ties the keys into *this* wallet. It is often left in an app, an encrypted cloud file, or nowhere—because nobody treated it as first-class backup material.

A failure that shows up late:

1. Setup feels finished once “2-of-3” works in the coordinator.
2. Years pass. One key is lost, bricked, or seized.
3. The remaining seeds are loaded. Rebuild fails or stalls: missing pubkey/xpub, unknown path or script type, locked or lost descriptor.
4. Offline brute-force only helps when you still know what to search for. Missing public material and forgotten enrollment details shrink that hope fast.

Taproot and MuSig-style designs change how spends look on-chain. They do not remove the need to know what was created, or to back up each participant seed.

## Checking the vault is not checking the backup

You do not need a broadcast spend to test much of multisig. Message signing and offline PSBT checks can show that keys and a known descriptor still work.

That audits devices and policy **today**. It does not prove that a paper or metal seed backup is intact, or that an heir can recover the descriptor without the original account. Those are backup problems.

DuraShare’s Share Audit is aimed at the backup side: check one share without gathering a threshold and without turning the check into a full recovery.

## How this sits with DuraShare

DuraShare splits an existing BIP39 mnemonic into k-of-n durable shares, with optional per-share audit and a specified manual fallback. It does not decide who may sign. It does not replace a multisig descriptor.

If you spend with singlesig, back up that mnemonic. If you spend with multisig, each cosigner seed still needs a backup plan—and the wallet definition does too. Threshold backup of a seed and threshold authorization of a spend are different layers. Confusing them is what produces “why not multisig?” when the topic was backup.
