---
layout: post
title: "Autonomy Slider and LLM tools for software development"
comments: true
math: true
slug: autonomy-slider
summary: "The mental model of Autonomy Slider with examples of software development use cases with LLM-based tools"
date: "2026-02-21"
tags: [genai, programming]
---

The LLM-based tools, in particular for software development, have gotten so much better lately. Just some months ago I was seeking a [solution](https://alexsm.com/vscode-copilot-keybinding/) for turning off autocomplete when there was too little context, and now I find myself more and more operating in more agentic workflows, where larger logic increments are generated based on prompts and carefully maintained initial context.

I find it very fitting to apply the mental model of "autonomy slider", introduced by Andrej Karpathy, to the varying selection of LLM-based tools and development workflows. In a nutshell, it describes the varying level of agency of a user as compared to how much is offloaded to AI systems. With software engineering, you can e.g. operate with the following levels of involvement:

- **Writing code manually, with extra LLM-driven autocomplete**: VSCode with Github Copilot is particularly suitable for that, and I admit that the UI and quality of its autocomplete and *next edit suggestions* has improved significantly lately.

- **Issuing larger code generation tasks with precisely controlled context**: I would say that this mode of operation is also a strong suit of VSCode with Github Copilot, as it is very easy to specify a concrete context by mixing files, directories, Git SHAs etc.

- **Large prompt-based chunks of work with autonomous context management**: more advanced tools like Windsurf and Cursor stand out here, as they maintain their own context engines, so the developer doesn't have to always pin down all the relevant files, as an example; this kind of development is much more effective when combined with context files like `AGENTS.md`, skills, and maintaining a good architecture of the codebase. 

- **Long-horizon tasks with AI agents**: agents like Claude Code, especially with using [Git worktrees](https://git-scm.com/docs/git-worktree), can be pretty good for large and tedious tasks.

As a nice reference, I would like to leave a link to Andrey Karpathy's talk where he introduced this concept: [Software Is Changing (Again)](https://www.youtube.com/watch?v=LCEmiRjPEtQ).
