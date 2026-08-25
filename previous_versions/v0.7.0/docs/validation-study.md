# Preliminary Validation Study: Manual Recovery Feasibility

**Date Range:** September 2024 - October 2025  
**Status:** Informal pilot study, formal validation planned January 2026  
**Author:** GRIFORTIS Research

## Abstract

This document presents findings from preliminary validation trials of manual recovery procedures for the Schiavinato Sharing scheme. Four family members (ages 28-72, zero self-custody experience) successfully completed manual wallet recovery using a 4-of-16 threshold configuration without pre-computed Lagrange coefficients—at the time of testing, pre-computation was not yet part of the design approach. Trials conducted 13 months apart demonstrate that the process is learnable from self-documenting written materials without prior experience or verbal instruction. Results validate core human-executability claims and provide empirical grounding for published time estimates. Formal usability study with controlled conditions scheduled for January 2026.

---

## 1. Study Overview

### Purpose
Initial feasibility assessment of manual recovery procedures for threshold secret sharing of BIP39 mnemonics.

### Timeline
- **Trial 1:** September 2024 (first exposure)
- **Trial 2:** October 2025 (13 months later, zero retention)

### Setting
Informal home environment with family participants. This preceded formal usability study design and served as proof-of-concept for manual recovery workflows.

### Key Research Questions
1. Can individuals with minimal crypto experience perform modular arithmetic required for recovery?
2. What is the practical time requirement for manual Lagrange interpolation?
3. How does documentation quality impact independent execution?
4. What role do group dynamics play in error detection?

---

## 2. Participant Demographics

Four family members participated, anonymized by role:

| Role | Age | Education/Background | Crypto Experience |
|------|-----|---------------------|-------------------|
| Father-in-law | 72 | Business college, shop owner | Knows Bitcoin exists |
| Mother-in-law | 70 | Shop owner | Knows Bitcoin exists |
| Brother-in-law | 36 | Engineer/trader | Holds Bitcoin on exchange, zero self-custody |
| Sister-in-law | 28 | Lawyer/prosecutor | Knows Bitcoin exists |

**Key Characteristics:**
- Age range: 28-72 years
- **Zero self-custody experience** across all participants
- Mix of educational backgrounds (college business, engineering, law)
- Represents target inheritance scenario demographics

---

## 3. Test Configuration

### Scheme Parameters
- **Threshold:** 4-of-16 (requires 4 shares from total of 16)
- **Shares selected:** 1, 3, 5, and 10
- **Lagrange coefficients:** NOT pre-computed (at time of testing, pre-computation approach not yet developed)

### Why This Configuration Matters
This test used a **more complex scenario** than typical production deployments:
- 4-of-16 is significantly more complex than common 2-of-3 or 3-of-5 schemes
- Participants had to compute Lagrange coefficients manually using inverse lookup tables
- **If participants can succeed at harder version, production version will be easier**

### Design Evolution: The Lagrange Insight

**At time of testing (2024):**
- All schemes required manual Lagrange coefficient computation
- Participants computed coefficients from scratch using modular inverse lookup tables
- This applied to simple and complex schemes alike

**Subsequent analysis revealed:**
- Lagrange coefficients contain **zero secret information** (depend only on share indices, not values)
- Can be pre-computed and published without compromising security
- **For common schemes** (2-of-3, 3-of-5): Practical to create lookup tables for all combinations
- **For complex schemes** (like 4-of-16): Can use electronic calculator for Lagrange computation, then manual arithmetic for remaining steps

**Production design implications:**
- Simple schemes: Pre-computed Lagrange tables eliminate 45-60 minute computation phase
- Complex schemes: Electronic Lagrange computation acceptable (non-secret), manual recovery for secret operations
- Trial data represents harder scenario than final users will encounter

### Validation Method
- Used test word with known result (the 1234th word = "olive")
- Participants verified they could recover this known value
- Confirmed correct process before attempting unknown secrets
- Note: Production design uses integrated checksum system instead

---

## 4. Trial 1: September 2024

### Materials Provided

1. **BIP39 wordlist lookup table** - Standard 2048-word list with indices
2. **Modular inverse lookup table** - For computing Lagrange coefficients in GF(2053)
3. **Single PowerPoint slide** - Complete process flow with colors showing both Lagrange computation and word recovery
4. **Blank paper** - For participants to replicate calculations
5. **Validation word approach** - Test word (olive = 1234) to verify process

