# Instrucciones para configurar el entorno de desarrollo

## Backend (Django + DRF)

1. Crear entorno virtual (Windows, PowerShell):

```
python -m venv venv
.\venv\Scripts\Activate.ps1
```

2. Instalar dependencias del backend:

```
pip install -r requirements.txt
```

3. (Opcional) Migrar la base de datos:

```
python manage.py makemigrations
python manage.py migrate
```

4. (Opcional) Crear superusuario:

```
python manage.py createsuperuser
```

5. Ejecutar el servidor:

```
python manage.py runserver
```

---

## Frontend (Flutter)

1. Instalar dependencias de Flutter:

```
flutter pub get
```

2. Ejecutar la app en modo desarrollo:

```
flutter run
```

---

Asegúrate de tener Python, pip y Flutter instalados en tu sistema antes de ejecutar estos comandos.
