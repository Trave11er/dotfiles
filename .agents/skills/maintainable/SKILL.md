---
name: maintainable
description: Apply good software design principles for maintainability; red flags are shallow modules, complex interfaces, information leakage, difficult to test, difficult to modify, tight coupling, violating SOLID, violating DRY
---

Follow these checks and principles when analyzing or generating code.

### 1. Deep vs Shallow Module Check

**Core Formula:** `Module Value = Functionality - Interface Complexity`

Target **Deep Modules**: Simple interfaces hiding powerful implementations (e.g., Unix I/O).

**Assessment:**
- **Functionality**: How much does it do? Does it hide significant complexity?
- **Interface**: How many methods/parameters? How much knowledge is required to use it?
- **The Feel Test**:
    - Interface complexity ≈ Implementation complexity? → **Shallow** (eliminate or deepen)
    - Simple interface, powerful implementation? → **Deep** (Good)
    - Just wrapping another module? → **Shallow** (Unnecessary abstraction)

**Warning Signs (Shallow):**
- Wrapper classes exposing most wrapped methods.
- Pass-through functions adding no logic.
- "Thin" layers that can be eliminated.

### 2. Information Leakage Check

**Core Test:** "If I change implementation details, do callers break?" (If YES, information is leaking).

**Common Leakage Patterns:**
- **Database Schema**: Returning raw rows/arrays instead of domain objects. Callers shouldn't know column order.
- **Internal Structures**: Exposing cache/buffer details. Callers shouldn't know *how* data is stored, only *what* is stored.
- **Configuration**: Forcing callers to know internal IDs or ordering.

**Goal:** Encapsulation. Each module should hide its design decisions and implementation details from others.

### 3. Red Flag Scanner (Naming & Structure)

**Generic Names (Avoid):**
- `Manager`, `Util`, `Helper` (Vague)
- `Service`, `Handler`, `Processor` (Often lazy)
- `Base`, `Abstract` (Prefixes)
- **Ask**: Does the name reveal *what* it does, or just *that* it does something?

**Temporal Decomposition (Avoid):**
- Names like `step1`, `initialize`, `process`, `finalize`.
- **Problem**: Organized by *when* it happens, not *what* it does.
- **Fix**: Organize by functionality/capability.

**Pass-Through Methods:**
- Methods that just delegate without adding value.
- Indirection for the sake of indirection.
