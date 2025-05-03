// ignore_for_file: public_member_api_docs, sort_constructors_first

class TodoModel {
  String titulo;
  bool finalizado;

  TodoModel(this.titulo, this.finalizado);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'titulo': titulo, 'finalizado': finalizado};
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(map['titulo'] as String, map['finalizado'] as bool);
  }
}
