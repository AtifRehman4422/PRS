# OTP Email Na Aaye To Check Karein

## 1. App Message Dikh Raha Hai?
- Sign Up ke baad: **"OTP sent to [email]. Check inbox and Spam."** SnackBar aana chahiye.
- Agar **"Resend failed"** ya koi error aaye → Firestore / network issue. Error message padhen.

## 2. Firestore – `mail` Collection
- Firebase Console → **Firestore Database** → **Data**
- **`mail`** collection open karein.
- Sign Up ya Resend dabayein, phir **`mail`** mein naya document add hua?
  - **Haan** → App sahi kaam kar rahi hai; problem **Trigger Email extension** ya Gmail side.
  - **Nahi** → App Firestore tak write nahi kar pa rahi (rules / internet / Cloud Function fail).

## 3. Trigger Email Extension
- Firebase Console → **Extensions** → **Trigger Email from Firestore**
- **Collection path** exactly **`mail`** ho (capital M, small mail).
- **Gmail** wale account (propertyrent48@gmail.com) pe **sign-in allow** kiya ho.
- **Logs** dekhen: Extension → **Logs** – koi error (e.g. "quota", "permission") to nahi?

## 4. Gmail Side
- User email **Inbox** ke sath **Spam**, **Promotions**, **Updates**, **All Mail** bhi check karein.
- Sender **propertyrent48@gmail.com** se aati hai – usko "Not spam" / "Important" mark karein taake aage Inbox mein aaye.

## 5. Cloud Function Deploy
- Agar app **Cloud Function** use kar rahi ho to: `cd functions` → `npm install` → `firebase deploy --only functions`
- Functions **Logs** (Firebase Console → Functions → Logs) mein error to nahi?

---
**Short:** Pehle Firestore `mail` mein document aa raha hai ya nahi check karein. Agar aa raha hai to problem Trigger Email / Gmail config ya spam filter ki hai.
