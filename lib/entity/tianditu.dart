import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:naturalist/entity/key_store.dart';

import 'cache_title_provider.dart'; // Suitable for most situations

class TianDiTu {
  static const key = KeyStore.tianditu;
  static const packageName = 'moe.sunjiao.naturalist';

  static List<TileLayer> vecTile = [
    // 街道图
    TileLayer(
      tileProvider: CacheTileProvider(
        tileName: 'vec',
        urlTemplate:
            'https://t{s}.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key',
        userAgentPackageName: packageName,
        subdomains: const ['0', '1', '2', '3', '4', '5', '6', '7'],
      ),
      backgroundColor: Colors.transparent,
    ),
    TileLayer(
      tileProvider: CacheTileProvider(
        tileName: 'cva',
        urlTemplate:
            'https://t{s}.tianditu.gov.cn/cva_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cva&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key',
        userAgentPackageName: packageName,
        subdomains: const ['0', '1', '2', '3', '4', '5', '6', '7'],
      ),
      backgroundColor: Colors.transparent,
    ),
  ];
  static List<TileLayer> imgTile = [
    // 卫星图
    TileLayer(
      tileProvider: CacheTileProvider(
        tileName: 'img',
        urlTemplate:
            'https://t{s}.tianditu.gov.cn/img_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key',
        userAgentPackageName: packageName,
        subdomains: const ['0', '1', '2', '3', '4', '5', '6', '7'],
      ),
      backgroundColor: Colors.transparent,
    ),
    TileLayer(
      tileProvider: CacheTileProvider(
        tileName: 'cia',
        urlTemplate:
            'https://t{s}.tianditu.gov.cn/cia_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cia&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key',
        userAgentPackageName: packageName,
        subdomains: const ['0', '1', '2', '3', '4', '5', '6', '7'],
      ),
      backgroundColor: Colors.transparent,
    ),
  ];
  static List<TileLayer> terTile = [
    // 地形图
    TileLayer(
      tileProvider: CacheTileProvider(
        tileName: 'ter',
        urlTemplate:
            'https://t{s}.tianditu.gov.cn/ter_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=ter&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key',
        userAgentPackageName: packageName,
        subdomains: const ['0', '1', '2', '3', '4', '5', '6', '7'],
      ),
      backgroundColor: Colors.transparent,
    ),
    TileLayer(
      tileProvider: CacheTileProvider(
        tileName: 'cta',
        urlTemplate:
            'https://t{s}.tianditu.gov.cn/cta_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cta&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key',
        userAgentPackageName: packageName,
        subdomains: const ['0', '1', '2', '3', '4', '5', '6', '7'],
      ),
      backgroundColor: Colors.transparent,
    ),
  ];
}