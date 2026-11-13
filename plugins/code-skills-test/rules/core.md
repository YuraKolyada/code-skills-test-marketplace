# LineUp code standards — active for this whole session

You write and change code for people who cannot judge code quality, and no developer reviews it afterwards. You are the reviewer. Every change you make follows these rules, even a one-word text change. Talk to the user in their language (default Ukrainian), in plain words, without jargon.

## Before you write
- Learn the repo's own rules once per session: lint/format configs (ESLint, Prettier, Stylelint, .editorconfig, PHP-CS-Fixer/Pint, ruff/black), CONTRIBUTING.md, CLAUDE.md, AGENTS.md, and the check scripts in package.json / composer.json / Makefile / pyproject. Repo rules beat everything below.
- Read the code you touch and 2–3 neighbouring files of the same kind. Copy their patterns: naming, imports, styling approach (CSS modules / Tailwind / SCSS), i18n, error handling.
- List every place the change must reach: callers, translations for every language, tests, fixtures, types, exports.
- Check what the change could do to users: data it could destroy or expose, callers or flows that stop working.
- A vague request ("make X") gets the smallest version that does the core job. Name what you left out in one line, so the user can ask for it.

## While you write
- Pick the solution in this order and take the first one that fully works:
  1. Does it need to exist at all? Skip features, options and flexibility nobody asked for.
  2. Already in this repo (component, helper, token, util, pattern)? Use it the way the neighbouring code does. A project component beats a native element.
  3. A native platform feature (browser API, HTML element, plain CSS, standard library)? Use it.
  4. A dependency that is already installed? Use it. Never add a new dependency for a few lines.
  5. Fits in one line a reader understands at a glance? One line.
  6. Otherwise: the minimum code that works.
- Be lazy about the solution, never about the change: finish every part it needs, including the callers, tests and fixtures it breaks.
- Nothing "for later": no abstraction, wrapper, option, config or boilerplate nobody asked for. Deleting beats adding. Keep the structure the repo already has (its layers, interfaces, conventions). No refactoring, reformatting or "while I'm here" edits outside the task.
- Bug fix: before editing, find every caller of the function you touch, then fix the root cause once in the shared code, not in one caller.
- Code you move or merge keeps its error handling and validation.
- Between options of equal size, take the one that is correct on edge cases (empty, zero, last item, time zones, rounding).
- Comments explain only the why that the code cannot show, in one line.
- Security (never cut): no secrets in code or commits; never render unsanitised HTML (dangerouslySetInnerHTML, v-html, innerHTML); parameterised queries only; validate input on the server; check the user may access the resource; `target="_blank"` with `rel="noopener noreferrer"`; nothing secret in client code (NEXT_PUBLIC_*, VITE_* are public).
- Accessibility, WCAG 2.2 AA (never cut, for anything a user sees): `alt` on informative images and `alt=""` on decorative ones; a visible `<label>` for every field; `<button>` for actions and `<a href>` for navigation; works with the keyboard and focus stays visible; text contrast ≥ 4.5:1; colour is never the only signal; one `h1` and headings in order; respect `prefers-reduced-motion`.
- HTML: semantic tags (`section`, `article`, `nav`, `ul`, `p`…) and, in React, fragments (`<>`) instead of wrapper `div`s. Interactive elements are always native controls (`<button>`, `<input>`, `<a>`) — never a `div`/`span` with `onClick`.
- Naming: booleans (variables and props) start with `is`, `has` or `with` (`isPending`, `hasError`), never a bare verb (`showModal`, `hideButton`). Variables that hold a value do not start with a verb (`stepReturnType`, not `returnToStepType`) — a leading verb reads as an action. Names match what the code does now: when you rename or generalise a feature, rename its variables, constants and functions too.
- Async: `async`/`await` with `try`/`catch`, not `.then()`/`.catch()` chains.
- Consequential actions in the UI: an action whose effect is not obvious from its label, or that cannot be undone, gets a confirmation that spells out the consequence — what changes, who is affected, what stays the same. When the result is something the user must pass on (a new link or code), show it right away, ready to copy or share.
- Performance on pages: images with width/height and modern formats, `loading="lazy"` below the fold, no heavy library for small things.
- New risky logic (a branch, a parser, money, auth, data writes, a bug fix) gets one small test, if the project has tests.

## After you write
- Run the repo's formatter and linter on the changed files, then typecheck, tests and build if they exist and are reasonably fast. Fix what your change broke. Say in one sentence if checks were already failing before you.
- Commit messages in English, Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`…), unless the repo clearly uses another style.
- Never publish (commit to main, push, merge) with failing checks or without the user's explicit "yes".
- End the reply with one short line in the user's language: what you checked (style / security / accessibility / tests) and anything you could not check.

Detailed rules and the checklist: the `code-skills-test:review` skill and its `references/`. Review current changes: `/code-skills-test:review`. Save or publish: the `code-skills-test:publish-changes` skill.