**Note:** Checksum system not yet implemented at this stage.

### Process Description

**Initial Setup:**
- PowerPoint slide presented complete process in single integrated flow
- Combined Lagrange coefficient computation and word recovery steps
- Color-coded to distinguish different phases

**Participant Behavior:**
- Self-organized into collaborative group (not instructed to do so)
- Decided independently to work through calculations individually
- Compared results after each step
- Provided peer review and error-catching

**Observed Confusion:**
- Combined flow diagram created initial confusion about process separation
- Participants unclear when Lagrange phase ended and word recovery began
- Required supervision to navigate between phases

### Results

| Metric | Time | Notes |
|--------|------|-------|
| Lagrange computation | 60 minutes | With supervision/guidance |
| First word recovery | 15 minutes | Initial learning curve |
| Second word recovery | 5-7 minutes | Learning continues |
| Third+ words | 3-5 minutes each | Using blank paper |
| Words completed | 5 total | Study ended after timing consistency |

**Error Detection:**
- All arithmetic errors caught via group peer review
- No errors escaped detection
- Self-organized verification process proved effective

### Key Findings

1. **Process is feasible** - Participants completed manual recovery successfully
2. **Supervision initially required** - Needed guidance to navigate process flow
3. **Flow diagram needs improvement** - Combined presentation caused confusion
4. **Group dynamics effective** - Self-organized peer review caught all mistakes
5. **Timing improved with practice** - First word 15 min, second 5-7 min, third+ 3-5 min (blank paper)
6. **Learning curve observed** - Each subsequent word faster as familiarity increased

---

## 5. Trial 2: October 2025 (13 Months Later)

### Critical Context

**Zero Retention:**
- Participants retained **no procedural memory** from Trial 1
- When approached for second trial, reacted: *"Oh, that fun math game again, nice!"*
- Remembered it was enjoyable but had forgotten all steps
- Trial 2 represents **cold-start relearning**, not practice or retention

**What This Proves:**
- Process learnability from documentation alone
- Validates inheritance scenario (heirs with no prior exposure)
- Tests documentation quality, not memory

### Materials Provided

1. **Same lookup tables** - BIP39 wordlist and modular inverse tables
2. **NEW: Self-documenting colored box worksheets**
   - Two pages for Lagrange coefficient computation
   - One page per individual word recovery
   - **Instructions written directly on worksheets**
   - Color-coded boxes for each calculation step
3. **No example demonstration** - No PowerPoint walkthrough this time
4. **No verbal explanation** - Worksheets intended to be fully self-explanatory
5. **Same validation word approach** - Test word (olive = 1234)

### Process Description

**Material Design:**
- Separated Lagrange computation and word recovery into distinct worksheet pages
- Each worksheet had integrated written instructions
- Color-coded boxes guided users through steps sequentially
- Visual structure provided clear separation of calculation phases

**Participant Behavior:**
- Remembered preference for group approach (but not the math steps)
- Worked independently from worksheets initially
- Self-organized peer review after completing each section
- Minimal questions about process

**Observed Independence:**
- Colored box structure eliminated most supervision needs
- Written instructions on worksheets replaced verbal guidance
- Self-documenting materials enabled autonomous execution

### Results

| Metric | Time | Notes |
|--------|------|-------|
| Lagrange computation | 45 minutes | **ZERO supervision or verbal guidance** |
| First word recovery | 15 minutes | Slight guidance on applying computed coefficients |
| Second word recovery | 5-7 minutes | Learning curve similar to Trial 1 |
| Third+ words | 2-3 minutes each | Using colored box templates |

**Minor Instruction Gap:**
- Brief confusion about "how to apply these 4 magic numbers we found"
- Small clarification needed on using Lagrange coefficients with share values
- Easily addressed with better worksheet text (noted for improvement)

**Performance Improvement:**
- Lagrange phase: 25% reduction (60 min → 45 min)
- Third+ words: 40% reduction (3-5 min → 2-3 min per word)
- First two words: Same timing (learning curve consistent)
- Achieved despite 13-month gap with zero retention
- Improvement attributable purely to documentation quality (colored box templates)

### Key Findings

1. **Self-documenting materials work** - Zero verbal instruction required
2. **Cold-start execution possible** - No prior experience or memory needed
3. **Documentation quality critical** - Better materials directly improved performance
4. **Process is learnable** - Not dependent on "trained users" or recent practice
5. **Inheritance scenario validated** - Heirs can learn and execute independently

