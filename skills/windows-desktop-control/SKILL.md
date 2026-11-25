---
name: windows-desktop-control
description: >-
  Control the Windows desktop (screen capture, mouse, keyboard, windows, and
  native apps) using the windows-mcp MCP server. Use this skill whenever the
  user asks to see their screen, click or type in Windows desktop applications,
  switch or resize windows, automate native Windows UI workflows, or take
  control of the PC screen. Do NOT use for ordinary web-only tasks that the
  built-in browser subagent handles better, or for pure file/terminal work.
---

# Windows Desktop Control (`windows-mcp`)

This skill defines the safe, reliable workflow for controlling the user's
Windows desktop through the `windows-mcp` MCP server.

## Core Observe → Act → Verify Loop

Never click or type blindly. Always follow this loop:

1. **Observe first**: Call `Snapshot` (with `use_vision=True` when visual layout
   matters) to inspect active windows, UI element labels/IDs, and coordinates.
   * For multi-monitor setups, call `DisplayInventory` once to identify display
     indices and pass `display=[0]` (or `[0, 1]`) to `Snapshot`.
   * For fast visual checks without needing UI element IDs, use `Screenshot`.
2. **Act precisely**:
   * Prefer targeting UI elements by their **label/ID** from `Snapshot` rather
     than raw `[x, y]` coordinates whenever available.
   * Use `App` (`launch`, `launch_executable`, `switch`, `resize`) to open or
     focus applications instead of clicking through the Start menu.
   * Use `Shortcut` (e.g. `ctrl+c`, `ctrl+s`, `alt+tab`) for standard actions.
   * Use `Type` (`clear=True` to replace text, `press_enter=True` to submit)
     and `Click` (`left`, `right`, `middle`; `clicks=1` or `2`).
   * Use `MultiEdit` or `MultiSelect` to batch multiple fields/items in one call.
3. **Wait smartly**: Use `WaitFor` (`text_exists`, `active_window`,
   `element_exists`, `element_enabled`, `focused_element`) instead of blind
   polling loops or long `Wait` sleeps.
4. **Verify**: Re-run `Snapshot` or `Screenshot` after critical actions to
   confirm the expected UI state before proceeding.

## Safety & Guardrails

* **Ask before destructive or irreversible actions**: Confirm with the user
  before deleting files, modifying Windows Registry keys (`Registry`), killing
  unfamiliar processes (`Process`), sending messages/emails, submitting
  payments, or changing system security settings.
* **Respect sensitive screens**: Pause and hand control back to the user on
  login prompts, 2FA/MFA dialogs, password managers, banking/payment flows, or
  CAPTCHAs.
* **Prefer native tools over GUI clicking**: When a task can be done cleanly via
  the workspace file/terminal tools or built-in browser subagent, prefer those
  over GUI automation. Use `windows-mcp` specifically for native Windows UI and
  on-screen desktop control.
* **NovaBrowser profiles go through their own skill**: when the task targets a
  website inside a NovaBrowser profile (an isolated account with its own proxy
  and fingerprint), use the `novabrowser-browser-control` skill and its
  `novabrowser` MCP server instead of clicking the browser window: it drives
  the profile in the background, without taking the user's mouse or keyboard.
* **Multi-step focus recovery**: If a click or keystroke lands in the wrong
  window, immediately call `App(mode="switch", ...)` or `Snapshot` to re-sync.

## Tool Reference

For the full list of `windows-mcp` tools, modes, and options, read
[references/tools.md](./references/tools.md).
