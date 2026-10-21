/// Uma tarefa da API. Os campos têm os mesmos nomes do JSON.
class Tarefa {
  final int? id; // null enquanto a tarefa ainda não foi cadastrada
  final String titulo;
  final String descricao;
  final String prioridade;
  final String status;
  final String criadoEm;

  // Valores aceitos pela API -> texto mostrado na tela
  static const prioridades = {'baixa': 'Baixa', 'media': 'Média', 'alta': 'Alta'};
  static const situacoes = {'pendente': 'Pendente', 'concluida': 'Concluída'};

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    required this.status,
    this.criadoEm = '',
  });

  // JSON recebido da API -> objeto Tarefa
  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: int.tryParse('${json['id']}'), // a API manda o id como número ou texto
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      prioridade: json['prioridade'] ?? 'media',
      status: json['status'] ?? 'pendente',
      criadoEm: json['criado_em'] ?? '',
    );
  }

  // Objeto Tarefa -> JSON enviado no POST e no PUT
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'prioridade': prioridade,
      'status': status,
    };
  }

  bool get concluida => status == 'concluida';
}