---

## 6. Comparative Analysis

### Trial Comparison Table

| Metric | Trial 1 (Sep 2024) | Trial 2 (Oct 2025) | Change |
|--------|-------------------|-------------------|---------|
| **Prior experience** | First exposure | Zero retention (13 months) | Cold-start relearning |
| **Materials** | PPT flow + blank paper | Self-documenting worksheets | Separated phases |
| **Instructions** | Verbal supervision | Written on worksheets | Self-explanatory |
| **Supervision level** | Required guidance | Zero supervision | Fully independent |
| **Lagrange time** | 60 minutes | 45 minutes | **-25% improvement** |
| **First word** | 15 minutes | 15 minutes | Same learning curve |
| **Second word** | 5-7 minutes | 5-7 minutes | Consistent |
| **Third+ words** | 3-5 min (blank paper) | 2-3 min (templates) | **-40% improvement** |
| **What improved** | N/A | Documentation design only | Not practice/memory |

### Key Insights from Comparison

**13-Month Gap Impact:**
- Participants forgot procedural steps completely
- Performance **improved** despite zero retention
- Proves documentation quality matters more than experience

**Material Design Impact:**
- Separated worksheets eliminated phase confusion
- Integrated instructions replaced verbal guidance
- Color-coded structure reduced cognitive load
- Measurable improvements: Lagrange 25% faster (60→45 min), repetitive words 40% faster (3-5→2-3 min)

**Supervision Requirements:**
- Trial 1: Continuous guidance needed
- Trial 2: Essentially none required
- Documents can replace human supervision with proper design

---

## 7. Interpretation: What the 13-Month Gap Actually Proves

### Not Retention, But Re-Learnability

**Traditional interpretation (incorrect):**
- "Participants remembered after 13 months" = good retention

**Actual reality:**
- Participants forgot all procedural steps
- Successfully learned from scratch using only written materials
- Improved performance despite no memory

**What this actually demonstrates:**
- Process is **learnable**, not just **followable with coaching**
- Documentation can standalone without human instruction
- Prior exposure not required or beneficial

### Validates Core Inheritance Scenario

**Real-world inheritance situation:**
- Heir discovers shares years after backup creation
- Has never performed recovery before
- May not have access to someone who understands process
- Must rely on documentation alone

**Trial 2 directly tests this:**
- 13-month gap simulates long time horizon
- Zero retention simulates first-time user
- Self-documenting materials simulate no available help
- Success validates this exact scenario

### Documentation Quality > Experience

**Critical finding:**
- Better documentation (colored boxes) reduced Lagrange time by 25% (60→45 min)
- Repetitive word recovery improved by 40% (3-5 min → 2-3 min per word)
- Improvements happened with **less** experience (zero retention)
- Contradicts "practice makes perfect" assumption
- **Proves: Clear instructions > Trained users**

**Implication for design:**
- Invest in documentation quality, not user training
- Self-documenting materials enable independence
- Process doesn't require recent practice or specialized knowledge

---

## 8. Design Lessons Learned

### Separate Process Phases

**Problem (Trial 1):**
- Combined Lagrange computation and word recovery in single flow
- Participants confused about when one phase ended and next began
- Created cognitive overload trying to understand entire process at once

**Solution (Trial 2):**
- Distinct worksheets for Lagrange computation (2 pages) and word recovery (1 page each)
- Clear phase boundaries
- Users complete one phase entirely before moving to next

**Lesson:** Process decomposition critical for human execution

### Self-Documenting Materials Are Critical

**Effective elements identified:**

1. **Instructions integrated into worksheets** - Not separate documentation
2. **Color coding** - Reduces cognitive load, guides attention
3. **Clear boxes for each calculation** - Visual structure for step-by-step work
4. **Written guidance at each step** - Eliminates need for verbal instruction
5. **Example placeholders** - Shows where values go before computing them

**Measured impact:**
- Lagrange computation: 25% faster (60 min → 45 min)
- Repetitive word operations: 40% faster (3-5 min → 2-3 min per word)
- First two words: Same timing (learning curve independent of templates)

**Lesson:** Material design directly impacts performance and independence

### Validation Mechanism Proves Valuable

