---
name: html
description: As a subagent, explain how a given class/function/file fits the bigger picture and write an HTML visualisation to file. Only use when the user explicitly requests it (e.g. /html).
---

Important do this as a subagent. 
You a class/function/file/list of changes from commit(s)
Create html page with a walkthrough of steps to take to understand it's motivation/usage 
Short summary at the top:
- Tell me more how it fits into the bigger picture
- What are major concepts and why they exist (labelled A, B, C...)
- At the top draw a graph of relevant dependencies
Then numbered walkthrough steps in style of start with reading X, then read Y. For each step write:
- One line of how it fits in a major concept
- Short description of why it's needed
- Relevant LoC locations and embedded snippets (simplified diff of 'code before' red vs 'code now' green; dont add +/- and no spaces between lines)
Don't worry about visual perfection, prefer faster generation of the html