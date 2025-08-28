# 📋 Task Manager (Flutter)

## 🚀 Sobre o Projeto

Este é um aplicativo de **gestão de tarefas** desenvolvido em **Flutter 3.27**, com suporte para **Android** e **iOS**.
A ideia central é ser **offline-first**, ou seja, as tarefas funcionam **localmente no dispositivo** (persistência local).
Se necessário, o app também pode trabalhar com **APIs remotas** para sincronização ou armazenamento externo.

### ✨ Funcionalidades

* Criar, editar e excluir tarefas
* Marcar tarefas como concluídas (toggle)
* Filtros por **status** (pendente, em andamento, concluída)
* Filtros por **período de vencimento**
* Persistência local (SharedPreferences / Secure Storage)
* Integração opcional com API usando **Dio**
* Arquitetura com **BLoC**, **GetIt** para injeção de dependências e **GoRouter** para navegação

---

## 🧱 Arquitetura

O projeto segue uma separação em camadas:

* **Presentation** → UI + Gerenciamento de estado (BLoC)
* **Domain** → Entidades e contratos de Repositórios
* **Data** → DataSources locais e remotos (API), Repositórios concretos
* **Core** → Utilitários e armazenamento seguro
* **DI** → Injeção de dependências centralizada com GetIt

---

## 🧰 Tecnologias

* **Flutter**: 3.27
* **Gerência de estado**: flutter\_bloc
* **Rotas**: go\_router
* **DI**: get\_it
* **HTTP Client**: dio
* **Persistência local**: shared\_preferences e flutter\_secure\_storage
* **Formatação de datas**: intl

---

## ⚙️ Como rodar o projeto

### Pré-requisitos

* Flutter 3.27 instalado
* Android SDK ou Emulador
* Xcode + CocoaPods (para iOS)

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/gustavorodrii/pluxee_task.git
cd main

# 2. Instale as dependências
flutter pub get

# 3. (iOS) instale os pods
cd ios
pod install
cd ..

# 4. Rode no dispositivo/emulador
flutter run
```

---

## 🔀 Alternando entre **Local** e **API**

O comportamento é controlado em **`config.dart`**:

```dart
const bool kUseMockApi = true; 
const String kBaseUrl = 'https://backend.com';
```

* `true` → as tarefas são salvas e lidas localmente (offline-first)
* `false` → o app usa a API remota (via Dio)