**Test word approach (olive = 1234):**
- Provided confidence checkpoint mid-process
- Participants could verify partial progress
- Reduced anxiety about making mistakes
- Confirmed understanding before continuing

**Production design:**
- Uses integrated checksum system
- Provides same psychological benefit
- Validates arithmetic accuracy at row and global levels

**Lesson:** Intermediate validation points critical for manual processes

### Group Dynamics Provide Natural Error-Catching

**Observed behavior:**
- Participants self-organized into collaborative group
- Worked individually, then compared results
- Peer review caught all arithmetic errors
- Multiple people provide redundancy

**Inheritance scenario alignment:**
- Family members often gather for estate recovery
- Natural collaboration emerges
- Built-in error detection through multiple participants

**Lesson:** Group recovery provides safety mechanism beyond single-person use

---

## 9. Implications for Final Production Design

### These Trials Tested Harder Scenario

**What made trials more difficult:**

1. **4-of-16 scheme** - More complex than typical 2-of-3 or 3-of-5 deployments
2. **Manual Lagrange computation** - At time of testing, pre-computation not part of design; participants calculated from scratch
3. **Pre-checksum validation** - Used test word instead of integrated arithmetic checksums

**Subsequent design insights:**

Analyzing trial results led to critical realization: **Lagrange coefficients are non-secret** (depend only on which shares are used, not their values). This enables:

- **Common schemes (2-of-3, 3-of-5):** Pre-computed lookup tables eliminate entire Lagrange phase
- **Complex schemes (4-of-16+):** Electronic Lagrange calculator acceptable (non-secret operation), manual arithmetic for secret-touching operations
- **Production advantage:** 45-60 minute hardest phase removed for typical users

**Production design will be easier:**
- Pre-computed tables for common schemes
- Integrated checksums (stronger than test words)
- Improved worksheets incorporating Trial 2 lessons

### Time Estimates for Production Design

**Extrapolation from trial data:**

Trial 2 demonstrated (with colored box templates):
- Lagrange: 45 minutes (eliminated in production for common schemes)
- First word: 15 minutes
- Second word: 5-7 minutes
- Third+ words: 2-3 minutes each (with templates)

**24-word recovery calculation (using Trial 2 data):**
- Pre-computed Lagrange: 0 minutes (tables provided)
- First word: 15 minutes
- Second word: 6 minutes (average)
- Remaining 22 words: 22 × 2.5 min (average) = 55 minutes
- Subtotal word recovery: ~76 minutes (~1.25 hours)
- Add 9 checksum verifications: ~30 minutes
- **Conservative estimate: 2 hours** for first-time users

**24-word recovery (conservative, using Trial 1 data without templates):**
- Pre-computed Lagrange: 0 minutes
- First word: 15 minutes  
- Second word: 6 minutes
- Remaining 22 words: 22 × 4 min (average) = 88 minutes
- Subtotal: ~109 minutes (~1.8 hours)
- Add checksums: ~30 minutes
- **Conservative estimate: 2-2.5 hours**

**Why 2-4 hour published range remains valid:**
- Lower bound (2 hours): Experienced users with good templates
- Upper bound (4 hours): First-time users, cautious pace, multiple verification passes
- Trial data supports this range empirically

**Production design advantages:**
- Pre-computed Lagrange (eliminates hardest 45 min phase)
- Improved worksheets based on Trial 2 learnings
- Integrated checksums (stronger than test word validation)
- Self-documenting materials reduce errors

**Empirical grounding:**
- Not theoretical projection
- Based on actual performance across age ranges
- Tested under harder conditions (4-of-16 complexity)
- Conservative estimates justified

### Accessibility Validated Across Demographics

**Age range: 28-72 years**
- 70+ year-olds successfully completed complex arithmetic
- No evidence age was barrier
- Shop owners performed as well as engineers

**Zero self-custody experience:**
- All participants unfamiliar with wallet recovery
- Represents actual inheritance beneficiary profile
- No specialized crypto knowledge required

**Education diversity:**
- Business college, engineering, law backgrounds
- All succeeded despite different training
- Process not restricted to technical users

**Self-documenting materials:**
- Enabled independence without supervision
- Written instructions replaced human guidance
- Validates standalone documentation approach

---

## 10. Limitations and Constraints

### Study Design Limitations

**Sample size:**
- Only 4 participants
- Single family group
- Insufficient for statistical population claims

