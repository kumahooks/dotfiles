---
description: Review uncommited changes against the project's four principles - simplicity, minimalism, elegance, and excellence.
agent: build
---

Read all the uncommited changes carefully, and:
1. Internalize the rules that the code should follow the four guiding principles: simplicity, minimalism, elegance and excellence.
2. Spawn three (or more, as necessary) agents to indepedently review the changes, each with their own scope and goals for review. They should be given proper context of what the changes are solving, the files, and freedom to explore (only read!) as necessary.
3. Once the agents finish their review, gather all their findings. Validate each finding with the codebase, analyzing if they make sense or not.
4. Separate each finding per severity: High (must be addressed), Medium (should be addressed), Low (could be addressed).

Always confirm the scope of files you will be reviewing from, before you start it. Before the agents are spawned for the review, you should create a small summary of what you understood about the changes, and ask the user if that makes sense as a starting point of view.
