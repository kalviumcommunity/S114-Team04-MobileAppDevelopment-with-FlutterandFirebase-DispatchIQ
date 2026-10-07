# DispatchIQ

Flutter client for the DispatchIQ appliance repair dispatch workspace. The app loads jobs and technicians from the Express backend on sign-in and synchronizes assignment and repeat-visit changes.

## Run locally

1. Start the API from the repository's `backend` folder with `npm start`.
2. From this folder, run `flutter pub get`.
3. Run `flutter run` for a connected device, emulator, or Chrome.

The first sign-in uses the local demo data to seed an empty backend. Android emulators connect to `10.0.2.2:5000`; web and iOS simulators use `127.0.0.1:5000`. For a physical device, set `--dart-define=API_BASE_URL=http://<computer-LAN-IP>:5000` when running Flutter. Backend state is currently held in memory and resets when the API process stops.