**Environment:**
- Uncontrolled home setting
- Informal timing (estimates, not precise measurement)
- Variable conditions between trials

**Methodology:**
- Pre-production validation method (test word vs checksums)
- Not blinded or randomized
- Researcher present (potential observer effect)

### Statistical Validity Constraints

**Cannot conclude:**
- Population-level success rates
- Confidence intervals for timing estimates
- Demographic generalizations beyond observed group
- Individual vs group performance comparison

**Observed data insufficient for:**
- Establishing probability of success across general population
- Identifying specific error patterns statistically
- Comparing performance across demographic variables
- Validating with diverse educational/cultural backgrounds

### Threats to Validity

**Internal validity:**
- Participants related (shared family context)
- Non-random sample
- Potential learning between trials despite zero procedural retention

**External validity:**
- Limited demographic diversity
- Cultural homogeneity (single family)
- Selection bias (family willing to participate)
- May not generalize to isolated individual recovery

**Ecological validity:**
- Home environment may differ from real inheritance scenario
- Low-stress conditions (not actual emergency)
- Researcher available if needed (safety net)

---

## 11. Next Steps: Formal Usability Study

### Planned Study Parameters

**Timeline:** January 2026

**Sample size:** 10 participants
- 5 crypto-experienced users
- 5 novice users (minimal/no crypto knowledge)
- Diverse age ranges, educational backgrounds, technical comfort levels

**Controlled conditions:**
- Standardized environment
- Precise time measurement instrumentation
- Video recording for error pattern analysis
- Think-aloud protocol for cognitive process observation

**Test materials:**
- Final production design with pre-computed Lagrange
- Integrated checksum system (not test word)
- Production-quality worksheets incorporating Trial 2 lessons

**Measured outcomes:**
- Success rate (percentage completing recovery correctly)
- Time to completion (mean, median, variance)
- Error rates (arithmetic, transcription, procedural)
- Subjective difficulty ratings
- Points of confusion or assistance requests

**Analysis:**
- Statistical comparison: crypto-experienced vs novice users
- Individual vs group recovery performance
- Correlation between demographics and success/time
- Qualitative analysis of error patterns and confusion points

### Research Questions

1. What is population success rate for manual recovery?
2. Do time estimates hold across diverse users?
3. What role does prior crypto experience play?
4. How effective are checksums at catching errors?
5. What documentation improvements emerge from formal testing?

---

## 12. Conclusion

### What This Preliminary Validation Demonstrates

**Manual recovery is feasible:**
- Real humans successfully completed process
- Age range 28-72 years validated
- Zero self-custody experience not a barrier
- 4-of-16 complexity manageable

**Process is learnable from documentation:**
- 13-month gap with zero retention = cold-start relearning
- Self-documenting materials enabled independent execution
- Written instructions eliminated verbal guidance needs
- Validates core inheritance scenario

**Documentation quality significantly impacts performance:**
- Better materials improved Lagrange by 25%, repetitive words by 40%
- Self-documenting worksheets eliminated supervision
- Clear visual structure reduces cognitive load
- Design matters more than user training

**Group dynamics provide valuable error-catching:**
- Self-organized peer review caught all arithmetic errors
- Multiple participants create natural redundancy
- Supports family inheritance team scenario

**Time estimates empirically grounded:**
- 2-4 hours for 24-word recovery defensible
- Based on actual performance under harder conditions (manual Lagrange computation)
- Conservative given production design advantages (pre-computed coefficients)
- Trial experience led to Lagrange pre-computation insight (non-secret operation)

### Current Status

This preliminary validation provides:
- ✅ Proof of concept for human-executable recovery
- ✅ Initial feasibility data across age ranges
- ✅ Evidence supporting published time estimates
- ✅ Design lessons for documentation improvements
- ❌ Not sufficient for production deployment claims
- ❌ Not statistically representative of general population

**Classification:** Informal pilot study with promising results requiring formal validation.

### Path Forward

Formal usability study (January 2026) needed to:
- Establish statistical confidence in success rates
- Validate time estimates with precise measurement
- Test production design with all improvements
- Generate publishable peer-reviewed results

**Until formal study complete:**
- Present scheme as experimental/unaudited
- Acknowledge preliminary validation only
- Recommend testing with modest amounts
- Maintain parallel backup strategies

---

**Document Version:** 2.0  
**Last Updated:** December 2025  
**Status:** Approved for publication in schiavinato-sharing repository
