import 'package:flutter/material.dart';

import 'tarefa.dart';

/// Formulário de cadastro (POST) e de edição (PUT) de uma tarefa.
class TelaFormulario extends StatefulWidget {
  final Tarefa? tarefa; // null = nova tarefa

  const TelaFormulario({super.key, this.tarefa});

  @override
  State<TelaFormulario> createState() => _TelaFormularioState();
}

class _TelaFormularioState extends State<TelaFormulario> {
  final _form = GlobalKey<FormState>();
  late String _titulo = widget.tarefa?.titulo ?? '';
  late String _descricao = widget.tarefa?.descricao ?? '';
  late String _prioridade = _valido(widget.tarefa?.prioridade, Tarefa.prioridades, 'media');
  late String _status = _valido(widget.tarefa?.status, Tarefa.situacoes, 'pendente');

  // Se a API devolver um valor fora da lista, usa o padrão (evita erro no Dropdown)
  String _valido(String? valor, Map<String, String> opcoes, String padrao) {
    return opcoes.containsKey(valor) ? valor! : padrao;
  }

  String? _obrigatorio(String? texto) {
    return (texto ?? '').trim().isEmpty ? 'Campo obrigatório' : null;
  }

  // Valida e devolve a tarefa preenchida para a tela da lista
  void _salvar() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      Tarefa(
        id: widget.tarefa?.id,
        titulo: _titulo.trim(),
        descricao: _descricao.trim(),
        prioridade: _prioridade,
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.tarefa != null;
    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar tarefa' : 'Nova tarefa')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _titulo,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ex.: Testar leitor RFID da prensa',
              ),
              validator: _obrigatorio,
              onChanged: (texto) => _titulo = texto,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _descricao,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
              validator: _obrigatorio,
              onChanged: (texto) => _descricao = texto,
            ),
            const SizedBox(height: 16),
            _selecao('Prioridade', Tarefa.prioridades, _prioridade, (valor) => _prioridade = valor),
            const SizedBox(height: 16),
            _selecao('Status', Tarefa.situacoes, _status, (valor) => _status = valor),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save),
              label: Text(editando ? 'Salvar alterações' : 'Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }

  // Caixa de seleção só com os valores que a API aceita
  Widget _selecao(String rotulo, Map<String, String> opcoes, String valor, void Function(String) aoMudar) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      decoration: InputDecoration(labelText: rotulo),
      items: [
        for (final opcao in opcoes.entries)
          DropdownMenuItem(value: opcao.key, child: Text(opcao.value)),
      ],
      onChanged: (novo) => aoMudar(novo!),
    );
  }
}
