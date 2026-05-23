const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onOrderCreated = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const orderData = snap.data();

    // Get all admin users
    const adminUsersSnapshot = await admin
      .firestore()
      .collection("users")
      .where("role", "==", "admin")
      .get();

    const tokens = [];
    adminUsersSnapshot.forEach((doc) => {
      const user = doc.data();
      if (user.fcmToken) {
        tokens.push(user.fcmToken);
      }
    });

    if (tokens.length > 0) {
      const payload = {
        notification: {
          title: "New Order Received!",
          body: `Order #${orderData.orderNumber} has been placed.`,
        },
      };

      try {
        await admin.messaging().sendToDevice(tokens, payload);
        console.log("Notification sent successfully to admins");
      } catch (error) {
        console.error("Error sending notification to admins:", error);
      }
    }
  });

exports.onOrderStatusUpdated = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    if (newValue.status !== previousValue.status && newValue.status === "Ready") {
      const userId = newValue.userId;
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .get();

      if (userDoc.exists) {
        const user = userDoc.data();
        if (user.fcmToken) {
          const payload = {
            notification: {
              title: "Your Order is Ready!",
              body: `Your order #${newValue.orderNumber} is ready for pickup.`,
            },
          };

          try {
            await admin.messaging().sendToDevice(user.fcmToken, payload);
            console.log("Notification sent successfully to user");
          } catch (error) {
            console.error("Error sending notification to user:", error);
          }
        }
      }
    }
  });
