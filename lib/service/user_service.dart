import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user_model.dart';

class UserService {
  final String collectionName;
  final CollectionReference _userCollection;

  UserService(this.collectionName)
      : _userCollection = FirebaseFirestore.instance.collection(collectionName);

  Future<void> addUser(UserModel user) {
    return _userCollection.doc(user.id).set(user.toMap());
  }

  Stream<List<UserModel>> getUsers() {
    return _userCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> updateUser(UserModel user) {
    return _userCollection.doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String id) {
    return _userCollection.doc(id).delete();
  }
}
