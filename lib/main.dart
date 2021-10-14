import 'package:flutter/material.dart';

import 'package:kytservices/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KYT SERVICES',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // all clients
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;

  // This  function is used to fetch all data from database
  void _refreshClients() async {
    final data = await SQLHelper.getClients();
    setState(() {
      _clients = data;
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _refreshClients(); // loading the lists when app starts
  }

  TextEditingController _namesController = new TextEditingController();
  TextEditingController _decoder_numberController = new TextEditingController();
  TextEditingController _locationController = new TextEditingController();
  TextEditingController _telephoneController = new TextEditingController();

  // This function will be triggered when the floating button is pressed
  void _showForm(int? id) async {
    if (id != null) {
      final existingClient = _clients.firstWhere((element) => element['id'] == id);
      _namesController.text = existingClient['names'];
      _decoder_numberController.text = existingClient['decoder_number'];
      _locationController.text = existingClient['location'];
      _telephoneController.text = existingClient['telephone'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      builder: (_) => Container(
        padding: EdgeInsets.all(15),
        width: double.infinity,
        height: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _namesController,
              decoration: InputDecoration(hintText: 'Noms du client'),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _decoder_numberController,
              decoration: InputDecoration(hintText: 'Numéro du décodeur'),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(hintText: 'Quartier du Client'),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _telephoneController,
              decoration: InputDecoration(hintText: 'Telephone')
            ),
            ElevatedButton(
              onPressed: () async {
                // save new client
                if (id == null){
                  await _addClient();
                }
                if (id != null) {
                  await _updateClient(id);
                }

                // clear the text fields
                _namesController.text = '';
                _decoder_numberController.text = '';
                _locationController.text = '';
                _telephoneController.text = '';

                // close the bottom sheet
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Ajouter' : 'Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }

  // insert a new client to the database
  Future<void> _addClient() async {
    await SQLHelper.createClient(_namesController.text, _decoder_numberController.text,
    _locationController.text, _telephoneController.text);
    _refreshClients();
  }

  // update an existing client
  Future<void> _updateClient(int id) async {
    await SQLHelper.updateClient(
      id, _namesController.text, _decoder_numberController.text, _locationController.text,
      _telephoneController.text
    );
    _refreshClients();
  }

  // update a client
  Future<void> _deleteClient(int id) async {
    await SQLHelper.deleteClient(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Client supprimé avec succès"),
    ));
    _refreshClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KYT SERVICES")),
        body: _isLoading
          ? Center(
          child: CircularProgressIndicator(),
        )
            : ListView.builder(
          itemCount: _clients.length,
          itemBuilder: (context, index) => Card(
            color: Colors.orange[200],
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(_clients[index]['names']),
              subtitle: Text(_clients[index]['decoder_number']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showForm(_clients[index]['id']),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteClient(_clients[index]['id']),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _showForm(null),
        ),
    );
  }
}
