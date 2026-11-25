---
name: github-stacks
description: Use when the user mentions a stack, stacked PRs, `gh stack`, or dependent PRs, or when work needs more than one PR that builds on another.
---

# GitHub Stacks

A stack is a chain of PRs where each PR targets the branch below it, so each
shows only its own layer. GitHub merges the whole stack in one step, so you
never merge, rebase and wait for CI once per PR. Use the `gh stack` CLI. Your
training data probably predates it, so trust this skill and
`gh stack <command> --help` over memory.

## When to stack

- Stack when the work splits into layers that depend on each other and are
  each worth reviewing alone, like schema, then API, then UI.
- Open one PR when the change is small enough to review in one sitting, or
  the parts can't stand alone.
- Open separate PRs off `main` when the parts are independent. Stacks are
  linear: one parent and at most one child per layer.

Decide before writing code. Build each layer on its own branch, bottom first.
Don't build everything on one branch and split it up later.

## Setup

```sh
gh extension install github/gh-stack
git config rerere.enabled true         # else `init` may prompt for it
git config remote.pushDefault origin   # needed when the repo has 2+ remotes
```

Exit code 9 means stacks are off for this repo. Fall back to one PR and tell
the user.

`gh stack` opens prompts and full-screen UIs when stdout is a terminal, so run
it from a non-TTY shell and always pass arguments. Never run `modify`,
`switch`, or a bare `init`, `add`, `checkout`, `view` or `submit`.

## Create

```sh
gh stack init <bottom-branch>
# commit the bottom layer
gh stack add <next-branch>
# commit the next layer; repeat
gh stack submit --auto --open   # push, open real PRs, link them as a stack
gh stack view --json            # branches, PR numbers, needsRebase
```

`--auto` alone opens drafts, so keep `--open`. Then fix each PR's
auto-generated title and description with `gh pr edit`, following `file-pr`.

## Feedback on a lower PR

Make the fix on the layer that owns it, never on the top branch:

```sh
gh stack checkout <branch>      # or: gh stack down
# commit the fix
gh stack rebase --upstack       # replay every layer above onto the fix
gh stack push                   # force-with-lease, all branches at once
gh stack top
```

Pushing a lower layer rewrites every layer above it, so all of their checks
rerun. Batch the feedback for a layer into one push.

On a rebase conflict (exit 3), resolve the files, `git add` them, and run
`gh stack rebase --continue`, or `--abort` to restore the stack.

## Keep it current

Each PR is a normal PR for review and CI. Checks and branch rules run as if it
targets `main`. When `main` moves, run `gh stack sync`: it fetches, rebases the
stack, and pushes. If it reports a conflict, it has already restored the
stack. Run `gh stack rebase` and resolve as above.

## Merge

Merge the top PR to land it and every PR below it at once. Merge a lower PR to
land only it and the PRs below; GitHub rebases the rest. Every PR being merged
must pass its own merge gate. `gh pr merge` and the old merge APIs fail on
stacked PRs, and there is no auto-merge or rule bypass.

Merge through the async merge API, pinned to the head you verified. A changed
head fails with "Pull request head branch was modified."

```sh
gh api -X PUT repos/<owner>/<repo>/pulls/<pr>/merge-async \
  -f merge_method=<repo's method> -f sha=<pr-head-sha>
gh api repos/<owner>/<repo>/pulls/<pr>/merge-async/<uuid>   # poll until not pending
```

With a merge queue, drop `merge_method`: the queue picks it, and the result is
`enqueued`, so wait until the PRs show merged. `gh stack merge --yes` from a stack branch also lands the whole
stack, unpinned. Then run `gh stack sync --prune` to delete the merged local
branches.

For anything else, read `gh stack <command> --help` or the
[gh-stack docs](https://github.com/github/gh-stack/tree/main/docs/src/content/docs).
