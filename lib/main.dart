import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final dummySnapShot = [
  {"name": "Filip", "votes": 15},
  {"name": "Abraham", "votes": 14},
  {"name": "Richard", "votes": 11},
  {"name": "Ike", "votes": 10},
  {"name": "Justin", "votes": 1},
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Baby Names",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _MyHomePage();
  }

}

class _MyHomePage extends State<MyHomePage>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Baby Name Votes"),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("baby").snapshots(),//Get snapshot from a collection
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot){
    return ListView(
      padding: const EdgeInsets.only(top: 20),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  void updateVotes(dynamic record) {
    LinearProgressIndicator();
    Firestore.instance.runTransaction((transaction) async {
      final freshSnapshot = await transaction.get(record.reference);
      final fresh = Record.fromSnapshot(freshSnapshot);
      await transaction.update(record.reference, {"votes": fresh.votes + 1});
    });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color:  Colors.grey),
          borderRadius: BorderRadius.circular(5)
        ),
        child: ListTile(
          title: Text(
            record.name,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          trailing: Text(record.votes.toString()),
          onTap: () => updateVotes(record),
        ),
      ),
    );
  }
}

class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
    : assert(map['name'] != null),
      assert(map['votes'] != null),
      name = map['name'],
      votes = map['votes'];

  Record.fromSnapshot(DocumentSnapshot snapshot) 
    : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record <$name:$votes>";

}