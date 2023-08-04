import 'package:flutter/material.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(
                height: 20,
              ),
              Text(
                "Our Address",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text("Eastern \nBP \nAK-071-6540"),
              Text("Email Us",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text("jerrito0240@gmail.com"),
            ]),
      ),
    );
  }
}
