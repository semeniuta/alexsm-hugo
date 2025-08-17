---
layout: post
title: "Configure on-demand GitHub Copilot completions in VSCode"
comments: true
math: true
slug: vscode-copilot-keybinding
summary: "Control when you want the completions by a keybinding"
date: "2025-08-15"
tags: [vscode, genai]
---

Autocompletion with GitHub Copilot is often useful, but can be annoying and distracting at times (particularly when there is not much context, so the suggestions are just wrong). The default configuration is that completions can be suggested automatically as you write code, which is not something that you always want. What if you would like to receive suggestions precisely when you want them by activating a keyboard shortcut? Here’s how to configure it.

In `settings.json` (which on a Mac is located in `~/Library/Application Support/Code/User`) you disable inline suggestions and enable GitHub Copilot for all files:

```json
{
	// ... existing configuration entries

	"editor.inlineSuggest.enabled": false,

	"github.copilot.enable": {
		"*": true
	}
}
```

Then, in `keybindings.json` (which is located in the same directory, in our case `~/Library/Application Support/Code/User`) add the keybinding you want to activate completions. We will configure it to be triggered by **⌘+Enter**:

```json
[
	// ... existing keybinding

	{
		"key": "cmd+enter",
		"command": "editor.action.inlineSuggest.trigger",
		"when": "editorTextFocus && !editorReadonly"
	}
]
```
