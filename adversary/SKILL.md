---
name: adversary
description: Use when a conclusion needs a strong opponent before you act on it — a diagnosis, root cause, plan, design, estimate, or recommendation. Dispatches a subagent whose job is to refute you, then iterates with it until you converge or can name exactly what you disagree about.
---

# Adversary

Dispatch a subagent to **destroy your conclusion**, then argue with it until you both converge on
the same result.

## Process

**1. Write your claims to a file.** Numbered, each falsifiable, each with the raw evidence behind
it — actual numbers, output, quotes, file:line. Not your summary of the evidence; an adversary that
only sees your interpretation can only check your arithmetic.

Put it in a scratchpad and pass the path. Do **not** inline it into the dispatch — the file holds
the detail so the prompt stays short, and short prompts get followed.

Then rank the claims by how much the answer changes if they're wrong. The top one is what the
adversary attacks first.

**2. Dispatch** with the Agent tool, `run_in_background: true`, a `name` so you can `SendMessage`
it, and a strong model. Everything after this flows over SendMessage in both directions — the
dispatch is the opening move of a dialogue, not a job submission. You should get an ACK back within
a minute or so; if you don't, the prompt below lost its reply instructions and nothing you wait for
will ever arrive.

Copy this prompt and fill every `{{slot}}`:

```
You are a SUPER-STRICT adversarial teammate. Your only goal is to BREAK the claims
below — do not confirm them to be agreeable. Assume the author is wrong until the
data forces otherwise. Verify everything independently: re-run the queries, read the
code, check the files. Do not trust my numbers.

CLAIMS TO BREAK: {{path to the file from step 1}}

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

HOW TO REPLY: you run in the background, so your plain text output reaches nobody —
everything you want me to see MUST go through SendMessage to `main`. SendMessage is
a deferred tool: run ToolSearch("select:SendMessage") first to load its schema.

Send me a one-line ACK right now, before you start investigating, confirming you can
reach me and have the claims file. Send the report the same way when it is ready.

Then stay available. This is a conversation, not a drop: I will come back with new
evidence, corrections to premises I gave you, and counter-arguments, and we keep
trading until we land on one state we both hold — the theory survives, or it moves,
or we can both name the experiment that would settle what is left. Never end a turn
without sending something; silence is indistinguishable from failure on my side.
```

**3. Iterate — this is the part that works.** The first report isn't final, and one exchange is not
the skill. Expect several rounds over SendMessage: you send new evidence, Corrections flow both ways — when
it reasons from a premise you gave it that turned out false, send the correction rather than quietly
discounting its conclusion.

Keep going until you both hold the same state.

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

**It goes quiet.** Message it and ask for the report — it may have finished the thinking and skipped
the sending. If your ask repeats "your final message is the report", it will fail the same way
twice; tell it explicitly to reply with SendMessage to `main`.

**You go read its transcript.** Don't. Scraping the session log is not a recovery path — it ends the
dialogue the skill is built on and leaves you holding a snapshot you cannot argue with, cannot
correct, and cannot ask a follow-up of. Silence means the reply channel is broken: fix it in the
prompt and re-dispatch. The only thing worth reading off disk is a post-mortem after the work is
done.

**No ACK.** If the opening acknowledgement never arrives, stop waiting immediately — the agent
cannot reach you, and every minute after that is spent on a report you will never receive.

**You defend instead of updating.** If it's right, say so and move on. The point is to be wrong in
private rather than in public.
