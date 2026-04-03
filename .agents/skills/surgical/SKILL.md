---
name: surgical
description: When doing changes to existing code remember that reviewer will have to spend valuable time on analysing those so try to minimize amount of change
---

Do the changes specified in a surgical manner. Namely, do as little changes as possible to achieve the result so that there is less changes to review.

If the user asks to add something, preserve existing symbols and introduce the new one separately unless replacement is explicit.

Never remove existing print statements, logging calls, or other debug output unless explicitly asked. When replacing logic around them, preserve the output and update it to reflect new values.

Never remove commented-out code unless the user explicitly asks. During active development, commented-out code is a deliberate bookmark the user intends to revisit.
