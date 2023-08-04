import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:driver/models/user.dart';

enum QueryStatus { successful, failed }

class QueryResult<T> {
  QueryStatus? status;
  T? data;
  dynamic error;

  QueryResult({this.status, this.data, this.error});
}

abstract class Serializable {
  Map<String, dynamic> toJson();
}

class FirebaseServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final usersRef = FirebaseFirestore.instance
      .collection('pashewDriverAccount')
      .withConverter<Customer>(
        fromFirestore: (snapshot, _) => Customer.fromJson(snapshot.data()!),
        toFirestore: (customer, _) => customer.toJson(),
      );


  Future<QueryResult<Customer>?> getUser({required String phoneNumber}) async {
    QueryResult<Customer>? result;
    return await usersRef
        .where("number", isEqualTo: phoneNumber)
        .get()
        .then((snapshot) {
      var userSnapShot = snapshot.docs;

      Customer? data;
      if (userSnapShot.isNotEmpty) {
        data = userSnapShot.first.data();
        data.id = userSnapShot.first.id;
        //data.id=
        print(data.id);
      }

      var status = QueryStatus.successful;

      result = QueryResult(
        status: status,
        data: data,
      );
      return result;
    }).catchError((error) {
      if (kDebugMode) {
        print("Failed to get user: $error");
      }
      var status = QueryStatus.failed;
      var errorMsg = error;
      result = QueryResult(status: status, error: errorMsg);

      return result;
    });
  }
  

  Future<QueryResult<Customer>?> getUser_2(
      {required String phoneNumber, required String password}) async {
    QueryResult<Customer>? result;

    //
    return await usersRef
        .where("number", isEqualTo: phoneNumber)
        .get()
        .then((snapshot) {
      var userSnapShot = snapshot.docs;

      Customer? data;
      if (userSnapShot.isNotEmpty) {
        data = userSnapShot.first.data();
        data.id = userSnapShot.first.id;
      }

      var status = QueryStatus.successful;

      result = QueryResult(
        status: status,
        data: data,
      );
      return result;
    }).catchError((error) {
      if (kDebugMode) {
        print("Failed to get user: $error");
      }
      var status = QueryStatus.failed;
      var errorMsg = error;
      result = QueryResult(status: status, error: errorMsg);

      return result;
    });
  }

  Future<QueryResult<Customer>?>? saveUser({required Customer user}) async {
    QueryResult<Customer>? result;

    //
    await usersRef.add(user).then((value) {
      result = QueryResult(status: QueryStatus.successful);
    }).catchError((error) {
      if (kDebugMode) {
        print("Failed to add user: $error");
      }
      result?.status = QueryStatus.failed;
      result?.error = error;
    });

    return result;
  }

  Future<QueryResult<Customer>?> updateUser({required Customer customer}) async {
    QueryResult<Customer>? result;
    print(customer.id);

    //
    await usersRef.doc(customer.id).update(customer.toJson()).then((value) {
      result = QueryResult(status: QueryStatus.successful);
    }).catchError((error) {
      if (kDebugMode) {
        print("Failed to update user: $error");
      }
      result?.status = QueryStatus.failed;
      result?.error = error;
    });

    return result;
  }
}

// class FirebaseAppCheckHelper {
//   FirebaseAppCheckHelper._();
//
//   static Future initialise() async {
//     await FirebaseAppCheck.instance.activate(
//       webRecaptchaSiteKey: 'recaptcha-v3-site-key',
//       androidProvider: _androidProvider(),
//     );
//   }
//
//   static AndroidProvider _androidProvider() {
//     if (kDebugMode) {
//       return AndroidProvider.debug;
//     }
//
//     return AndroidProvider.playIntegrity;
//   }
// }
