# DispatchIQ

## Run locally

1. Start the API from the `backend` folder with `npm start`.
2. From `frontend`, run `flutter pub get` and then `flutter run`.

The API listens on port `5000`. Flutter uses `127.0.0.1` for web and iOS simulators, and `10.0.2.2` for the Android emulator. For a physical device, pass the computer's LAN address, for example:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:5000
```

The first successful sign-in seeds the API with the existing demo jobs and technicians. Job assignment and repeat-visit changes are then synchronized through `/api/state`. The backend currently keeps this state in memory, so restarting it resets the data to the demo seed on the next sign-in.
