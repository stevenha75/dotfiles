---
name: audit-corrections
description: Use when the user asks to audit their agent history, find the mistakes agents keep making, or turn past corrections into checks, skill edits, or AGENTS.md rules.
---

# Audit corrections

Find where agents went wrong in the user's own sessions, and propose the
change that stops each repeat at the strongest rung that will hold it.

Read session history on this machine: Claude Code transcripts under
`~/.claude/projects/`, and Codex sessions under both `~/.codex/sessions/` and
`~/.codex/archived_sessions/`. Keep messages from the window the user names,
or the last 30 days, by message timestamp. Stay inside any models or repos
they name.

Count only messages the user typed. Tool results and parent-agent prompts are
also stored as user messages; skip them.

A correction is a user message that pushes back on the agent's last turn:
"no", "that's wrong", "why did you...", "stop", "you missed...". A repeated
request or a bare status ping like "did you push?" counts only when the turn
before it shows the agent stopped short or missed the request. Pull the
message, the agent turn before it, the model, and the harness.

Sort each correction into one failure mode. Start from these and add one only
when several corrections fit none of them:

- WRONG-IMPL: main path shipped, adjacent surface missed
- TASTE: works, looks wrong
- PROCESS: stale branch, red CI, bad PR body
- MISREAD: right build, wrong object
- TOOL-MISUSE: broke the machine (killed processes, deleted state)
- OVERBUILD: bigger than the problem needed
- STOPPED-EARLY: handed back before the job was done
- NO-VERIFY: asserted something it never checked
- REGRESSION: broke something that worked
- UNASKED-EDIT: changed files when asked a question

For lots of history, split it across subagents by harness or date range, and
give each one the same taxonomy. Count tool-call facts (kill commands, draft
PRs) from the transcripts directly instead of from classifier judgment.

## Reflect

Before proposing anything, route each repeat issue to the file or check that
already owns that behavior. Prefer editing that home over adding a new one.
Check whether earlier fixes held: compare this window's rate for each mode
against the window before the fix landed. A fix that didn't move its rate
climbs a rung.

## Rungs

Fix each repeat at the strongest rung that will hold it:

1. Types, CI, or hooks. Anything a machine can check: a type, a CI step, a
   hook in `~/.agents/hooks/`. Name the exact check and where it runs.
2. Skill. A bad/good example pair taken from the real transcript, plus a stop
   point ("stop and ask before X"). Only if the prose rules from ENG-4 and
   dotfiles#22 didn't move their rates.
3. `~/.agents/AGENTS.md` prose, in the file's existing voice.

When a rung-1 check now enforces a rule, propose deleting its prose.

## Conditional checks

Run each only if its trigger has fired:

- flavigula CI `verify.yaml`: only if ENG-2 has landed. Count repeats it
  should have caught.
- `#eng-alerts` auto-repro: only if `#eng-alerts` posted in the window. Try to
  reproduce each alert and count a confirmed agent-caused one as a correction.
- Skill evals: only if a core skill drifted (repeats tied to a skill that was
  followed as written). Propose an eval case from the transcript.
- Antigravity and Neon transcripts: only if Neon has meaningful volume. Add
  them to the sources above.

## Report

Report as one HTML page:

1. A table of corrections per 100 user messages, failure mode by model. Bold
   the model that owns each mode. Say which counts are directional.
2. One proposal per repeat issue: its rung, the exact check, skill example,
   or rule text, and a "Why" line that quotes the real corrections behind it.
   Skip any failure already prevented unless the data shows the fix isn't
   holding.

Do not edit any instruction file. Report the page URL and stop. The user
picks which changes to apply.
