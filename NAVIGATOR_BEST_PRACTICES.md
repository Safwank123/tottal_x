# Flutter Navigator Best Practices - Modal Bottom Sheet

## The Issue You Had

### ❌ WRONG - Double Navigator.pop()
```dart
// In UsersPage
void _showAddUserBottomSheet() {
  showModalBottomSheet(
    builder: (_) {
      return AddUserBottomSheet(
        onAddUser: (user) {
          context.read<UsersBloc>().add(AddNewUserEvent(user));
          Navigator.pop(context);  // ❌ EXTRA POP - Closes parent!
        },
      );
    },
  );
}

// In AddUserBottomSheet
TextButton(
  onPressed: () {
    widget.onAddUser(userEntity);
    if (mounted) {
      Navigator.pop(context);  // ✓ This closes the bottom sheet
    }
  },
)
```

### What Happens
```
Flow:
1. User saves data
2. AddUserBottomSheet calls Navigator.pop() → closes bottom sheet ✓
3. Callback executes in parent
4. Parent calls Navigator.pop() AGAIN → closes UsersPage ✗
5. Result: BLANK SCREEN 🔴
```

---

## ✅ The Correct Solution

### Single Pop - Bottom Sheet Only
```dart
// In UsersPage (PARENT)
void _showAddUserBottomSheet() {
  showModalBottomSheet(
    builder: (_) {
      return AddUserBottomSheet(
        onAddUser: (user) {
          // ONLY dispatch the event
          // DON'T pop - let the bottom sheet handle its own closing
          context.read<UsersBloc>().add(AddNewUserEvent(user));
        },
      );
    },
  );
}

// In AddUserBottomSheet (BOTTOM SHEET)
TextButton(
  onPressed: () {
    widget.onAddUser(userEntity);  // Notify parent
    if (mounted) {
      Navigator.pop(context);  // ✓ SINGLE pop - closes bottom sheet only
    }
  },
)
```

### What Happens Now
```
Flow:
1. User saves data
2. Callback fires → dispatches event to BLoC
3. AddUserBottomSheet calls Navigator.pop() → closes bottom sheet ✓
4. UsersPage remains on screen ✓
5. BLoC rebuilds the UI with new user ✓
```

---

## 🎯 Flutter Best Practices for Bottom Sheets

### Rule 1: **Bottom Sheet Owns Its Closing**
- The widget that opens (bottom sheet) should close itself
- The parent should NOT close it
- Let the callback be purely for data passing

### Rule 2: **Separation of Concerns**
```dart
// Parent responsibility: Show bottom sheet + handle events
showModalBottomSheet(
  builder: (_) => AddUserBottomSheet(
    onAddUser: (user) {
      // ONLY: Update state/dispatch events
      context.read<UsersBloc>().add(AddNewUserEvent(user));
    },
  ),
);

// Bottom sheet responsibility: Validate input + close itself
onPressed: () {
  if (isValid) {
    widget.onAddUser(userData);  // Notify parent
    Navigator.pop(context);       // Close myself
  }
}
```

### Rule 3: **Use Async/Await for Data Return (Alternative)**
```dart
// More elegant: Return data instead of callback
void _showAddUserBottomSheet() async {
  final user = await showModalBottomSheet<UserEntity>(
    context: context,
    builder: (_) => AddUserBottomSheet(),
  );
  
  if (user != null) {
    context.read<UsersBloc>().add(AddNewUserEvent(user));
  }
}

// In AddUserBottomSheet
onPressed: () {
  if (isValid) {
    Navigator.pop(context, userEntity);  // Return data and close
  }
}
```

---

## Summary

| Aspect | Wrong ❌ | Correct ✅ |
|--------|---------|----------|
| **Who closes?** | Parent + Bottom Sheet | Bottom Sheet only |
| **Parent pop()** | `Navigator.pop(context)` | None |
| **Bottom sheet pop()** | `Navigator.pop(context)` | `Navigator.pop(context)` |
| **Callback purpose** | Data + close | Data only |
| **Result** | Blank screen | Works perfectly |

---

## Your Fixed Code

✅ **UsersPage (`_showAddUserBottomSheet`)**
- Removed `Navigator.pop(context)` from callback
- Callback only dispatches the BLoC event
- Bottom sheet closes itself

✅ **AddUserBottomSheet (Save button)**
- Calls `widget.onAddUser()` to pass data
- Calls `Navigator.pop(context)` to close itself
- Single pop = clean closure
