# Takhta Langit

God-sim fantasi isekai berbasis HTML. APK dibuat otomatis oleh GitHub Actions.

Setiap kali ada push ke repo ini, buka tab **Actions** → tunggu build selesai → ambil `TakhtaLangit.apk` di bagian **Releases**.

- `index.html`: seluruh game
- `setup.sh`: menyiapkan project Android (WebView)
- `takhta.keystore`: kunci tanda tangan tetap, supaya APK baru bisa dipasang menimpa yang lama tanpa hapus data
- Simpanan dunia tersimpan di HP dan disimpan otomatis saat aplikasi ditutup
