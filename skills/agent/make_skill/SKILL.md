---
name: make_skill
description: Create a SKILL.md (in its own subdir) from a skill description, following the required skill format. Only use when the user explicitly requests it (e.g. /make_skill).
---

- You are given a description of a skill.
- You should write create an .md file based on description.
- Note, you should make sure it is follows the following format

---
name: my-skill
description: Short description of what this skill does and when to use it.
---

# My Skill

Detailed instructions for the agent.

## When to Use

- Use this skill when...
- This skill is helpful for...

## Instructions

- Step-by-step guidance for the agent
- Domain-specific conventions
- Best practices and patterns
- Use the ask questions tool if you need to clarify requirements with the user

Note, you should make sure it is saved in a subdir with suitable name as a SKILL.md file.
Skills can also include optional directories for scripts, references, and assets:
skills/
└── deploy-app/
    ├── SKILL.md
    ├── scripts/
    │   ├── deploy.sh
    │   └── validate.py
    ├── references/
    │   └── REFERENCE.md
    └── assets/
        └── config-template.json
