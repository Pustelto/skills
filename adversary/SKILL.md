---
name: adversary
description: Use when a conclusion needs a strong opponent before you act on it — a diagnosis, root cause, plan, design, estimate, or recommendation. Dispatches a subagent whose job is to refute you, then iterates with it until you converge or can name exactly what you disagree about.
---

# Adversary

Dispatch a subagent to **destroy your conclusion**, then argue with it until you both converge on
the same result.

A reviewer asks "is this good?" An adversary asks "how is this wrong?" That difference is the
whole skill. The value comes from the adversary being free to say you are wrong and _required to
try_.

Use it wherever a wrong answer is expensive: hard debugging, root-cause analysis, architecture and
design choices, plans, estimates, build-vs-buy, any decision you'd regret discovering late. Skip it
for mechanical work or anything with a cheap oracle — if a test can answer it, run the test.

Strongest signal you need it: **you notice you want your theory to be right.**

## Process

**1. Write your claims to a file.** Numbered, each falsifiable, each with the raw evidence behind
it — actual numbers, output, quotes, file:line. Not your summary of the evidence; an adversary that
only sees your interpretation can only check your arithmetic.

Put it in a scratchpad and pass the path. Do **not** inline it into the dispatch — the file holds
the detail so the prompt stays short, and short prompts get followed.

Then rank the claims by how much the answer changes if they're wrong. The top one is what the
adversary attacks first.

**2. Dispatch** with the Agent tool, `run_in_background: true`, a `name` so you can `SendMessage`
it, and a strong model. Copy this prompt and fill every `{{slot}}`:

```
You are a SUPER-STRICT adversarial auditor. Your only goal is to BREAK the claims
below — do not confirm them to be agreeable. Assume the author is wrong until the
data forces otherwise. Verify everything independently: re-run the queries, read the
code, check the files. Do not trust my numbers.

CLAIMS TO BREAK: {{path to the file from step 1}}

ATTACK {{claim}} FIRST — it is load-bearing, and if it falls the recommendation
changes. {{why I already doubt it}}

Then, in this order: {{remaining weak points, ranked}}

HOW TO INVESTIGATE INDEPENDENTLY:
{{tools, access, credentials pattern, repo paths, working commands to copy}}

LIMITS: {{what is shared, what breaks if you are careless, what is off-limits}}
Do not modify any files. Do not commit or push.

For EACH claim return REFUTED / UNSUPPORTED / SURVIVES, with the single strongest
piece of evidence — what you RAN and what it RETURNED, quoted. Reasoning alone is not
evidence. UNSUPPORTED means "your evidence does not establish this", which is not the
same as "wrong" — keep those buckets separate.

Then:
- COMPETING EXPLANATIONS, ranked, including any I have not considered
- MY STRONGEST ARGUMENT, tested specifically rather than accepted
- EXPERIMENTS that would settle what is left; flag which ones need the human
- WHICH CONCLUSIONS MUST CHANGE, and the single most important thing still unverified

Do not rubber-stamp, and do not invent flaws to look useful. If you cannot break a
claim, say "could not falsify" and give the strongest independent corroboration you
found. If the data cannot settle something either way, say so explicitly and say what
would settle it.

Your final message IS the report — it is the deliverable, not a conversational reply.
```

**3. Iterate — this is the part that works.** The first report isn't final. Feed it new evidence
and let it re-rank. Corrections flow both ways: when it reasons from a premise you gave it that
turned out false, send the correction rather than quietly discounting its conclusion.

Stop when you genuinely agree, or when you can state precisely what you disagree about and which
experiment settles it. Both are good endings. Agreement reached by the adversary giving up is not.

**4. Report honestly.** If it refuted your headline claim, lead with that. Separate what's
established from what's inferred, and carry UNSUPPORTED items forward as open questions instead of
dropping them.

## Failure modes

**It agrees with you.** Your prompt leaked your confidence, or it lacked the access to gather
independent evidence. Re-dispatch with the evidence and without the conclusion.

**It invents flaws to look useful.** The mirror image, and likelier the harder you push. This is
why the prompt forbids both rubber-stamping and manufacturing — an adversary told only to attack
will find something whether or not it's there.

**It's confidently wrong.** It's a peer, not an oracle. Verify its central claim yourself before
acting. Expect both sides to be wrong about something.

**It goes quiet.** Ask it directly for the report rather than assuming it failed — it may have
finished the thinking and skipped the sending.

**You defend instead of updating.** If it's right, say so and move on. The point is to be wrong in
private rather than in public.

## What good looks like

Neither party is fully right at the end. You went in with a plausible theory, the adversary killed
part of it, you corrected part of its reasoning, and the conclusion that survived is one neither of
you started with — and you can say precisely which parts are proven, which are inferred, and which
are still open.
