import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_osm_interface/src/types/geo_point.dart' as geo;
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:driver/userProvider.dart';
import 'package:driver/widgets/MainButton.dart';
import 'package:driver/widgets/drawer.dart';
import 'package:driver/constants/Size_of_screen.dart';
import "package:provider/provider.dart";
import 'package:sticky_headers/sticky_headers.dart';
class Order extends StatefulWidget {
  const Order({super.key});
  @override
  State<Order> createState() => _OrderState();
}
class _OrderState extends State<Order> {
  CustomerProvider? customerProvider;
  bool driverRefresh=true;

  final mapController = MapController.withUserPosition(
    trackUserLocation: const UserTrackingOption(
      enableTracking: false,
      unFollowUser: true,
    ),
    //areaLimit: BoundingBox.
  );


  int dateSubtract=0;
  Stream<QuerySnapshot<Map<String, dynamic>>> allOrders(){
    var stringList =  DateTime.now().toIso8601String().split(RegExp(r"[T\.]"));

    var formatedDate = stringList[0];
    // print("2023-08-01");
    // print("gg");
    var date=formatedDate.replaceAll("-", "");
    if(date.endsWith("01")==true){
      var li= DateTime.now().subtract(const Duration(days:1))
          .toIso8601String().split(RegExp(r"[T\.]"));
      var formatedDate=li[0];
      var date=formatedDate.replaceAll("-", "");
      int dateGet=int.parse(date)-dateSubtract;
      dateGet=int.parse("${dateGet}000000");
      //int dateInt=int.parse("${date}000000");
      // print("fee");
      // print(dateGet);
      final products= FirebaseFirestore.instance
          .collection("Orders")
          .where("date",isGreaterThanOrEqualTo:dateGet )
          //.where("driverName",isEqualTo: customerProvider?.appUser?.number)
          .where("driverNumber",isEqualTo: customerProvider?.appUser?.number)
          .snapshots();
      return products;
    }

    else{
      int dateGet=int.parse(date)-dateSubtract;
      dateGet=int.parse("${dateGet}000000");
      // print("hee");
      // print(date);
      // print(dateGet);

      final products= FirebaseFirestore.instance
          .collection("Orders")
          .where("date",isGreaterThanOrEqualTo:dateGet )
          .where("driverNumber",isEqualTo: customerProvider?.appUser?.number)
          .snapshots();
      return products;

    }
  }






 late List<PopupMenuItem<dynamic>> items=[
  PopupMenuItem<int>(
    onTap:(){

  },value:1,

    child:TextButton(
      child:const Text("Yesterday included"),
      onPressed:(){
        setState((){
          dateSubtract=1;
        });
        Navigator.pop(context);
      },),

    ),
    PopupMenuItem<int>(
        onTap:(){

        },value:2,
        child:TextButton(
          child:const Text("All the Month Orders"),
          onPressed:(){
            setState((){
              dateSubtract=100;
            });
            Navigator.pop(context);
            // print(DateTime.now().day+DateTime.now().month);
            // print(DateTime.now().subtract(Duration(days:1)));
          },)

    ),
  ];
  @override
  void initState() {
    super.initState();
    customerProvider = context.read<CustomerProvider>();


  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
       // drawer: const Drawers(),
         // bottomNavigationBar: BottomNavBar(idx:0),
          appBar: AppBar(
            title: const Text("Orders"),
            centerTitle: true,
            actions:[
              IconButton(
                icon:const Icon(Icons.more_vert),
                onPressed:(){
                  showMenu(context: context,
                      position: const RelativeRect.fromLTRB(50,80,30,0),
                      items: items);
                }
              )

            ],

            // leading: Builder(
            //   builder: (BuildContext context) {
            //     return IconButton(
            //       icon: const Icon(Icons.menu),
            //       onPressed: () {
            //         Scaffold.of(context).openDrawer();
            //       },
            //       tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            //     );
            //   },
            // ),
          ),
        body:  SingleChildScrollView(
          //physics: ScrollPhysics(),
          child: Container(
            color: const Color.fromRGBO(245, 245, 245, 0.6),
            padding: const EdgeInsets.all(10),
            child: Column(
                mainAxisSize:MainAxisSize.min,
                children:[
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: allOrders(),
              builder: (context, snapshot) {
                if(!snapshot.hasData){
                  return const Center(child: Text("No orders yet"));
                }
                else if(snapshot.connectionState==ConnectionState.waiting){
                  //FlutterSpinkit
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
    //print(snapshot.data?.docs.length);
    var orders=snapshot.data?.docs[index];
   var id= snapshot.data?.docs[index].id;
    return Container(
      margin:const EdgeInsets.only(bottom:10),
      padding:const EdgeInsets.only(bottom:10,top:5),
      decoration: BoxDecoration(
        color:Colors.white,
        borderRadius:BorderRadius.circular(10),
        border:Border.all(
            width:1,color:Colors.white,style:BorderStyle.solid
        )
      ),
      child: StickyHeader(
            header:Center(
        child: Text("Deliver to ${orders?["customerName"]}"
        "\n${orders?["customerLocation"].toString().substring(0,45)}...\n"
        "${orders?["customerNumber"]}"
            "\nRestaurant: ${orders?["title"]}",textAlign:TextAlign.center),
      ),
      content:Column(
        children: [
            ListTile(
            leading:Text(orders!["quantity"].toString()),
            title: Text(orders["name"]),
            trailing: Text(orders["totalAmount"].toString()),
            ),
          Text("Total: GHc ${orders["totalAmount"].toString()}",
              style:const TextStyle(
                  fontSize:15,fontWeight: FontWeight.bold
              )),
            Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  SizedBox(width:130,
                    child: MainButton(
                      onPressed:orders["driverStatus"]=="accepted"?null:
                          () {
                        Map<String,dynamic> gg={
                          "driverStatus":"accepted",
                        };
                        FirebaseFirestore.instance
                            .collection("Orders")
                            .doc(id).update(gg);
                      },
                      color: Colors.white,
                      child:  Text("Accept"),
                    ),
                  ),
                  SizedBox(width:120,
                    child: MainButton(
                      onPressed:orders["driverStatus"]=="accepted"?null: () {
                        Map<String,dynamic> gg={
                          "driverStatus":"Pending",
                          "driverLocation":null,
                          "driverName":null,
                          "driverLongitude":null,
                          "driverLatitude":null,
                          "driverNumber":null,
                          //"statusCheck":true,
                        };
                        FirebaseFirestore.instance
                            .collection("Orders")
                            .doc(id).update(gg);
                        },
                    color: Colors.white,
                    child: const Text("Reject"),
                  ),
                  ),

                ]
            )])),
    );
                    });
              }
            )
              ]),
          ),
        ),
        ),

    );
  }
  // Stream<QuerySnapshot<Map<String, dynamic>>> getDrivers(){
  //   return FirebaseFirestore.instance
  //       .collection("pashewDriverAccount")
  //       .snapshots();
  //
  // }
}
