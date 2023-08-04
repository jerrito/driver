import 'package:flutter/foundation.dart';
import 'package:driver/databases/firebase_services.dart';
import 'package:driver/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerProvider extends ChangeNotifier {
  final SharedPreferences? preferences;
  final firebaseService = FirebaseServices();

  CustomerProvider({required this.preferences}) {
    var appUserString = preferences?.getString("app_user") ?? '';
    _appUser = appUserString.isNotEmpty ? Customer.fromString(appUserString) : null;
  }

  Customer? _appUser;
  Customer? get appUser => _appUser;

  set appUser(Customer? a) {
    _appUser = a;
    notifyListeners();

    preferences?.setString(
      "app_user",
      a?.toString() ?? '',
    );
  }

  Future<QueryResult<Customer>?>? getUser({required String phoneNumber}) async {
    var result = await firebaseService.getUser(phoneNumber: phoneNumber);

    if (result?.status == QueryStatus.successful && result?.data != null) {
      appUser = result?.data;
    }

    return result;
  }

  Future<QueryResult<Customer>?>? getUser_2(
      {required String phoneNumber, required String password}) async {
    var result = await firebaseService.getUser_2(
        phoneNumber: phoneNumber, password: password);

    if (result?.status == QueryStatus.successful && result?.data != null) {
      appUser = result?.data;
    }

    return result;
  }

  Future<QueryResult<Customer>?>? updateUser({required Customer customer}) async {
    var result = await firebaseService.updateUser(customer: customer);

    if (result?.status == QueryStatus.successful) {
      await getUser(phoneNumber: customer.number ?? "");
    }

    return result;
  }
}

