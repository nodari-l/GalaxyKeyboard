# KeyboardViewController Refactoring Plan

## Code Quality Assessment Summary
- **Total Lines**: 868
- **Main Issues**: Massive class, DRY violations, magic numbers, complex methods
- **Assessment Date**: January 25, 2026

## High Priority Issues

### 1. Massive Class Violation (Single Responsibility Principle)
**Priority**: HIGH | **Status**: ❌ NOT FIXED

**Issue**: `KeyboardViewController` has 868 lines handling multiple responsibilities:
- UI creation and layout
- Event handling  
- State management
- Appearance management
- Popup management

**Impact**: Difficult to maintain, test, and extend

**Solution**: Extract separate classes:
- [ ] `KeyboardLayoutManager` - Handle keyboard layout creation
- [ ] `KeyboardAppearanceManager` - Manage themes and colors  
- [ ] `KeyboardStateManager` - Handle shift, caps, language states
- [ ] `PopupManager` - Manage key preview and long-press popups

**Estimated Effort**: High
**Lines Affected**: All 868 lines

---

### 2. Severe DRY Violations in Button Creation
**Priority**: HIGH | **Status**: ❌ NOT FIXED

**Issue**: Button creation code duplicated across 4 methods:
- `createKeyButton()` (lines 344-363)
- `createSpecialButton()` (lines 365-384)  
- `createDeleteButton()` (lines 386-404)

**Duplicated Code**:
- Shadow configuration (lines 350-353, 371-374, 392-395)
- Corner radius setup
- Height constraints
- Event handler attachment

**Solution**: Create single method:
```swift
enum ButtonType {
    case key, special, delete
}

private func createButton(type: ButtonType, title: String, action: Selector) -> UIButton {
    // Consolidated button creation logic
}
```

**Estimated Effort**: Medium
**Lines Affected**: 344-404

---

### 3. Complex Method with Multiple Responsibilities  
**Priority**: HIGH | **Status**: ❌ NOT FIXED

**Issue**: `setupKeyboard()` method (lines 93-162) handles:
- View cleanup
- Layout creation
- Conditional logic for different keyboard modes
- Constraint setup

**Cyclomatic Complexity**: Very high with nested if-else statements

**Solution**: Break into smaller methods:
```swift
private func setupKeyboard() {
    cleanupKeyboard()
    let layout = createMainLayout()
    addKeyboardRows(to: layout)
    configureInputModeSwitchKey()
}
```

**Estimated Effort**: Medium  
**Lines Affected**: 93-162

---

### 4. Magic Numbers Throughout Codebase
**Priority**: HIGH | **Status**: ❌ NOT FIXED

**Issue**: Hard-coded values scattered throughout:
- `constant: 60`, `constant: 50` (lines 314, 317, 324, 331)
- `0.5` (lines 200, 524) - Double-tap detection
- `0.1` (line 566) - Delete repeat interval
- `45` (line 13) - Key height
- Spacing values: `10`, `6`, `4`, `8`

**Solution**: Create constants structure:
```swift
private struct Constants {
    struct Dimensions {
        static let keyHeight: CGFloat = 45
        static let specialKeyWidth: CGFloat = 60
        static let normalKeyWidth: CGFloat = 50
        static let keySpacing: CGFloat = 6
        static let stackSpacing: CGFloat = 10
        static let edgeInsets: CGFloat = 4
    }
    
    struct Timing {
        static let doubleTapInterval: TimeInterval = 0.5
        static let deleteRepeatDelay: TimeInterval = 0.5
        static let deleteRepeatInterval: TimeInterval = 0.1
        static let longPressDelay: TimeInterval = 0.5
        static let animationDuration: TimeInterval = 0.1
    }
}
```

**Estimated Effort**: Low
**Lines Affected**: Throughout entire file

---

## Medium Priority Issues

### 5. String Hardcoding Violates DRY
**Priority**: MEDIUM | **Status**: ❌ NOT FIXED

**Issue**: UI strings hardcoded in multiple places:
- Button titles: "🌐", "⇧", "⌫", "↵", "ABC", "!#1"
- Comparison strings in `showKeyPreview` (line 421)
- Special button detection (line 802)

**Solution**: String constants enum:
```swift
enum KeyboardStrings {
    static let shift = "⇧"
    static let delete = "⌫"
    static let globe = "🌐"
    static let returnKey = "↵"
    static let symbols = "!#1"
    static let letters = "ABC"
    static let symbolsPage1 = "1/2"
    static let symbolsPage2 = "2/2"
}
```

**Estimated Effort**: Low
**Lines Affected**: 421, 802, and button creation methods

---

### 6. Inconsistent State Update Pattern
**Priority**: MEDIUM | **Status**: ❌ NOT FIXED

