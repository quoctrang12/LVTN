import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:lvtn_admin/Models/Manager/RoomManager.dart';
import 'package:lvtn_admin/Models/Room.dart';
import 'package:flutter/material.dart';
import 'package:lvtn_admin/Models/offsetPosition.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_plus/dropdown_plus.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<void> _fetchRooms;
  List<Room> list = [];
  final from = ValueNotifier('');
  final controller = TextEditingController();

  @override
  void initState() {
    _fetchRooms = context.read<RoomManager>().initilize().then((value) {
      context.read<RoomManager>().fetchPositions().then((value) {
        setState(() {
          list = context.read<RoomManager>().search;
        });
      });
      setState(() {
        list = context.read<RoomManager>().search;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Container(
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(25)),
          child: IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Room _room = Room(
                  name: '',
                  offset: OffsetPosition(x: 0, y: 0),
                  luotTruyCap: 0,
                  keyWord: []);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Thêm khu vực!"),
                  content: StatefulBuilder(
                    builder: (context, StateSetter setdialog) => Container(
                      height: 400,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              initialValue: _room.name,
                              decoration: const InputDecoration(
                                  labelText: 'Tên khu vực'),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please provide a value.';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setdialog(() {
                                  _room = _room.copyWith(name: value);
                                });
                              },
                              onSaved: (value) {
                                _room = _room.copyWith(name: value);
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SpinBox(
                              min: 0.0,
                              max: 20.0,
                              value: _room.offset.x.toDouble(),
                              decimals: 1,
                              step: 0.1,
                              onChanged: (value) => _room = _room.copyWith(
                                  offset: OffsetPosition(
                                      x: value, y: _room.offset.y)),
                              decoration:
                                  const InputDecoration(labelText: 'Tọa độ x'),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SpinBox(
                              min: 0.0,
                              max: 20.0,
                              value: _room.offset.y.toDouble(),
                              decimals: 1,
                              step: 0.1,
                              onChanged: (value) => _room = _room.copyWith(
                                  offset: OffsetPosition(
                                      y: value, x: _room.offset.x)),
                              decoration:
                                  const InputDecoration(labelText: 'Tọa độ y'),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Số lượng tìm kiếm: '),
                            SizedBox(
                              height: 10,
                            ),
                            Text(_room.luotTruyCap.toString()),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Từ khóa tìm kiếm: '),
                            SizedBox(
                              height: 10,
                            ),
                            Text(_room.name.split(' ').join(',')),
                          ]),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Đóng"),
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text("Thêm"),
                      onPressed: () async {
                        await context
                            .read<RoomManager>()
                            .addRoom(_room)
                            .then((value) {
                          setState(() {
                            list = context.read<RoomManager>().search;
                          });
                          Navigator.of(ctx).pop(true);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            fromInputBox(),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: FutureBuilder(
                future: _fetchRooms,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Container(
                    height: MediaQuery.of(context).size.height * .6,
                    width: MediaQuery.of(context).size.width,
                    child: ValueListenableBuilder<String>(
                      valueListenable: from,
                      builder: ((context, value, child) =>
                          searchListView(list)),
                    ),
                  );
                },
              ),
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
              Expanded(
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
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.mode_outlined,
                            size: 24,
                          ),
                          onPressed: () {
                            Room _edited = matchQuery[i];
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Sửa khu vực!"),
                                content: StatefulBuilder(
                                  builder: (context, StateSetter setdialog) =>
                                      Container(
                                    height: 400,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            initialValue: _edited.name,
                                            decoration: const InputDecoration(
                                                labelText: 'Tên khu vực'),
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please provide a value.';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              setdialog(() {
                                                _edited = _edited.copyWith(
                                                    name: value);
                                              });
                                            },
                                            onSaved: (value) {
                                              _edited =
                                                  _edited.copyWith(name: value);
                                            },
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          SpinBox(
                                            min: 0.0,
                                            max: 20.0,
                                            value: _edited.offset.x.toDouble(),
                                            decimals: 1,
                                            step: 0.1,
                                            onChanged: (value) => _edited =
                                                _edited.copyWith(
                                                    offset: OffsetPosition(
                                                        x: value,
                                                        y: _edited.offset.y)),
                                            decoration: const InputDecoration(
                                                labelText: 'Tọa độ x'),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SpinBox(
                                            min: 0.0,
                                            max: 20.0,
                                            value: _edited.offset.y.toDouble(),
                                            decimals: 1,
                                            step: 0.1,
                                            onChanged: (value) => _edited =
                                                _edited.copyWith(
                                                    offset: OffsetPosition(
                                                        y: value,
                                                        x: _edited.offset.x)),
                                            decoration: const InputDecoration(
                                                labelText: 'Tọa độ y'),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Số lượng tìm kiếm: '),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(_edited.luotTruyCap.toString()),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Từ khóa tìm kiếm: '),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(_edited.name
                                              .split(' ')
                                              .join(',')),
                                        ]),
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("Đóng"),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("Lưu"),
                                    onPressed: () async {
                                      await context
                                          .read<RoomManager>()
                                          .updateRoom(_edited)
                                          .then((value) {
                                        setState(() {
                                          list = context
                                              .read<RoomManager>()
                                              .search;
                                        });
                                        Navigator.of(ctx).pop(true);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 24,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Xóa khu vực!"),
                                content: Text('Bạn có chắc muốn xóa không?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("Không"),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("Có"),
                                    onPressed: () async {
                                      await context
                                          .read<RoomManager>()
                                          .deleteRoom(matchQuery[i])
                                          .then((value) {
                                        setState(() {
                                          list = context
                                              .read<RoomManager>()
                                              .search;
                                        });
                                        Navigator.of(ctx).pop(true);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        controller: controller,
        // options: room,
        onFieldSubmitted: ((value) {
          print(value);
        }),
        onChanged: (dynamic value) {
          from.value = value;
        },
        decoration: InputDecoration(
          hintText: "Tìm kiếm ...",
          prefixIcon: IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.blue,
            ),
            onPressed: () {},
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              from.value = '';
              controller.clear();
            },
          ),
        ),
      ),
    );
  }
}
