import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:objectid/objectid.dart';
import 'package:photo_manager/photo_manager.dart';

import '../db/db_manager.dart';
import '../db/image.dart';
import '../db/record.dart';
import '../tianditu/geocoder.dart';
import '../tool/coordinator_tool.dart';
import '../tool/image_tool.dart';
import '../tool/location_tool.dart';
import '../widget/app_bars.dart';
import '../widget/picture_grid.dart';

class EditRecord extends StatefulWidget {
  final DbRecord? record;
  final String project;

  const EditRecord({Key? key, this.record, required this.project})
      : super(key: key);

  @override
  State<EditRecord> createState() => _EditRecordState();
}

class _EditRecordState extends State<EditRecord> {
  final _formKey = GlobalKey<FormState>();
  final _pictureKey = GlobalKey<PictureGridState>();

  List<AssetEntity> initialImages = [];
  List<DbImage> oldImages = [];

  late final Widget pictureGrid;
  var _isNew = false;
  late DbRecord record;
  late Future<void>? _geoFuture;
  late Future<void>? _imageFuture;
  late final TextEditingController noteController;

  @override
  void initState() {
    pictureGrid = PictureGrid(
      key: _pictureKey,
      initialImages: initialImages,
    );

    if (widget.record != null) {
      record = widget.record!;
      _geoFuture = emptyFuture();
      _imageFuture = imageGridFuture();
    } else {
      _isNew = true;
      record = DbRecord.add(project: ObjectId.fromHexString(widget.project), lon: 0.0, lat: 0.0, ele: 0.0, species: '', speciesRef: '', country: '', province: '', city: '', county: '', poi: '', notes: '');

      _geoFuture = _getCurrentLocation(context);
      _imageFuture = emptyFuture();
    }
    noteController = TextEditingController(text: record.notes);

    super.initState();
  }

  @override
  void dispose() {
    // 清理控制器资源
    noteController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    Position? locationData = await getCurrentLocation(context);

    if (locationData != null) {
      record.lat = locationData.latitude;
      record.lon = locationData.longitude;
      record.ele = locationData.altitude;
      final addresses = await Geocoder.getFromLocation(
          locationData.latitude, locationData.longitude);
      if (addresses.isNotEmpty) {
        record.country = addresses[0].nation;
        record.province = addresses[0].province;
        record.city = addresses[0].city;
        record.county = addresses[0].county;
        record.poi = addresses[0].address;
      }
      return;
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      FocusManager.instance.primaryFocus?.unfocus();

      final pictureGrid = _pictureKey.currentState;
      if (pictureGrid == null || pictureGrid.imageData.isEmpty) {
        Fluttertoast.showToast(
          msg: "请选择至少一张图片",
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }

      if (_isNew) {
        DbManager.db.recordDao.insertOne(record);
      } else {
        DbManager.db.recordDao.updateOne(record);
      }

      final result = await imageMapForEach(
          'place', pictureGrid, oldImages, record.id);

      if (result == 1) {
        Fluttertoast.showToast(
          msg: "保存成功",
          toastLength: Toast.LENGTH_SHORT,
        );
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } else {
        Fluttertoast.showToast(
          msg: "保存失败",
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  Future<void> imageGridFuture() async {
    oldImages =
        await DbManager.db.imageDao.getByRecord(record.id.hexString);
    for (DbImage image in oldImages) {
      final assetEntity = await AssetEntity.fromId(image.imageId);
      if (assetEntity != null) {
        initialImages.add(assetEntity);
      }
    }

    pictureGrid = PictureGrid(
      key: _pictureKey,
      initialImages: initialImages,
    );
  }

  Widget _getSpeciesSelector() => TextFormField(
    onSaved: (val) => {
      if (val != null) {record.species = val}
    },
    validator: (val) => val == null || val.isEmpty
        ? '本项不能为空'
        : null,
    enabled: true,
    initialValue: record.species,
    decoration:
    const InputDecoration(labelText: '物种'),
  );

  Future<void> emptyFuture() async {}

  Widget _showTitle() {
    return Text(
      _isNew ? '添加记录' : '修改记录',
    );
  }

  Widget _getImageGrid() => StatefulBuilder(
      builder: (context, setState) => FutureBuilder(
          future: _imageFuture,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return pictureGrid;
            } else {
              return const LinearProgressIndicator();
            }
          }));

  Widget _getTimeItem() => Row(
        children: [
          const Icon(
            Icons.access_time_filled_rounded,
            color: Colors.green,
          ),
          const SizedBox(
            width: 12,
          ),
          Text(record.observeTime.toString(), style: const TextStyle(fontSize: 18)),
        ],
      );

  Widget _getLocationItem() => StatefulBuilder(
      builder: (context, setState) => FutureBuilder(
        future: _geoFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '经度: ${CoordinateTool().degreeToDms(record.lat.toString())}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(
                  height: 12,
                ),
                Text(
                    '纬度: ${CoordinateTool().degreeToDms(record.lon.toString())}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(
                  height: 12,
                ),
                Text('海拔: ${record.ele.toStringAsFixed(3)}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(
                  height: 12,
                ),
                Text('${record.country} ${record.province} ${record.city} ${record.county}',
                    style: const TextStyle(fontSize: 18)),
                TextFormField(
                  onSaved: (val) => {
                    if (val != null) {record.poi = val}
                  },
                  validator: (val) => val == null || val.isEmpty
                      ? '本项不能为空'
                      : null,
                  enabled: true,
                  initialValue: record.poi,
                  decoration:
                  const InputDecoration(labelText: '地址'),
                ),
              ],
            );
          } else {
            return const LinearProgressIndicator();
          }
        },
      ),
  );

  Widget _getNoteItem() => StatefulBuilder(builder: (context, setState) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(
              width: 12,
            ),
            Expanded(
                child: TextFormField(
              controller: noteController,
              onSaved: (val) => {
                if (val != null) {record.notes = val}
              },
              decoration: const InputDecoration(
                labelText: '备注',
              ),
            )),
            const SizedBox(
              width: 12,
            ),
          ],
        );
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: anAppBar(
        title: _showTitle(),
        actions: [
          IconButton(
            onPressed: () {
              _submitForm(context);
            },
            icon: const Icon(
              Icons.save_rounded,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: false,
            children: [
              _getSpeciesSelector(),
              const SizedBox(
                height: 12,
              ),
              _getImageGrid(),
              _getTimeItem(),
              const SizedBox(
                height: 12,
              ),
              _getLocationItem(),
              const SizedBox(
                height: 12,
              ),
              const SizedBox(
                height: 12,
              ),
              _getNoteItem(),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
