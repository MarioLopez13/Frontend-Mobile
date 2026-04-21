# SmartPayout Mobile

Aplicación móvil del proyecto **Capstone Pagos QR/NFC**.  
Esta app representa el canal móvil del sistema y sirve como base para el flujo de usuario final en pagos digitales.

Actualmente funciona con autenticación mock y datos simulados, pero ya tiene estructura lista para crecer y conectarse a un backend real.

---

## Objetivo del proyecto

La aplicación móvil tiene como finalidad permitir al usuario final interactuar con el sistema de pagos digitales desde un dispositivo móvil, especialmente en funciones como:

- autenticación
- consulta de sesión
- inicio o dashboard móvil
- lectura/validación de QR
- historial de movimientos
- futura integración de pagos QR/NFC

Esta versión corresponde a una **base funcional inicial**, no a la implementación final conectada al backend.

---

## Tecnologías usadas

- Flutter
- Riverpod
- Go Router
- Shared Preferences
- Google Fonts

---

## Estado actual

Actualmente la app implementa:

- login mock
- persistencia local de sesión
- roles simulados (`admin` y `operator`)
- home móvil
- resumen visual con métricas simuladas
- navegación base para futuras pantallas
- estructura por features y carpetas reutilizables

Aún no existe integración real con backend ni cámara/NFC real.

---

## Estructura del proyecto


lib/
  app/
    app.dart
    router.dart
  core/
    theme/
      app_theme.dart
  features/
    auth/
      auth_controller.dart
      login_page.dart
    history/
    home/
      home_page.dart
    payments/
    qr/
  shared/
    mocks/
    models/
      app_user.dart
    widgets/
  main.dart
Flujo actual de autenticación

La autenticación es simulada.

Reglas actuales
si el correo contiene admin, el usuario entra con rol admin
cualquier otro correo válido entra como operator
la sesión se guarda en SharedPreferences
Ejemplos
admin@demo.com → admin
operador@demo.com → operator

Esto es temporal y debe ser reemplazado por autenticación real con backend.

Navegación actual
Rutas implementadas
/login → inicio de sesión
/ → pantalla principal

La navegación está preparada con GoRouter para añadir nuevas pantallas sin reestructurar el proyecto.

Contrato esperado para backend

La app móvil necesita un backend sencillo pero claro.
No se requiere una versión final compleja para comenzar, pero sí endpoints consistentes.

1. Autenticación
Endpoints esperados
POST /api/auth/login
GET /api/auth/me
POST /api/auth/logout
Respuesta esperada de login
{
  "token": "jwt-token",
  "user": {
    "id": "1",
    "name": "Administrador Demo",
    "email": "admin@demo.com",
    "role": "ADMIN"
  }
}
2. Validación de QR

Este módulo será clave para el flujo móvil.

Endpoints esperados
GET  /api/qr/:code
POST /api/qr/pay
Respuesta esperada de validación
{
  "id": "u1",
  "code": "BUS-001",
  "busLabel": "Unidad 001",
  "routeName": "Ruta Norte",
  "driverName": "Carlos Mena",
  "amount": 0.35,
  "active": true
}
Request esperado para pago QR
{
  "qrCode": "BUS-001",
  "amount": 0.35,
  "method": "QR"
}
Respuesta esperada
{
  "id": "p15",
  "qrCode": "BUS-001",
  "busLabel": "Unidad 001",
  "routeName": "Ruta Norte",
  "amount": 0.35,
  "method": "QR",
  "status": "APPROVED",
  "createdAt": "2026-03-24T10:45:00"
}
3. Historial de transacciones
Endpoints esperados
GET /api/mobile/payments/history
GET /api/payments/:id
Respuesta esperada
[
  {
    "id": "p1",
    "qrCode": "BUS-001",
    "busLabel": "Unidad 001",
    "routeName": "Ruta Norte",
    "amount": 0.35,
    "method": "QR",
    "status": "APPROVED",
    "createdAt": "2026-03-24T10:30:00"
  }
]
4. NFC

Aunque todavía no está implementado en frontend móvil, el backend debería prever un contrato escalable.

Endpoints esperados
POST /api/nfc/validate
POST /api/nfc/pay
Request esperado
{
  "tagId": "04AABB2299",
  "amount": 0.35,
  "method": "NFC"
}
Recomendación para el backend

La app móvil no necesita depender de una arquitectura final gigante para comenzar.
Lo recomendable es que el backend implemente una primera versión simple y extensible.

Recomendación mínima
Spring Boot
JWT
endpoints REST claros
separación por módulos:
auth
qr
payments
history
nfc
Si se trabaja con microservicios

Los más útiles al inicio serían:

identity
payments
qr
gateway
Cómo integrar backend en esta app

Actualmente la app usa:

Riverpod para estado
SharedPreferences para sesión
navegación con GoRouter

Para pasar a backend real:

crear capa de servicios HTTP
mover login mock a POST /api/auth/login
guardar token real
obtener usuario real desde /api/auth/me
conectar lectura QR a /api/qr/:code
conectar pago a /api/qr/pay
conectar historial a /api/mobile/payments/history
Instalación local
flutter pub get
flutter run
Notas importantes
la app actual es una base funcional de frontend móvil
no tiene integración real con backend
no implementa todavía lectura real de cámara ni NFC nativo
sirve como avance demostrable y como base estructural para el prototipo móvil final