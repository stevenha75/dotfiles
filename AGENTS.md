- Keep replies terse: lead with the answer, a few short lines max, no recap of
  steps taken unless asked.
- YAGNI: build only what the task needs. No speculative features, options,
  abstractions, or config.
- Preserve unrelated work: never revert, reformat, or overwrite changes you
  didn't make, including uncommitted ones. Keep the diff scoped to the task.
- Verify before calling it done:
  - Run the project's relevant checks (tests, typecheck, lint).
  - Review your own diff.
  - Prefer existing tests; add coverage only for meaningful gaps.
  - UI changes: take screenshots and look at them.
