# `windows-mcp` Tool Reference

Quick reference of tools exposed by `windows-mcp` (v0.8.x).

## Observation & Waiting

| Tool | Purpose | Key Options |
| :--- | :--- | :--- |
| `Snapshot` | Capture desktop state, open windows, interactive UI tree with element labels/IDs, and optional annotated screenshot. | `use_vision=True`, `use_annotation=True/False`, `use_ui_tree=True/False`, `use_dom=True` (browser DOM), `display=[0]` |
| `Screenshot` | Fast screenshot-only capture with cursor position and window summary (skips UI tree extraction). | Scales image for speed; use `Snapshot` for exact interactive labels. |
| `DisplayInventory` | Inspect connected monitors, resolution, work area, DPI, and scale factor. | Useful before targeting secondary monitors. |
| `WaitFor` | Poll the Windows UIA tree until a condition holds. | `text_exists`, `active_window`, `element_exists`, `element_enabled`, `focused_element`, `use_dom=True` |
| `Wait` | Pause for a fixed number of seconds. | Use sparingly for animations; prefer `WaitFor`. |

## Mouse & Keyboard

| Tool | Purpose | Key Options |
| :--- | :--- | :--- |
| `Click` | Click or hover at `[x, y]` or UI element `label`. | `button`: `left` / `right` / `middle`; `clicks`: `0` (hover), `1` (single), `2` (double) |
| `Type` | Type text at `[x, y]` or UI element `label`. | `clear=True/False`, `press_enter=True/False`, `caret_position`: `start` / `end` / `idle` |
| `Shortcut` | Send keyboard shortcuts joined by `+`. | Examples: `ctrl+c`, `ctrl+v`, `alt+tab`, `win+r`, `ctrl+shift+esc` |
| `Scroll` | Scroll vertically or horizontally at `loc`, `label`, or current cursor. | `type`: `vertical` / `horizontal`; `direction`: `up` / `down` / `left` / `right`; `wheel_times` |
| `Move` | Move cursor or drag-and-drop. | `drag=True`, `from_loc=[x, y]`, `duration` |
| `MultiSelect` | Select multiple items or checkboxes in one call. | `locs` or `labels`, `press_ctrl=True/False` |
| `MultiEdit` | Fill multiple text fields in one call. | `locs=[[x,y,text], ...]` or `labels=[[label,text], ...]` |

## Applications & System

| Tool | Purpose | Key Options |
| :--- | :--- | :--- |
| `App` | Launch, focus, or resize Windows applications. | Modes: `launch`, `launch_executable`, `switch`, `resize` |
| `Clipboard` | Read or write the Windows clipboard. | `mode="get"` / `mode="set"` |
| `Process` | List or terminate running processes. | `mode="list"` / `mode="kill"` (confirm before killing) |
| `Notification` | Show a Windows toast notification. | `title`, `message` |
| `FileSystem` | File operations (relative paths resolve from Desktop). | `read`, `write`, `copy`, `move`, `delete`, `list`, `search`, `info` |
| `PowerShell` | Execute PowerShell commands on the host. | High privilege — confirm destructive actions. |
| `Registry` | Read/write Windows Registry keys (`HKCU:\...`, `HKLM:\...`). | `get`, `set`, `delete`, `list` (confirm before writes/deletes) |
| `Scrape` | Fetch web page content via HTTP or active browser DOM. | `use_dom=True`, `query`, `use_sampling=True/False` |
