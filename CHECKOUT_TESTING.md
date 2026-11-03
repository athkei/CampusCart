# Checkout and My Orders test checklist

Run these checks in a debug build connected to the Firebase project or Firebase Emulator Suite. Use test accounts and test data; do not use a production student's account for failure testing.

## Firestore rules

Publish the rules documented in `lib/README_firebase_rules.txt` to Firebase Console > Firestore Database > Rules before testing. Expected access:

- Signed-in student can create an `/orders/{orderId}` document only when its `uid` equals their Auth UID.
- Student can read their own orders, but not another user's order.
- Student client cannot update or delete an order. Update `status` in the Firebase Console for this project, or later add a trusted admin/backend path.

## Happy path

1. Sign in with a test student account and add a menu item to the cart.
2. Open My Cart > Review Order > Place Order.
3. Confirm the button shows its in-progress indicator while submitting, then a success screen appears.
4. Return to the menu and verify the cart badge is zero and My Cart is empty.
5. In Firebase Console > Firestore > `orders`, verify the new document contains `uid` matching the test account, `items` with `foodId`, `name`, `price`, `quantity`, and `subtotal`, `totalPrice`, `status: Pending`, and server timestamp fields.
6. Open My Orders. Verify the newly placed order appears, newest first, with item details, total and Pending status.
7. In Firebase Console, change only that test order's `status` to `Preparing`, `Ready for Pickup`, then `Completed`. Verify My Orders updates live each time.

## Isolation and failure paths

1. Sign in with a second test account. Verify it does not see the first account's order.
2. With the second account, attempt to create an order whose `uid` is the first account's UID; Firestore must reject it.
3. With the second account, attempt to read or update the first account's order; Firestore must reject access.
4. To test a failed checkout write, temporarily publish a test-only rule denying order creation, attempt checkout, then restore the owner-only create rule. Verify an error is shown and the cart remains intact. Do not leave deny-all or permissive test rules deployed.

## Automated checks

Run `flutter analyze` and `flutter test` after changes. These checks do not replace the authenticated Firestore integration checks above.
