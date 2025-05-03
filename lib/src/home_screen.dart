import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:to_do/src/models/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _toDoController = TextEditingController();

  List<TodoModel> _toDoList = [];

  final List<TodoModel> _ultimosRemovidos = [];
  int? _ultimoRemovidoPosicao;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      if (data != null) {
        setState(() {
          final List dados = json.decode(data);
          _toDoList = List.generate(
            dados.length,
            (index) => TodoModel.fromMap(dados[index]),
          );
        });
      }
    });
  }

  void _addToDo() {
    setState(() {
      var newToDo = TodoModel(_toDoController.text, false);
      _toDoController.text = "";

      _toDoList.add(newToDo);

      _saveData();
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b) {
        if (a.finalizado && !b.finalizado) {
          return 1;
        } else if (!a.finalizado && b.finalizado) {
          return -1;
        } else {
          return 0;
        }
      });

      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                ElevatedButton(onPressed: _addToDo, child: Text("ADD")),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: buildItem,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index].titulo),
        value: _toDoList[index].finalizado,
        secondary: CircleAvatar(
          child: Icon(_toDoList[index].finalizado ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _toDoList[index].finalizado = c ?? false;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _ultimosRemovidos.add(_toDoList[index]);
          _ultimoRemovidoPosicao = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text(
              "Tarefa \"${_ultimosRemovidos.last.titulo}\" removida!",
            ),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  if (_ultimoRemovidoPosicao != null) {
                    _toDoList.insert(
                      _ultimoRemovidoPosicao!,
                      _ultimosRemovidos.last,
                    );
                  }
                  // _saveData();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );

          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList.map((e) => e.toMap()).toList());

    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
