import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/class_model.dart';

class NameService {
  final String collectionName;
  final CollectionReference _nameCollection;

  NameService(this.collectionName)
      : _nameCollection = FirebaseFirestore.instance.collection(collectionName);

  Future<void> addName(CDModel name) {
    return _nameCollection.add(name.toMap());
  }

  Stream<List<CDModel>> getNames() {
    return _nameCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CDModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Update
  Future<void> updateName(CDModel name) {
    return _nameCollection.doc(name.id).update(name.toMap());
  }

  // Delete
  Future<void> deleteName(String id) {
    return _nameCollection.doc(id).delete();
  }

  Future<String?> getNameById(String id) async {
    try {
      DocumentSnapshot doc = await _nameCollection.doc(id).get();
      if (doc.exists) {
        // Adjust to get the specific field from the document
        final data = doc.data() as Map<String, dynamic>;
        return data['name'] as String?; // Assuming 'name' is the field you want to return
      } else {
        return null; // Document does not exist
      }
    } catch (e) {
      print('Failed to fetch name: $e');
      return null; // Handle error as appropriate
    }
  }




}
