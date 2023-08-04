import 'dart:convert';

import 'package:driver/databases/firebase_services.dart';


class Customer implements Serializable {
  String? fullName;
  String? number;
  String? email;
  String? password;
  String? id;
  String? image;
  String? location;
  double? latitude;
  double? longitude;

  Customer({
    this.fullName,
    this.number,
    this.id,
    this.email,
    this.password,
    this.image,
    this.location,
    this.latitude,
    this.longitude,
  });
  factory Customer.fromJson(Map? json) => Customer(
        id: json?["id"],
        fullName: json?["fullName"],
        number: json?["number"],
        email: json?["email"],
        password: json?["password"],
        image: json?["image"],
        location: json?["location"],
        latitude: json?["latitude"],
       longitude: json?["longitude"],
      );
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      "fullName": fullName,
      "number": number,
      "password": password,
      "email": email,
      "image": image,
      "location": location,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  static Customer fromString(String userString) {
    return Customer.fromJson(jsonDecode(userString));
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
