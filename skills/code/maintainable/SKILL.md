---
name: maintainable
description: Apply good software design principles for maintainability as per John's Osterhout's philosophy of software design
---

**Definition:** Module is any unit of code that hides implemented functionality behind an interface, eg function, class or file

### 1. Deep vs Shallow Module Check

- **Core Formula:** `Module Value = Functionality - Interface Complexity`
- **Goal** is to have Deep Modules: Simple interfaces hiding powerful implementations (e.g., Unix I/O).

**Assessment:**
- **Functionality**: How much does it do? Does it hide significant complexity?
- **Interface**: How many methods/parameters? How much knowledge is required to use it?
- **The Feel Test**:
    - Interface complexity ≈ Implementation complexity? → **Shallow** (eliminate or deepen)
    - Simple interface, powerful implementation? → **Deep** (Good)
    - Just wrapping another module? → **Shallow** (Unnecessary abstraction)

**Warning Signs (Shallow):**
- Thin wrapper classes exposing most wrapped methods.
- Pass-through functions adding no logic.
- Having to write much code to use a module
- Passing complexity onto users

### 2. Information Leakage Check

- **Core Test:** "If I change implementation details, do callers break? Is the same design decision living in multiple modules?" (If YES, information is leaking).

- **Goal:** Encapsulation. Each module should hide its design decisions and implementation details from others. Least possible dependencies between modules.

**Examples (Bad):**
- File format known by separate reader and writer classes 
- Serialization format duplicated across services
- Hardcoded assumptions, eg module A creates a list where index 0 is the ID and index 1 is the name; module B reads it assuming the same layout
- Hidden dependency
- Returning raw rows/arrays instead of domain objects. Callers shouldn't know column order.
- Forcing callers to know internal IDs or ordering.


### 3. Hidden Dependency Check

- **Core test:** "Are there dependencies between modules that are not stated in the interface"
- **Goal:** Avoid non-obvious dependencies by making the interface carry the information

**Examples (Bad)**
- module A must have initialize() called before process(), but nothing in the interface enforces
- module B silently reads a global that module A sets.
- A's save() also happens to flush a cache that B relies on. A future refactor that makes save() stop flushing

### 4. Code cohesion
- **Core test:** "Is releated knowledge spread across modules?"
- **Goal:** Relevant modules are in the same place so code cohesion is high.

**Warning signs (Low cohesion):**
- There is redundant code and duplicate logic.
- DRY is not followed (except for small and simple pieces of code which can appear no more than twice.)