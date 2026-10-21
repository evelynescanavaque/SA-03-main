import 'dart:convert';

import 'package:http/http.dart' as http;

import 'tarefa.dart';

/// Comunicação com a API REST do professor (GET, POST, PUT e DELETE).
class TarefaService {
  // Endereço informado pelo professor
  static const url = 'http://10.140.170.19/pdm_api/tarefas.php';
  static const _cabecalhos = {'Content-Type': 'application/json; charset=UTF-8'};

  // GET: busca as tarefas de todos os grupos
  Future<List<Tarefa>> listar() async {
    final json = await _enviar(http.get(Uri.parse(url)));
    final List dados = json['dados'] ?? [];
    return dados.map((item) => Tarefa.fromJson(item)).toList();
  }

  // POST: cadastra uma nova tarefa
  Future<String> cadastrar(Tarefa tarefa) async {
    final json = await _enviar(http.post(
      Uri.parse(url),
      headers: _cabecalhos,
      body: jsonEncode(tarefa.toJson()),
    ));
    return json['mensagem'] ?? 'Tarefa cadastrada.';
  }

  // PUT: altera a tarefa do id informado
  Future<String> alterar(Tarefa tarefa) async {
    final json = await _enviar(http.put(
      Uri.parse('$url?id=${tarefa.id}'),
      headers: _cabecalhos,
      body: jsonEncode(tarefa.toJson()),
    ));
    return json['mensagem'] ?? 'Tarefa alterada.';
  }

  // DELETE: exclui a tarefa do id informado
  Future<String> excluir(int id) async {
    final json = await _enviar(http.delete(Uri.parse('$url?id=$id')));
    return json['mensagem'] ?? 'Tarefa excluída.';
  }

  // Espera a resposta, converte o JSON e transforma qualquer falha em ApiException
  Future<Map<String, dynamic>> _enviar(Future<http.Response> requisicao) async {
    final http.Response resposta;
    try {
      resposta = await requisicao.timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException('Não foi possível conectar à API. Verifique a rede.');
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(resposta.bodyBytes));
    } catch (_) {
      throw ApiException('Resposta inválida da API (HTTP ${resposta.statusCode}).');
    }

    // A API responde {"sucesso": false, "mensagem": "..."} quando algo dá errado
    if (json['sucesso'] != true) {
      throw ApiException(json['mensagem'] ?? 'Erro ${resposta.statusCode} na API.');
    }
    return json;
  }
}

/// Erro com uma mensagem pronta para mostrar na tela.
class ApiException implements Exception {
  final String mensagem;
  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}
