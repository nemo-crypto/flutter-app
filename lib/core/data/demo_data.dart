import 'package:flutter/material.dart';

import '../models/card_item.dart';

abstract final class DemoData {
  static const featuredCard = CardItem(
    id: 'aurora',
    name: '极光观测者',
    subtitle: '限定 · 星辉序列',
    rarity: CardRarity.legendary,
    symbol: 'A-01',
    primaryColor: Color(0xFF25D0E6),
    secondaryColor: Color(0xFF725CFF),
    icon: Icons.auto_awesome,
    isNew: true,
  );

  static const cards = <CardItem>[
    featuredCard,
    CardItem(
      id: 'lunar',
      name: '月面信使',
      subtitle: '稀有 · 静海档案',
      rarity: CardRarity.epic,
      symbol: 'L-07',
      primaryColor: Color(0xFFFF76C8),
      secondaryColor: Color(0xFF7047D8),
      icon: Icons.nightlight_round,
    ),
    CardItem(
      id: 'nova',
      name: '新星引擎',
      subtitle: '稀有 · 炽热核心',
      rarity: CardRarity.epic,
      symbol: 'N-12',
      primaryColor: Color(0xFFFFA765),
      secondaryColor: Color(0xFFE84877),
      icon: Icons.bolt,
    ),
    CardItem(
      id: 'tide',
      name: '潮汐编织者',
      subtitle: '精良 · 深蓝回声',
      rarity: CardRarity.rare,
      symbol: 'T-04',
      primaryColor: Color(0xFF65D7FF),
      secondaryColor: Color(0xFF3E73DD),
      icon: Icons.water_drop,
    ),
    CardItem(
      id: 'orbit',
      name: '轨道旅人',
      subtitle: '精良 · 漂浮城市',
      rarity: CardRarity.rare,
      symbol: 'O-03',
      primaryColor: Color(0xFF83E5A5),
      secondaryColor: Color(0xFF288C9A),
      icon: Icons.public,
    ),
    CardItem(
      id: 'signal',
      name: '信号拾荒者',
      subtitle: '普通 · 失落频道',
      rarity: CardRarity.common,
      symbol: 'S-09',
      primaryColor: Color(0xFFA6B3D3),
      secondaryColor: Color(0xFF5C668E),
      icon: Icons.graphic_eq,
    ),
  ];

  static const events = <({String title, String subtitle, IconData icon})>[
    (title: '深空回响', subtitle: 'SSR 概率提升', icon: Icons.blur_on),
    (title: '新手航线', subtitle: '首次十连必得 SR', icon: Icons.rocket_launch),
    (title: '星尘兑换', subtitle: '限时商店开放中', icon: Icons.local_mall_outlined),
  ];
}
