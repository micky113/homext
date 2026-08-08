const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Cloud Function to process the notifications_queue Firestore collection
 * and deliver push notifications via FCM with sound and banners (v1 API).
 */
exports.processNotificationsQueue = functions.firestore
  .document("notifications_queue/{docId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    if (!data) return null;

    const { token, title, body, data: payloadData } = data;

    if (!token) {
      console.warn("Notification document lacks token. Deleting document.");
      return snapshot.ref.delete();
    }

    const message = {
      token: token,
      notification: {
        title: title || "MyGate Homext Alert",
        body: body || "You have a new gate alert.",
      },
      data: payloadData || {},
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "high_importance_channel",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log(`Successfully sent FCM message: ${response}`);
      
      // Delete document from queue after successful dispatch to keep database clean
      await snapshot.ref.delete();
    } catch (error) {
      console.error(`Error sending FCM message: ${error}`);
      
      // Update status to FAILED for debugging instead of silent deletion
      await snapshot.ref.update({
        status: "FAILED",
        error: error.message,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    return null;
  });