**Issue**: Different methods use different approaches for state updates:
- Some call `updateShiftState()` (lines 515, 741)
- Some call `setupKeyboard()` directly (lines 541, 757, 864)
- Inconsistent update chain

**Solution**: Create consistent state update pipeline:
```swift
private func updateKeyboardState() {
    updateShiftState()
    updateAppearance()
    // Centralized state update logic
}
```

**Estimated Effort**: Medium
**Lines Affected**: 515, 541, 757, 864, and related methods

---

### 7. Long Parameter Lists and Complex Logic
**Priority**: MEDIUM | **Status**: ❌ NOT FIXED

**Issue**: 
- `updateColorsRecursively` (line 797) takes multiple color parameters
- Complex conditional logic in `showKeyPreview` (line 421)

**Solution**: 
- Use configuration objects for color themes
- Extract preview logic to separate method

**Estimated Effort**: Medium
**Lines Affected**: 797, 421, and related appearance methods

---

### 8. Timer Management Scattered
**Priority**: MEDIUM | **Status**: ❌ NOT FIXED

**Issue**: Timer management logic spread across multiple methods:
- Delete timer (lines 555, 566, 572-575)
- Long press timer (lines 33, 200)
- No centralized timer lifecycle management

**Solution**: Create `TimerManager` class:
```swift
class KeyboardTimerManager {
    private var deleteTimer: Timer?
    private var longPressTimer: Timer?
    
    func startDeleteRepeat(action: @escaping () -> Void)
    func stopDeleteRepeat()
    func startLongPress(delay: TimeInterval, action: @escaping () -> Void)
    func stopAllTimers()
}
```

**Estimated Effort**: Medium
**Lines Affected**: 555, 566, 572-575, 200, and timer-related code

---

## Low Priority Issues

### 9. Inconsistent Naming Conventions
**Priority**: LOW | **Status**: ❌ NOT FIXED

**Issue**: Mixed naming patterns:
- `deletePressed` vs `deleteTouchDown`
- `spacePressed` vs `spaceSwipedLeft`

**Solution**: Consistent verb-noun pattern for all action methods

**Estimated Effort**: Low
**Lines Affected**: Method names throughout

---

### 10. Missing Error Handling
**Priority**: LOW | **Status**: ❌ NOT FIXED

**Issue**: Limited error handling for edge cases:
- Force unwrapping without fallbacks
- No validation for button creation failures

**Solution**: Add proper error handling and fallbacks

**Estimated Effort**: Low
**Lines Affected**: Various guard statements and optional handling

---

### 11. Long Methods
**Priority**: LOW | **Status**: ❌ NOT FIXED

**Issue**: Several methods exceed 30 lines:
- `showKeyPreview` (lines 414-470)
- `showSoftSignPopup` (lines 667-722)
- `updateColorsRecursively` (lines 797-815)

**Solution**: Extract sub-methods for better readability

**Estimated Effort**: Low
**Lines Affected**: Long methods throughout

---

### 12. Appearance Logic Complexity
**Priority**: LOW | **Status**: ❌ NOT FIXED

**Issue**: `updateColorsRecursively` performs multiple responsibilities:
- Button type detection
- Color application
- Recursive traversal

**Solution**: Extract theme management to separate class

**Estimated Effort**: Low
**Lines Affected**: 797-815 and related appearance code

---

## Implementation Strategy

### Phase 1: Quick Wins (Low Effort, High Impact)
- [ ] **Extract constants** (Issue #4)
- [ ] **Create string constants** (Issue #5)
- [ ] **Consolidate button creation** (Issue #2)

### Phase 2: Structural Improvements (Medium Effort)
- [ ] **Simplify setupKeyboard method** (Issue #3)
- [ ] **Implement consistent state management** (Issue #6)
- [ ] **Create timer manager** (Issue #8)

### Phase 3: Major Refactoring (High Effort)
- [ ] **Break down massive class** (Issue #1)
- [ ] **Extract appearance management** (Issue #12)
- [ ] **Improve error handling** (Issue #10)

---

## Progress Tracking

**Last Updated**: January 25, 2026
**Total Issues**: 12
**Fixed Issues**: 0 ✅
**Remaining Issues**: 12 ❌

### Status Legend
- ✅ **FIXED** - Implementation completed and tested
- 🔄 **IN PROGRESS** - Currently being worked on
- ❌ **NOT FIXED** - Not yet addressed
- ⏸️ **BLOCKED** - Waiting on dependencies

---

## Notes
- Focus on high-priority issues first for maximum impact
- Consider writing tests before major refactoring
- Some changes may require updating related files
- Breaking changes should be documented and communicated