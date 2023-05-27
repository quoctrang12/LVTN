import 'package:ble_ips_example4/Models/Manager/PositionManager.dart';
import 'package:ble_ips_example4/Models/Manager/RoomManager.dart';
import 'package:ble_ips_example4/Models/Room.dart';
import 'package:ble_ips_example4/choose_map.dart';
import 'package:ble_ips_example4/direction.dart';
import 'package:flutter/material.dart';
// import 'package:location/views/Search_details_screen.dart';
// import 'package:location/constrain.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final from = ValueNotifier('');
  List<String> recentlySearch = [];
  List<Room> list = [];

  late Future<void> _fetchRooms;

  @override
  void initState() {
    _fetchRooms = context.read<RoomManager>().initilize().then((value) {
      context
          .read<RoomManager>()
          .fetchPositions(context.read<PositionManager>().location)
          .then((value) {
        setState(() {
          list = context.read<RoomManager>().search!;
        });
      });
      setState(() {
        list = context.read<RoomManager>().search!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            fromInputBox(),
            SizedBox(height: 20),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: CircleAvatar(
                            backgroundColor: Colors.amber[50],
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red[800],
                              size: 17,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chọn trên bản đồ',
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Divider(
                      thickness: 1,
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChooseMap(location: 'search'),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gần đây',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Icon(Icons.info_outline),
                ],
              ),
            ),
            FutureBuilder(
              future: _fetchRooms,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    height: MediaQuery.of(context).size.height * .6,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: ValueListenableBuilder<String>(
                        valueListenable: from,
                        builder: ((context, value, child) =>
                            searchListView(list)),
                      ),
                    ),
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget searchListView(List<Room> recentlySearch) {
    List<Room> matchQuery = [];
    for (var recent in recentlySearch) {
      if (recent.name.toLowerCase().contains(from.value.toLowerCase())) {
        matchQuery.add(recent);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (ctx, i) {
        return ListTile(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.access_time,
                size: 28,
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  matchQuery[i].name,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Số lần tìm kiếm: ${matchQuery[i].luotTruyCap}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          )
                        ],
                      ),
                      Divider(
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          onTap: () async {
            await context.read<RoomManager>().updateRoom(matchQuery[i]
                .copyWith(luotTruyCap: matchQuery[i].luotTruyCap + 1));
            context.read<RoomManager>().setSearchRoom(matchQuery[i]);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Direction(),
              ),
            );
          },
        );
      },
    );
  }

  Widget fromInputBox() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      height: 58,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: TextFormField(
        // options: room,
        autofocus: true,
        onFieldSubmitted: ((value) {
          // print(value);
        }),
        onChanged: (dynamic value) {
          from.value = value;
        },
        decoration: InputDecoration(
          hintText: "Tìm kiếm...",
          prefixIcon: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          suffixIcon: Icon(Icons.clear),
        ),
      ),
    );
  }
}
