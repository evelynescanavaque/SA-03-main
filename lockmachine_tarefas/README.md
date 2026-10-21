# LockMachine Tarefas (SA03 de PDM)

App Flutter que consome a API REST de tarefas do professor, com a identidade visual do TCC LockMachine.
A lista mostra as tarefas de **todos os grupos**, e o que cadastramos aqui também aparece para eles.

## O que o app faz

| Ação no app | Método HTTP |
|---|---|
| Abrir o app, botão de atualizar ou puxar a lista para baixo | **GET** |
| Botão **Nova tarefa** | **POST** |
| Tocar em uma tarefa para editar | **PUT** |
| Ícone de lixeira (pede confirmação) | **DELETE** |

## Arquivos (tudo em `lib/`)

| Arquivo | Função |
|---|---|
| `main.dart` | Tema do LockMachine e tela da lista |
| `formulario.dart` | Formulário de cadastro e edição |
| `tarefa.dart` | Classe `Tarefa`: conversão de/para JSON |
| `tarefa_service.dart` | Requisições HTTP com `async`/`await`, `Future` e tratamento de erros |

## Como rodar

1. Abra o emulador Android (Pixel_6) ou conecte um celular que esteja na rede da escola.
2. No terminal, dentro desta pasta:

```bash
flutter pub get
```

```bash
flutter run
```

- O endereço da API fica em `lib/tarefa_service.dart`. Se o professor mudar o IP, troque só ali.
- Não rode no Chrome: a API não libera CORS, então o navegador bloqueia as requisições.
