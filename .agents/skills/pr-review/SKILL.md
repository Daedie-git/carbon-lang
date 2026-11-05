---
name: pr-review
description:
    Review a Carbon PR or branch before it goes upstream, checking for a
    self-contained description, minimal tests, and the project's contribution
    guidelines. Use when asked to review a PR or branch, or before offering one
    upstream.
---

# PR review

<!--
Part of the Carbon Language project, under the Apache License v2.0 with LLVM
Exceptions. See /LICENSE for license information.
SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
-->

This skill exists on our fork only. Judge the PR as a maintainer seeing it for
the first time, with only `carbon-language/carbon-lang` to go on. Report
findings to the operator; post nothing. The operator files anything upstream,
because the `github_cli` skill keeps agents read-only there.

## Steps

1.  **Collect the change.** Fetch the title, body, comments, commits and diff:

    ```bash
    gh pr view <n> -R <repo> --json title,body,comments,commits
    gh pr diff <n> -R <repo>
    ```

    For a branch without a PR, use its commit messages and
    `git diff origin/trunk...<branch>`.

2.  **Read the guidelines fresh**, since they change: `CONTRIBUTING.md`,
    `docs/project/code_review.md`, `docs/project/pull_request_workflow.md`,
    `AGENTS.md`, `.github/pull_request_template.md`, and every skill in
    `.agents/skills/` that covers the changed paths.

3.  **Apply every check below.** Done when each has a verdict with evidence and
    every added test is accounted for.

4.  **Report** one line per check (pass or fail), then failures ranked by what
    would cost the most reviewer trust. Quote the offending text and give the
    fix. End with whether it is ready for upstream.

## Checks

### Self-contained

Every reference in the title, body, commit messages and comments resolves for a
maintainer with no access to us. Fail on:

-   Fork PRs and issues, review repositories, and `#N` numbers that mean
    anything other than an upstream number.
-   Local paths, machines, sandboxes, agent sessions and scratch files.
-   Downstream projects, earlier review rounds, and what the operator asked for.
-   Validation only we can repeat. A claim belongs in the PR as a reproducer or
    a test.

### Description

-   The title is an imperative summary of the change, with no labels.
-   The body opens with the problem as a user meets it: the smallest example and
    the actual error.
-   It gives the cause, why this approach is the right one, and the existing
    pattern it follows.
-   It names every behaviour change the diff makes, plus tradeoffs and rejected
    alternatives. Read the production diff and list its behaviour changes before
    comparing them with the description.
-   It reads as a merge commit message a year from now, because it becomes one.
    Fail on test inventories, CI narration and file-by-file summaries.
-   It links its issue with `Closes #N` where one exists.

### Scope

-   The PR does one thing and is as small as it can be while self-contained.
-   The branch descends from `origin/trunk` and the diff holds only this change:
    fail on this skill, other fork-only files, and scratch output.
-   For a first-time contributor, the change was discussed first or is obviously
    good from the title and a glance at the diff.

### Minimal tests

For each added test or split, name the distinct behaviour it pins and whether it
goes red without the change. Run this when the build allows, and say which
verdicts were run rather than inferred. Fail on:

-   Cases that repeat a code path another case covers.
-   Cases that restate Clang, LLVM or other library behaviour.
-   Cases that helped development but protect nothing the PR promises.
-   SemIR dumped beyond the logic under test.

Judge changed `CHECK` output with the `review_testdata_changes` skill.

### Project guidelines

Apply each rule from step 2 that bears on this PR, including:

-   The tooling used is disclosed, with AI tools in `Assisted-by:` trailers.
    `Co-authored-by:` names only people who have signed the CLA.
-   The value outweighs the review cost, per the "extractive" rule in
    `CONTRIBUTING.md`.
-   History of a submitted PR stays unrewritten.
-   Comments and test code follow `toolchain_tests` and `code_style`.
