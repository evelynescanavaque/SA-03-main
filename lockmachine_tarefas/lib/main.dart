import 'package:flutter/material.dart';

import 'formulario.dart';
import 'tarefa.dart';
import 'tarefa_service.dart';

// Vermelho da identidade visual do LockMachine
const vermelho = Color(0xFFE63946);

void main() => runApp(const LockMachineApp());

class LockMachineApp extends StatelessWidget {
  const LockMachineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LockMachine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: vermelho,
          onPrimary: Colors.white,
          surface: Color(0xFF17191E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0E11),
      ),
      home: const TelaTarefas(),
    );
  }
}

/// Tela principal: lista as tarefas da API e permite cadastrar, editar e excluir.
class TelaTarefas extends StatefulWidget {
  const TelaTarefas({super.key});

  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  final _service = TarefaService();
  late Future<List<Tarefa>> _tarefas = _service.listar(); // GET ao abrir o app

  // Busca a lista de novo (botão de atualizar ou puxar a lista para baixo)
  Future<void> _recarregar() async {
    setState(() => _tarefas = _service.listar());
    await _tarefas.catchError((_) => <Tarefa>[]); // o erro já aparece na tela
  }

  // Espera o POST, PUT ou DELETE, mostra a mensagem da API e atualiza a lista
  Future<void> _executar(Future<String> requisicao) async {
    String mensagem;
    try {
      mensagem = await requisicao;
    } catch (erro) {
      mensagem = '$erro';
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
    _recarregar();
  }

  // Sem tarefa = cadastrar (POST). Com tarefa = alterar (PUT).
  Future<void> _abrirFormulario([Tarefa? tarefa]) async {
    final preenchida = await Navigator.push<Tarefa>(
      context,
      MaterialPageRoute(builder: (_) => TelaFormulario(tarefa: tarefa)),
    );
    if (preenchida == null) return; // voltou sem salvar
    _executar(tarefa == null ? _service.cadastrar(preenchida) : _service.alterar(preenchida));
  }

  // Pede confirmação e exclui (DELETE)
  Future<void> _excluir(Tarefa tarefa) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('"${tarefa.titulo}" será apagada da API para todos os grupos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmou == true) _executar(_service.excluir(tarefa.id!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.lock_outline, color: vermelho),
        title: const Text.rich(
          TextSpan(text: 'Lock', children: [
            TextSpan(text: 'Machine', style: TextStyle(color: vermelho)),
            TextSpan(text: '  Tarefas', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ]),
        ),
        actions: [
          IconButton(onPressed: _recarregar, icon: const Icon(Icons.refresh), tooltip: 'Atualizar'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
      body: FutureBuilder<List<Tarefa>>(
        future: _tarefas,
        builder: (context, snapshot) {
          // Carregando
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // Falha na comunicação com a API
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: vermelho),
                    const SizedBox(height: 12),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _recarregar, child: const Text('Tentar novamente')),
                  ],
                ),
              ),
            );
          }

          final tarefas = snapshot.data!;
          if (tarefas.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa cadastrada.'));
          }
          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 88), // 88 = espaço do botão
              itemCount: tarefas.length,
              itemBuilder: (context, i) => _cartao(tarefas[i]),
            ),
          );
        },
      ),
    );
  }

  // Cartão de uma tarefa: toque para editar, lixeira para excluir
  Widget _cartao(Tarefa tarefa) {
    final cor = {'alta': vermelho, 'media': Colors.amber, 'baixa': Colors.lightGreen}[tarefa.prioridade];
    return Card(
      child: ListTile(
        onTap: () => _abrirFormulario(tarefa),
        leading: Icon(
          tarefa.concluida ? Icons.check_circle : Icons.radio_button_unchecked,
          color: tarefa.concluida ? Colors.green : Colors.grey,
        ),
        title: Text(tarefa.titulo),
        subtitle: Text.rich(
          TextSpan(children: [
            if (tarefa.descricao.isNotEmpty) TextSpan(text: '${tarefa.descricao}\n'),
            TextSpan(
              text: (Tarefa.prioridades[tarefa.prioridade] ?? tarefa.prioridade).toUpperCase(),
              style: TextStyle(color: cor, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: '  ·  ${Tarefa.situacoes[tarefa.status] ?? tarefa.status}  ·  #${tarefa.id}'),
          ]),
        ),
        trailing: IconButton(
          onPressed: () => _excluir(tarefa),
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Excluir',
        ),
      ),
    );
  }
}
