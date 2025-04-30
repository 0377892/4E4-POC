### 1. Installer les dépendances système
#### 1.1 Git
Téléchargez et installez depuis : https://git-scm.com/

#### 1.2 Python 3.11+

Téléchargez depuis : https://python.org

Lors de l’installation, cochez `« Add Python to PATH »`.

#### 1.3 PostgreSQL

Téléchargez et installez depuis : https://www.postgresql.org/download/windows/

Notez bien le mot de passe du super-utilisateur que vous choisissez.

Vérifiez que ``pgAdmin`` est installé.

#### 1.4 Android Studio & SDK

Téléchargez depuis : https://developer.android.com/studio

Lancez ``Android Studio`` → ``SDK Manager``, installez :

``Android SDK Platform-Tools``

``Android SDK Build-Tools`` (dernière version)

Au moins une ``API Android`` (par ex. API 33)

#### 1.5 Flutter SDK

Téléchargez l’archive depuis : https://flutter.dev/docs/get-started/install/windows

Extrayez dans ``C:\src\flutter``

Dans ``Propriétés système`` → ``Variables d’environnement``, ajoutez ``C:\src\flutter\bin`` à votre ``PATH``

Ouvrez un nouveau PowerShell et tapez :
```ps
flutter doctor
```

Suivez les instructions restantes (par ex. accepter les licences Android).


### 2. Extensions VS Code
Ouvrez VS Code et installez :

``Python`` (Microsoft)

``Django`` (batisteo.vscode-django)

``Flutter`` (Dart-Code.flutter)

``Dart`` (Dart-Code.dart-code)

``REST Client`` (humao.rest-client) — optionnel

``SQLTools`` + ``PostgreSQL driver`` — optionnel


### 3. Configuration de PostgreSQL
#### 3.1 Lancez pgAdmin et connectez-vous à votre serveur local.

#### 3.2 Créez un nouvel utilisateur
```ps
Nom : memedev
Mot de passe : memepw
Privilèges : cochez Can login.
```

#### 3.3 Créez une nouvelle base de données
```ps
Nom : meme_db
Propriétaire : memedev
```

Testez depuis PowerShell :
```ps
psql -U memedev -d meme_db -h localhost -W
# puis \dt pour lister les tables
```


### 4. Backend (Django + DRF)
#### 4.1 Clonez le dépôt
```ps
cd C:\Users\Frank Gervais\Documents\git
git clone https://…/backend_4e4.git
cd backend_4e4
```

#### 4.2 Créez et activez un virtualenv
```ps
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

#### 4.3 Installez les dépendances
```ps
pip install --upgrade pip
pip install django djangorestframework psycopg2-binary corsheaders drf-yasg pillow
```

#### 4.4 Configurez ``settings.py``
Dans ``backend_4e4/settings.py`` :
```python
DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.postgresql',
    'NAME': 'meme_db',
    'USER': 'memedev',
    'PASSWORD': 'memepw',
    'HOST': 'localhost',
    'PORT': '5432',
  }
}
ALLOWED_HOSTS = ['localhost', '127.0.0.1', '10.0.2.2']
CORS_ALLOW_ALL_ORIGINS = True
```

#### 4.5 Migrations & superuser
```python
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
# saisissez un email et un mot de passe
```

#### 4.6 Démarrez le serveur
```python
python manage.py runserver 0.0.0.0:8000
```


### 5. Frontend (Flutter)
#### 5.1 Clonez le dépôt
```ps
cd C:\Users\Frank Gervais\Documents\git
git clone https://…/frontend_4e4.git
cd frontend_4e4
```

#### 5.2 Ouvrez dans VS Code
```ps
code .
```

#### 5.3 Récupérez les packages
```ps
flutter pub get
```

#### 5.4 Vérifiez ``lib/api.dart`` contient bien :
```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

String get apiBase {
  if (kIsWeb) return 'http://localhost:8000/api';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
  return 'http://localhost:8000/api';
}
String apiLang = 'fr';  // ou 'en'
```

#### 5.5 Si flutter doctor indique un manque d’outils Android :
```ps
sdkmanager "platform-tools" "platforms;android-33" "cmdline-tools;latest"
flutter doctor --android-licenses
```


### 6. Configuration de l’émulateur Android
Dans ``Android Studio`` → ``AVD Manager``

Créez un ``Virtual Device`` (ex. Pixel 4)

Choisissez une image système (API 33)

Lancez l’émulateur

Vérifiez avec Flutter :
```ps
flutter devices
# doit lister 'emulator-5554'
```

### 7. Lancer & tester
#### 7.1 Backend en cours d’exécution :
```ps
python manage.py runserver 0.0.0.0:8000
```

#### 7.2 Frontend sur l’émulateur Android :
```ps
flutter run -d emulator-5554
```

#### 7.3 Frontend sur Chrome (web) :
```ps
flutter run -d chrome
```

Vous pouvez maintenant :

- Sélectionner des catégories

- Prévisualiser et générer des mèmes

- Enregistrer le mème sur l’appareil

🎉 Toutes nos félicitations, votre environnement de développement Django/Flutter/PostgreSQL est prêt !