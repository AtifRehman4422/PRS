const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const CODES_COLLECTION = "email_verification_codes";
const MAIL_COLLECTION = "mail"; // Trigger Email extension sends from here
const CODE_EXPIRY_MINUTES = 10;
const CODE_LENGTH = 6;

function generateCode() {
  let code = "";
  for (let i = 0; i < CODE_LENGTH; i++) {
    code += Math.floor(Math.random() * 10);
  }
  return code;
}

function sanitizeDocId(email) {
  return email.toLowerCase().replace(/[^a-z0-9]/g, "_");
}

/**
 * Request a 6-digit verification code. Code is sent to the email the user entered.
 * Stores code in Firestore. Add your email provider (Nodemailer/SendGrid) to send to that email.
 */
exports.requestEmailVerificationCode = functions.https.onCall(async (data, context) => {
  const email = (data.email || "").trim().toLowerCase();
  if (!email) {
    throw new functions.https.HttpsError("invalid-argument", "Email required");
  }

  const code = generateCode();
  const expiry = new Date(Date.now() + CODE_EXPIRY_MINUTES * 60 * 1000);
  const docId = sanitizeDocId(email);

  await admin.firestore().collection(CODES_COLLECTION).doc(docId).set({
    email,
    code,
    expiry: admin.firestore.Timestamp.fromDate(expiry),
  });

  // Send code to user's email via Trigger Email extension (FROM: propertyrent48@gmail.com).
  await admin.firestore().collection(MAIL_COLLECTION).add({
    to: [email],
    message: {
      subject: "Your verification code",
      text: `Your verification code is: ${code}. It expires in ${CODE_EXPIRY_MINUTES} minutes.`,
    },
  });

  console.log("Verification code saved and email queued for:", email);
  return { success: true };
});

/**
 * Verify the 6-digit code for the given email.
 */
exports.verifyEmailVerificationCode = functions.https.onCall(async (data, context) => {
  const email = (data.email || "").trim().toLowerCase();
  const code = (data.code || "").trim().replace(/\D/g, "");
  if (!email || code.length !== CODE_LENGTH) {
    return { valid: false };
  }

  const docId = sanitizeDocId(email);
  const ref = admin.firestore().collection(CODES_COLLECTION).doc(docId);
  const snap = await ref.get();

  if (!snap.exists) return { valid: false };
  const d = snap.data();
  const stored = d.code;
  const expiry = d.expiry && d.expiry.toDate ? d.expiry.toDate() : null;
  if (!stored || !expiry || new Date() > expiry) return { valid: false };
  const valid = stored === code;
  if (valid) await ref.delete();
  return { valid };
});
