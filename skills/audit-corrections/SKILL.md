---
name: audit-corrections
description: Use when the user asks to audit their agent history, find the mistakes agents keep making, or turn past corrections into AGENTS.md rules.
---

# Audit corrections

Find where agents went wrong in the user's own sessions, and propose
instruction changes that steer away from those mistakes.

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

Report as one HTML page:

1. A table of corrections per 100 user messages, failure mode by model. Bold
   the model that owns each mode. Say which counts are directional.
2. Proposed edits to `~/.agents/AGENTS.md`. For each edit, give the exact
   rule text in the file's existing voice, and a "Why" line that quotes the
   real corrections behind it. Prefer editing an existing section over adding
   a new one. Skip any failure the file already prevents unless the data shows
   the rule isn't holding.

Do not edit any instruction file. Report the page URL and stop. The user
picks which edits to apply.
