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
git clone <url-do-repo>
cd <nome-do-repo>

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
const bool kUseMockApi = true; // true = offline/local, false = usa API
const String kBaseUrl = 'https://sua.api.com';
```

* `true` → as tarefas são salvas e lidas localmente (offline-first)
* `false` → o app usa a API remota (via Dio)

---

## 🛠️ Troubleshooting

* **Tarefas não aparecem após criar** → verifique se o mesmo `TaskBloc` está sendo compartilhado entre telas (use ShellRoute ou BlocProvider no topo).
* **Toggle ou filtros não funcionam** → confirme que está no modo local (`kUseMockApi = true`) e que o datasource está salvando corretamente.
* **Erro no iOS** → rode `cd ios && pod install` e confira a versão mínima do iOS no `Podfile`.

---

## 🗺️ Roadmap

* Sincronização entre local ↔️ remoto
* Busca por texto
* Notificações de vencimento
* Testes automatizados (unitários e de UI)

---

## 📄 Licença

Adicione aqui a licença desejada (MIT, Apache 2.0, etc).

---

Quer que eu crie também uma **versão em inglês** do README (para deixar o projeto mais apresentável no GitHub) ou prefere manter apenas em português?
