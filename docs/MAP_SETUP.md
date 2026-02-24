# Google Map Nahi Dikh Raha / Search Suggestion Nahi Aa Raha

## 1. Map blank / show nahi ho raha

**Sabse common wajah:** API key ke liye **Maps SDK** enable nahi hai.

### Steps (Google Cloud Console)

1. [Google Cloud Console](https://console.cloud.google.com/) kholo.
2. Project select karo: **prsapp-90270** (ya jo Firebase project use kar rahe ho).
3. **APIs & Services** → **Library** (ya "Enable APIs and Services").
4. Search karo: **Maps SDK for Android** → open karo → **Enable**.
5. Phir search karo: **Maps SDK for iOS** → **Enable** (agar iOS build karte ho).
6. (Optional) **Geocoding API** bhi enable karo – address search ke liye better results.

API key wahi use ho rahi hai jo AndroidManifest / AppDelegate me hai. Enable ke baad app dubara run karo; map load honi chahiye.

---

## 2. Search me suggestion nahi aa raha

- Address **type karo** (e.g. "Lahore", "DHA Karachi", "F-7 Islamabad").
- **Search icon** dabao ya keyboard pe **Enter / Search** dabao.
- Agar ek result milega to map us location par chala jayegi.
- Agar **multiple** results honge to neeche **suggestions list** dikhegi – koi bhi tap karo, map wahan move ho jayegi.

Agar "Address not found" aaye to alag words try karo (city name, area, full address).

---

## 3. Internet / permission

- **INTERNET** permission Android manifest me add ho chuka hai (map tiles ke liye).
- Emulator/device pe **internet** on ho.

---

**Short:** Map ke liye Cloud Console me **Maps SDK for Android** (aur iOS agar chahiye) **Enable** karo. Search ke liye address likh ke **Search** dabao; multiple results me se suggestion tap karo.
