# Guia de Instalação – Oficina "Do App à API: Flutter, Java e IA generativa com OpenCode "

**Tecnologias:** Flutter, Spring Boot (Java), OpenCode
**IDEs:** Android Studio (Flutter) e IntelliJ IDEA (Spring Boot)
**Sistema operacional:** Windows 10 ou 11 (64 bits)
**Tempo estimado de instalação:** 1h a 1h30, dependendo da velocidade da internet

Este guia deve ser feito **antes** da oficina. Durante o evento não haverá tempo para resolver problemas de instalação, então, se algum passo falhar, anote a mensagem de erro e consulte a seção de [Problemas comuns](#9-problemas-comuns).

---

## Requisitos mínimos

| Item | Mínimo recomendado |
|---|---|
| Sistema operacional | Windows 10 ou 11 (64 bits) |
| Memória RAM | 16 GB (8 GB funcionam, mas o emulador Android fica lento) |
| Espaço em disco | 25 GB livres |
| Processador | Com suporte a virtualização (Intel VT-x ou AMD-V) habilitado na BIOS |

> **Dica:** para verificar a virtualização, abra o **Gerenciador de Tarefas** → aba **Desempenho** → **CPU**. Se aparecer "Virtualização: Habilitada", está tudo certo.

---

## Ordem de instalação

1. Git
2. Node.js (LTS)
3. JDK 17
4. Android Studio
5. Flutter SDK
6. Configuração do Flutter e do Android (`flutter doctor`)
7. IntelliJ IDEA
8. OpenCode
9. Problemas comuns
10. Checklist final de verificação

---

## 1. Git

O Git será usado na oficina para versionar o código e clonar o repositório de apoio.

### Instalação

1. Acesse https://git-scm.com/downloads e baixe o instalador para Windows.
2. Execute o instalador e mantenha as opções padrão. Na tela **"Choosing the default editor"** pode escolher o VS Code ou deixar o Vim.
3. Na tela **"Adjusting your PATH environment"**, mantenha a opção recomendada **"Git from the command line and also from 3rd-party software"**.
4. Conclua a instalação.

### Verificação

```powershell
git --version
```

**Resultado esperado:** algo como `git version 2.45.0.windows.1`. Qualquer versão 2.x serve.

---

## 2. Node.js (LTS)

O Node.js é necessário para instalar o OpenCode pelo npm.

1. Acesse https://nodejs.org e baixe a versão **LTS**.
2. Execute o instalador com as opções padrão.
3. **Feche e reabra** o PowerShell após a instalação.

### Verificação

```powershell
node --version
npm --version
```

**Resultado esperado:** `v20.x.x` ou superior para o Node, e `10.x.x` ou superior para o npm.

---

## 3. JDK 17 (Java)

O Spring Boot 3.x exige Java 17 ou superior. Usaremos o **JDK 17**, uma versão LTS (suporte de longo prazo).

> **Atenção:** o Android Studio já traz um JDK próprio (JBR), usado pelo Flutter. Mesmo assim, o Spring Boot precisa de um JDK instalado no sistema e com a variável `JAVA_HOME` configurada. Por isso instalamos o JDK 17 separadamente.

### Instalação

1. Acesse https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html.
2. Na seção **Windows**, baixe o instalador **x64 Installer** (arquivo `jdk-17.0.x_windows-x64_bin.exe`). Pode ser necessário entrar com uma conta Oracle gratuita e aceitar a licença para concluir o download.
3. Execute o instalador com as opções padrão. O JDK será instalado em `C:\Program Files\Java\jdk-17.0.x`.

### Configuração manual do JAVA_HOME

1. Pesquise por **"Editar as variáveis de ambiente do sistema"** no menu Iniciar.
2. Clique em **Variáveis de Ambiente**.
3. Em **Variáveis do usuário**, clique em **Novo**:
   - Nome: `JAVA_HOME`
   - Valor: o caminho exato da instalação, por exemplo `C:\Program Files\Java\jdk-17.0.12` (ajuste para a versão que você baixou)
4. Ainda em **Variáveis do usuário**, selecione **Path**, clique em **Editar**, depois em **Novo**, e adicione: `%JAVA_HOME%\bin`
5. Clique em **OK** em todas as janelas e **feche e reabra** o PowerShell.

### Verificação

```powershell
java -version
javac -version
echo $env:JAVA_HOME
```

**Resultado esperado:**
- `java -version` mostra `openjdk version "17.0.x"`.
- `javac -version` mostra `javac 17.0.x`.
- `JAVA_HOME` aponta para a pasta do JDK 17.

---

## 4. Android Studio

O Android Studio é a IDE que usaremos para o Flutter. Ele também instala o **Android SDK** e o **emulador**, necessários para rodar o app em um celular virtual.

### Instalação

1. Acesse https://developer.android.com/studio e baixe o Android Studio.
2. Execute o instalador com as opções padrão. Mantenha marcadas as opções de **Android Virtual Device** e **Android SDK**.
3. Na primeira abertura, escolha **Standard** no assistente de configuração.
4. Aceite as licenças e aguarde o download dos componentes (pode levar de 10 a 20 minutos).

Por padrão, o SDK fica em `C:\Users\SEU_USUARIO\AppData\Local\Android\Sdk`.

### Instalação dos plugins Flutter e Dart

1. Abra o Android Studio e vá em **File → Settings**.
2. Clique em **Plugins**, aba **Marketplace**.
3. Pesquise por **Flutter** e clique em **Install**. O **Dart** é instalado junto automaticamente.
4. Reinicie o Android Studio quando solicitado.

### Verificação

- Em **File → Settings → Languages & Frameworks → Android SDK**, confira que o **Android SDK Location** aponta para a pasta indicada acima.
- Na aba **SDK Platforms**, marque **Android 14.0 (API 34)** ou superior e clique em **Apply**, se ainda não estiver instalado.
- Na aba **SDK Tools**, confirme que estão marcados: **Android SDK Build-Tools**, **Android SDK Command-line Tools (latest)**, **Android Emulator** e **Android SDK Platform-Tools**.

---

## 5. Flutter SDK

### Instalação

1. Acesse h[ttps://docs.flutter.dev/install/manual](https://docs.flutter.dev/install/manual#install-flutter) e baixe o arquivo **zip** do Flutter SDK (versão estável).
2. **Extraia o zip em uma pasta sem espaços e sem acentos**, por exemplo `C:\src\flutter`.
   > **Não** instale em `C:\Program Files`, pois o Flutter precisa de permissão de escrita nessa pasta.
3. Adicione o Flutter ao PATH:
   1. Pesquise por **"Editar as variáveis de ambiente do sistema"**.
   2. Em **Variáveis do usuário**, selecione **Path** e clique em **Editar**.
   3. Clique em **Novo** e adicione: `C:\src\flutter\bin`
   4. Confirme em OK em todas as janelas.
4. Feche e reabra o PowerShell.

### Verificação

```powershell
flutter --version
```

**Resultado esperado:** uma linha com `Flutter 3.x.x` e a versão do Dart, por exemplo `Dart 3.x.x`.

---

## 6. Configuração do Flutter e do Android (`flutter doctor`)

O comando `flutter doctor` verifica se todo o ambiente está pronto.

### Passo 1: aceitar as licenças do Android

```powershell
flutter doctor --android-licenses
```

Pressione `y` para aceitar cada licença.

### Passo 2: rodar o diagnóstico

```powershell
flutter doctor -v
```

### Resultado esperado

Os itens abaixo devem aparecer com **[✓]**:

```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Windows Version (...)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.x.x)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2024.x)
[✓] Connected device (1 available)
[✓] Network resources
```

**Notas:**
- **[!] Visual Studio** aparece como aviso quando não está instalado. **Pode ser ignorado**, pois não é necessário para Android.
- **Connected device** só aparece com um emulador aberto ou um celular conectado (ver passo 3).
- Se aparecer `cmdline-tools component is missing`, abra o Android Studio, vá em **SDK Tools** e instale **Android SDK Command-line Tools (latest)**. Depois rode o `flutter doctor` novamente.

### Passo 3: criar e iniciar um emulador Android

1. No Android Studio, clique em **More Actions → Virtual Device Manager** (ou **Tools → Device Manager**).
2. Clique em **Create Device**.
3. Escolha um celular, por exemplo **Pixel 7**, e clique em **Next**.
4. Selecione uma imagem de sistema **Android 14 (API 34)** ou superior, clique em **Download** se necessário e depois em **Next** e **Finish**.
5. Clique no botão **▶ (Play)** ao lado do dispositivo para iniciá-lo.

Aguarde o emulador carregar a tela inicial do Android antes de continuar.

### Passo 4: verificar o dispositivo

```powershell
flutter devices
```

**Resultado esperado:** uma linha com o emulador, por exemplo `sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android 14 (API 34)`.

> **Se o emulador não abrir:** ative o **Windows Hypervisor Platform** em *Painel de Controle → Programas → Ativar ou desativar recursos do Windows*, reinicie o computador e tente de novo. Também verifique se a virtualização está ativa na BIOS.

---

## 7. IntelliJ IDEA

O IntelliJ será usado para o backend em Spring Boot. Pode ser a versão **Community** (gratuita) ou **Ultimate**. A Community é suficiente para esta oficina.

### Instalação

1. Acesse https://www.jetbrains.com/idea/download e baixe a versão **Community** (ou Ultimate, se tiver acesso).
2. Execute o instalador com as opções padrão.
3. Na primeira abertura, escolha o tema de sua preferência e aceite os termos.

### Configuração do JDK

1. Abra o IntelliJ e vá em **File → Settings**.
2. Vá em **Build, Execution, Deployment → Build Tools → Maven → Runner**.
3. Em **JRE**, selecione o JDK 17 (se aparecer na lista).

Caso o JDK 17 não apareça:
1. Vá em **File → Project Structure → SDKs**.
2. Clique em **+** → **Add JDK...** e aponte para a pasta do JDK 17 (ex.: `C:\Program Files\Eclipse Adoptium\jdk-17.0.x-hotspot`).

### Verificação

Confirme que o IntelliJ abre sem erros e que, em **File → Project Structure → Project**, o **SDK** está como **17**.

---

## 8. OpenCode

O OpenCode é um agente de programação para o terminal. Vamos usá-lo para gerar código a partir de prompts durante a oficina.

### Instalação via npm

Com o Node.js já instalado (passo 2), execute no PowerShell:

```powershell
npm install -g @opencode/cli
```

Consulte a documentação em https://opencode.ai/docs caso o comando tenha mudado.

### Verificação da instalação

```powershell
opencode --version
```

**Resultado esperado:** um número de versão, por exemplo `1.x.x`.

---

## 9. Problemas comuns

| Problema | Solução |
|---|---|
| `flutter` não é reconhecido como comando | O PATH não foi configurado ou o PowerShell não foi reaberto. Feche todas as janelas e abra de novo. |
| `java` não é reconhecido, ou mostra versão diferente de 17 | Confirme o `JAVA_HOME` e o `%JAVA_HOME%\bin` no Path. Se houver outro Java instalado, remova-o do Path ou deixe o JDK 17 primeiro na lista. |
| `flutter doctor` mostra erro no Android toolchain | Execute `flutter doctor --android-licenses` e instale os componentes sugeridos no SDK Manager do Android Studio. |
| Emulador não inicia ou está muito lento | Verifique a virtualização na BIOS, ative o Windows Hypervisor Platform e aumente a memória RAM do emulador em **Device Manager → Edit**. |
| Erro "Unable to locate Android SDK" | Abra o Android Studio, vá em **Settings → Android SDK** e confirme o caminho. Depois rode `flutter config --android-sdk "CAMINHO_DO_SDK"`. |
| `opencode` não é reconhecido | Feche e reabra o PowerShell. Confirme o caminho do npm global com `npm config get prefix` e verifique se ele está no Path. |
| Erro de rede nos downloads | Verifique se o firewall ou proxy não bloqueia os domínios `flutter.dev`, `dart.dev`, `pub.dev`, `google.com`, `opencode.ai` e `github.com`. |

---

## 10. Checklist final de verificação

Marque cada item após executar o comando correspondente. **Leve este checklist preenchido para a oficina.**

| # | Ferramenta | Comando de verificação | Resultado esperado | OK |
|---|---|---|---|---|
| 1 | Git | `git --version` | `git version 2.x.x` | ☐ |
| 2 | Node.js | `node --version` | `v20.x.x` ou superior | ☐ |
| 3 | npm | `npm --version` | `10.x.x` ou superior | ☐ |
| 4 | Java | `java -version` | `openjdk version "17.x.x"` | ☐ |
| 5 | JAVA_HOME | `echo $env:JAVA_HOME` | Caminho do JDK 17 | ☐ |
| 6 | Android Studio | Abre sem erros, com plugins Flutter e Dart instalados | Plugins listados em Settings → Plugins | ☐ |
| 7 | Android SDK | Android Studio → Settings → Android SDK | SDK Platform API 34 ou superior instalada | ☐ |
| 8 | Flutter | `flutter --version` | `Flutter 3.x.x` | ☐ |
| 9 | Licenças Android | `flutter doctor --android-licenses` | Todas aceitas | ☐ |
| 10 | Flutter doctor | `flutter doctor` | `[✓] Flutter` e `[✓] Android toolchain` | ☐ |
| 11 | Emulador | `flutter devices` (com emulador aberto) | Dispositivo Android listado | ☐ |
| 12 | IntelliJ IDEA | Abre sem erros, JDK 17 configurado | SDK do projeto = 17 | ☐ |
| 13 | OpenCode | `opencode --version` | Número de versão exibido | ☐ |


Se algum item não funcionar mesmo após a seção de problemas comuns, anote o comando executado e a mensagem de erro completa e entre em contato.
