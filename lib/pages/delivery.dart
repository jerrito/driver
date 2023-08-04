import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
//import 'package:driver/widgets/snackbars.dart';
import 'package:driver/userProvider.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:driver/models/user.dart';
import 'package:driver/databases/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DeliveryMap extends StatefulWidget with OSMMixinObserver{
  const DeliveryMap({super.key});

  @override
  State<DeliveryMap> createState() => _DeliveryMapState();

  @override
  Future<void> mapIsReady(bool isReady) {
    // TODO: implement mapIsReady
    throw UnimplementedError();
  }


}

class _DeliveryMapState extends State<DeliveryMap> with OSMMixinObserver{

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessenger=
  GlobalKey<ScaffoldMessengerState>();
  var firebase=FirebaseServices();
  final mapController = MapController.withUserPosition(
    trackUserLocation: const UserTrackingOption(
      enableTracking: true,
      unFollowUser: false,
    ),
    //areaLimit: BoundingBox.
  );
  CustomerProvider? customerProvider;
  int _index=0;
  double latitude=5;
  double longitude=-1;
  String location="";

  bool isLoading = false;
  @override
  void initState(){
    super.initState();
    _index=0;
    customerProvider=context.read<CustomerProvider>();
    print(customerProvider?.appUser?.id);
    mapController.addObserver(this);
    //onSingleTap(GeoPoint(latitude: 5, longitude: -1));
  }
  Future<void> mapIsReady(bool isReady) {
    // TODO: implement mapIsReady
    throw UnimplementedError();
  }
  @override
  Future<void> mapRestored() async {
    super.mapRestored();
    /// TODO
  }
  @override
  Future<void> onSingleTap(GeoPoint position) async{

    super.onSingleTap(GeoPoint(latitude: 5, longitude:-1));
    mapController.listenerMapSingleTapping.addListener(() {
      if (mapController.listenerMapSingleTapping.value != null) {
        /// put you logic here
        setState(() {
          latitude=mapController.listenerMapSingleTapping.value!.latitude;
          longitude=mapController.listenerMapSingleTapping.value!.longitude;
        });
              }
    });
    showMap(latitude,longitude);
    print(mapController.listenerMapSingleTapping.value?.latitude);
    print(mapController.listenerMapSingleTapping.value?.longitude);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text("Location: ${mapController.listenerMapSingleTapping.value}")));

    /// TODO
  }

  // @override
  // void onLongTap(GeoPoint position) {
  //   super.onLongTap();
  //   /// TODO
  //
  // }

  // @override
  // void onRegionChanged(Region region) {
  //   super.onRegionChanged(
  //       Region(center: center, boundingBox: boundingBox));
  //   /// TODO
  //
  // }

  // @override
  // void onRoadTap(RoadInfo road) {
  //   super.onRoadTap();
  //   /// TODO
  //
  // }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Address')),
      bottomNavigationBar: BottomNavigationBar(
        onTap:(index){
          if(index==0){
            setState(() {
              _index=index;
              mapController.myLocation();
            });
          }
          else if(index==1){
            setState(() {
              _index=index;
           showMap(5,-1);
            });
          }

        },
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(
            label: "Current Location",
              icon: Icon(Icons.location_on)),
          BottomNavigationBarItem(
              label: "Search",
              icon: Icon(Icons.search))
          ],),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await mapController.myLocation();
           //await mapController.setZoom(zoomLevel: 16,stepZoom: 2);
          // await mapController.zoomIn();

          // print(mapController.listenerMapSingleTapping.value);


        //print(mapController.geopoints.);
        },
        child:const Icon(Icons.my_location)
      ),
      body:Consumer<CustomerProvider>(
        builder: (context,customerProvider,child) {
          return Container(
              decoration: BoxDecoration(
                  color:Colors.grey,
                  borderRadius: BorderRadius.circular(10)
              ),
              width:double.infinity,//height: 400,
              child:Stack(
                children: [
                  OSMFlutter(
                   // mapIsLoading:const CircularProgressIndicator(),
                    controller:mapController,
                    userTrackingOption: const UserTrackingOption(
                      enableTracking: true,
                      unFollowUser: false,
                    ),
                    //isPicker: true,
                    initZoom: 16,
                    minZoomLevel: 2,
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
                 // Positioned(
                  //   top:20,left:30,
                  //   child:CarouselSlider(
                  //     items:[
                  //       Container(
                  //         width:150,
                  //           child: Text("Tap on the position")),
                  //     ],
                  //     options:CarouselOptions(
                  //       height:20,//width:double.infinity,
                  //       viewportFraction: 0.9,
                  //       autoPlay: true,
                  //     )
                  //   )
                  // )
                ],
              )
          );
        }
      ),
    );
  }
  void showMap( double lat,double long){
    showModalBottomSheet(
        shape:RoundedRectangleBorder(
            borderRadius:BorderRadius.circular(10)),
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
              builder: (context,setState) {
                return Container(
                  height:MediaQuery.of(context).size.height*75,
                  width:double.infinity,
                  decoration:BoxDecoration(
                      borderRadius:BorderRadius.circular(10)),
                  child:OpenStreetMapSearchAndPick(
                    center: LatLong(lat,long),
                    buttonColor: Colors.green,
                    buttonText: 'Set Current Location',
                    onPicked: (pickedData) async{
                      setState((){
                          longitude=pickedData.latLong.longitude;
                          latitude=pickedData.latLong.latitude;
                          location=pickedData.address;
                        });
                        await locationDetails(customer:customerProvider?.appUser);
                    },
                  ),
                );
              }
          );
        });
  }
  Future<void> locationDetails({required Customer? customer})async{
    var customers=customer;
    double? long=customer?.longitude;
    double? lat=customer?.latitude;
    String? loc=customer?.location;
    long=longitude;
    loc=location;
    lat=latitude;

   customers?.longitude=long;
    customers?.latitude=lat;
    customers?.location=loc;


    await updateUser(customer: customers!);
  }
  updateUser({required Customer customer}) async {
    //print("ss");
    var result = await customerProvider?.updateUser(customer: customer);
    if (result?.status == QueryStatus.successful) {
      //print("s");
      if(!context.mounted)return;
      // PrimarySnackBar(context).displaySnackBar(
      //   message: "Location updated successfully",
      //   //backgroundColor: AppColors.colorPrimary,
      // );
      Navigator.pushReplacementNamed(context, "home");

      return;
    }
    if (result?.status == QueryStatus.failed) {
      print("f");
      setState(() {
        isLoading = false;
      });
      if(!context.mounted)return;
      // PrimarySnackBar(context).displaySnackBar(
      //   message: "Error saving location details",
      //  // backgroundColor: AppColors.errorRed,
      // );
    }
  }
}
