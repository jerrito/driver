import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_osm_interface/src/types/geo_point.dart' as geo;
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:driver/userProvider.dart';
import 'package:driver/widgets/MainButton.dart';
import 'package:driver/widgets/bottomNavigation.dart';
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


  Stream<QuerySnapshot<Map<String, dynamic>>> allOrders(int dateSubtract){
    var stringList =  DateTime.now().toIso8601String().split(RegExp(r"[T\.]"));
    var formatedDate = "${stringList[0]}000000";
    var date=formatedDate.replaceAll("-", "");
    print(date);
    int dateInt=int.parse(date);
    final products= FirebaseFirestore.instance
        .collection("Orders")
        .where("date",isGreaterThanOrEqualTo:dateInt-dateSubtract  )
        .where("title",isEqualTo: customerProvider?.appUser?.fullName)
        .snapshots();
    return products;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> yesterdayOrder(int dateSubtract){
    var stringList =  DateTime.now().toIso8601String().split(RegExp(r"[T\.]"));
    var formatedDate = "${stringList[0]}";
    var date=formatedDate.replaceAll("-", "");
    if(date.endsWith("01")==true){

    }
    int dateInt=int.parse(date);


    print(date);
    final products= FirebaseFirestore.instance
        .collection("Orders")
        .where("date",isGreaterThanOrEqualTo:dateInt-dateSubtract )
        .where("title",isEqualTo: customerProvider?.appUser?.fullName)
        .snapshots();
    return products;
  }

  List<PopupMenuItem<dynamic>> items=[
    PopupMenuItem<int>(
      onTap:(){

      },value:1,

      child:TextButton(
        child:const Text("Yesterday orders"),
        onPressed:(){

        },),

    ),
    PopupMenuItem<int>(
      onTap:(){

      },value:2,
      child:TextButton(
        child:const Text("Month Orders"),
        onPressed:(){

        },),

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
        drawer: const Drawers(),
        bottomNavigationBar: BottomNavBar(idx:0),
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

          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ),
        body:  SingleChildScrollView(
          //physics: ScrollPhysics(),
          child: Column(
              mainAxisSize:MainAxisSize.min,
              children:[
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: allOrders(0),
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
                            print(snapshot.data?.docs.length);
                            var orders=snapshot.data?.docs[index];
                            return StickyHeader(
                                header:Center(
                                  child: Text("Deliver to ${orders?["customerName"]}"
                                      "\n${orders?["customerLocation"].toString().substring(0,45)}...\n"
                                      "${orders?["customerNumber"]}",textAlign:TextAlign.center),
                                ),
                                content:Column(
                                    children: [
                                      ListTile(
                                        leading:Text(orders!["quantity"].toString()),
                                        title: Text(orders["name"]),
                                        trailing: Text(orders["totalAmount"].toString()),
                                      ),
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children:[
                                            const Padding(
                                              padding: EdgeInsets.only(left:50.0),
                                              child: Text("Total: \$300",style:TextStyle(
                                                  fontSize:18,fontWeight: FontWeight.bold
                                              )),
                                            ),
                                            MainButton(
                                              onPressed: () {
                                                showDialog(context: context,
                                                    builder:
                                                        (BuildContext context){
                                                      return StatefulBuilder(
                                                          builder: (context,setState) {
                                                            return Dialog(

                                                              child: SizedBox(
                                                                  height: MediaQuery.of(context).size.height*0.8,
                                                                  child:StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                                                      stream: getDrivers(),
                                                                      builder:  (BuildContext context ,snapshot){
                                                                        if(!snapshot.hasData){
                                                                          return const Center(child: Text("No drivers yet"));
                                                                        }
                                                                        else if(snapshot.connectionState==ConnectionState.waiting){
                                                                          return const Center(child: CircularProgressIndicator());
                                                                        }

                                                                        return Column(
                                                                          children: [
                                                                            const Text("Select driver",style:TextStyle(
                                                                                fontSize:18,fontWeight:FontWeight.bold
                                                                            )),
                                                                            const SizedBox(height:10),
                                                                            Flexible(
                                                                              child: ListView.builder(
                                                                                  itemCount:snapshot.data?.docs.length,
                                                                                  itemBuilder: (BuildContext context,index){
                                                                                    var drivers=snapshot.data?.docs[index];
                                                                                    return ListTile(
                                                                                      onTap: (){
                                                                                        print(drivers?["fullName"]);
                                                                                      },
                                                                                      title: Text(drivers?["fullName"]),
                                                                                      trailing:  CircleAvatar(
                                                                                        backgroundImage:NetworkImage(
                                                                                            drivers?["image"]
                                                                                        ) ,
                                                                                      ),

                                                                                    );
                                                                                  }),
                                                                            ),
                                                                            MainButton(
                                                                                onPressed:()async{
                                                                                  await  showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context){
                                                                                        return StatefulBuilder(
                                                                                            builder: (context,setState) {
                                                                                              return Container(
                                                                                                height:MediaQuery.of(context).size.height*0.8,
                                                                                                width:double.infinity,
                                                                                                decoration:BoxDecoration(
                                                                                                    borderRadius:BorderRadius.circular(10)),
                                                                                                child: Stack(
                                                                                                  children: [
                                                                                                    OSMFlutter(
                                                                                                      // mapIsLoading:Center(child: const
                                                                                                      // CircularProgressIndicator(
                                                                                                      //   value:100
                                                                                                      // )),
                                                                                                      controller:mapController,
                                                                                                      userTrackingOption: const UserTrackingOption(
                                                                                                        enableTracking: false,
                                                                                                        unFollowUser: true,
                                                                                                      ),
                                                                                                      //isPicker: true,
                                                                                                      initZoom: 16,
                                                                                                      minZoomLevel: 4,
                                                                                                      maxZoomLevel: 18,
                                                                                                      stepZoom: 1.0,
                                                                                                      userLocationMarker: UserLocationMaker(
                                                                                                        personMarker: const MarkerIcon(
                                                                                                          icon: Icon(
                                                                                                            Icons.location_history_rounded,
                                                                                                            color: Colors.red,
                                                                                                            size: 48,
                                                                                                          ),
                                                                                                        ),
                                                                                                        directionArrowMarker: const MarkerIcon(
                                                                                                          icon: Icon(
                                                                                                            Icons.double_arrow,
                                                                                                            size: 48,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      roadConfiguration: const RoadOption(
                                                                                                        roadColor: Colors.yellowAccent,
                                                                                                      ),
                                                                                                      markerOption: MarkerOption(
                                                                                                          defaultMarker: const MarkerIcon(
                                                                                                            icon: Icon(
                                                                                                              Icons.person_pin_circle,
                                                                                                              color: Colors.blue,
                                                                                                              size: 56,
                                                                                                            ),
                                                                                                          )
                                                                                                      ),
                                                                                                    ),
                                                                                                    Align(
                                                                                                        alignment: Alignment.topRight,
                                                                                                        child:IconButton(
                                                                                                            onPressed:(){

                                                                                                              mapController.dispose();
                                                                                                              Navigator.pop(context);},
                                                                                                            icon:
                                                                                                            const Icon(Icons.cancel))
                                                                                                    ),
                                                                                                    Visibility(
                                                                                                      visible:driverRefresh,
                                                                                                      replacement:Align(
                                                                                                          alignment: Alignment.bottomRight,
                                                                                                          child: IconButton(
                                                                                                              onPressed:(){
                                                                                                                getDrivers();
                                                                                                              },
                                                                                                              icon:const Icon(Icons.refresh,
                                                                                                                  size:30,color:Colors.green)
                                                                                                          )
                                                                                                      ),
                                                                                                      child: Align(
                                                                                                          alignment: Alignment.bottomCenter,
                                                                                                          child:IconLabelButton(
                                                                                                            onPressed:(){

                                                                                                              setState((){
                                                                                                                driverRefresh=false;
                                                                                                                mapController.addMarker(
                                                                                                                  geo.GeoPoint(
                                                                                                                      latitude: 5.1096452986370196,
                                                                                                                      longitude: -1.2982749938964844),
                                                                                                                  markerIcon:const MarkerIcon(
                                                                                                                      icon:Icon(Icons.restaurant,
                                                                                                                        color:Colors.green,size: 50,)),
                                                                                                                );
                                                                                                                for(int i=0;i<snapshot.data!.docs.length;i++){
                                                                                                                  var drivers=snapshot.data?.docs[i];
                                                                                                                  //print(drivers?["latitude"]);
                                                                                                                  mapController.drawRoad(
                                                                                                                      geo.GeoPoint(
                                                                                                                          latitude: drivers?["latitude"],
                                                                                                                          longitude: drivers?["longitude"]),
                                                                                                                      geo.GeoPoint(
                                                                                                                          latitude: 5.1096452986370196,
                                                                                                                          longitude: -1.2982749938964844),
                                                                                                                      roadOption:const RoadOption(
                                                                                                                        roadColor: Colors.black,
                                                                                                                        roadWidth: 5,
                                                                                                                      ));
                                                                                                                }
                                                                                                                // mapController.myLocation();

                                                                                                              });
                                                                                                            },
                                                                                                            icon:
                                                                                                            const Icon(Icons.location_on),
                                                                                                            backgroundColor: Colors.green,
                                                                                                            color: Colors.green,
                                                                                                            label: 'Show Drivers',
                                                                                                          )
                                                                                                      ),
                                                                                                    )
                                                                                                  ],
                                                                                                ),
                                                                                              );
                                                                                            }
                                                                                        );
                                                                                      });

                                                                                },
                                                                                backgroundColor: Colors.green,
                                                                                color: Colors.green,
                                                                                child: const Text("Use map instead",
                                                                                )),
                                                                            const SizedBox(height:10)
                                                                          ],
                                                                        );

                                                                      }) ),
                                                            );
                                                          }
                                                      );
                                                    });
                                              },
                                              color: Colors.white,
                                              child: const Text("Driver Pending"),
                                            )
                                          ]
                                      )


                                    ])

                            );

                          });
                    }
                )
              ]),
        ),
      ),

    );
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getDrivers(){
    return FirebaseFirestore.instance
        .collection("pashewDriverAccount")
        .snapshots();

  }
}
