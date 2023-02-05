import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'input_chip.dart';

class PopupModal extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<PopupModal> {
  final _usernameController = TextEditingController();
  final _groupNameController = TextEditingController();
  final _frequencyController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _groupNameController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              20.0,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.only(
          top: 10.0,
        ),
        title: const Text(
          "Create your group",
          style: TextStyle(fontSize: 24.0),
        ),
        content: Container(
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Your name',
                    )),
                TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Group name',
                    )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChipsInput<String>(
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search), hintText: ''),
                      onChanged: _onChanged,
                      chipBuilder: (BuildContext context,
                          ChipsInputState<String> state, String profile) {
                        return InputChip(
                          key: ObjectKey(profile),
                          label: Text(profile),
                          onDeleted: () => state.deleteChip(profile),
                          onSelected: (_) => _onChipTapped(profile),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      },
                    ),
                  ),
                ),
                TextField(
                    controller: _frequencyController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Frequency',
                    )),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () => _onCreateTapped(),
                  child: const Text('Create'),
                )
              ],
            )));
  }

  void _onChanged(List<String> data) {
    print('onChanged $data');
  }

  void _onChipTapped(String profile) {
    print('$profile');
  }

  void _onCreateTapped() {
    DatabaseReference _testRef = FirebaseDatabase.instance.ref().child('users');
    // _testRef.update(Map)
  }
}
