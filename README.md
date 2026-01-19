# One Stop Gym Solution - Landing App 🏋️‍♂️

A modern, responsive landing page built with **Flutter** and **Supabase** to manage gym waitlists. This project was completed within a 48-hour challenge.

## 🚀 Features
* **Premium UI:** Glassmorphic design with atmospheric mesh backgrounds and smooth entrance animations.
* **Responsive Layout:** Fully optimized for Mobile, Tablet, and Desktop views.
* **Waitlist Management:** Secure email capture system integrated with Supabase.
* **Real-time Validation:** Client-side email regex validation and server-side uniqueness checks.
* **Timezone Optimized:** Database configured for Pakistan Standard Time (PKT).

## 🛠 Tech Stack
* **Frontend:** Flutter (v3.x)
* **Backend:** Supabase (PostgreSQL)
* **Security:** Row Level Security (RLS) policies to protect user privacy.

## 🛡 Database Security (RLS)
The project uses PostgreSQL Row Level Security to ensure data privacy:
- **Insert Policy:** Allows anonymous users to join the waitlist.
- **Select Policy:** Restricted to prevent users from reading other people's data.


## ⚙️ Setup Instructions
1. Clone the repo: `git clone <https://github.com/habiba-imran/one-stop-gym-solution>`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`