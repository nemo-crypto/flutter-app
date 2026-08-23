import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/section_title.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '我的航线',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _ProfileHeader(),
              const SizedBox(height: 20),
              const _LevelProgress(),
              const SizedBox(height: 28),
              const SectionTitle(title: '成就徽章'),
              const SizedBox(height: 14),
              const _AchievementGrid(),
              const SizedBox(height: 28),
              const SectionTitle(title: '更多设置'),
              const SizedBox(height: 14),
              const _SettingList(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.pink, AppColors.purple],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: 0.26),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '星际漫游者',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'ID  NO.  2024-星尘-0816',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _LevelProgress extends StatelessWidget {
  const _LevelProgress();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '探索等级',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const Text(
                'LV. 18',
                style: TextStyle(
                  color: AppColors.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              value: 0.68,
              minHeight: 8,
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation(AppColors.cyan),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Text(
                '2,480 星尘经验',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
              Spacer(),
              Text(
                '3,600',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  const _AchievementGrid();

  static const items = [
    (icon: Icons.auto_awesome, title: '初次共鸣', color: AppColors.gold),
    (icon: Icons.explore, title: '星际旅人', color: AppColors.cyan),
    (icon: Icons.workspace_premium, title: '高光时刻', color: AppColors.pink),
    (icon: Icons.lock_outline, title: '未解锁', color: AppColors.outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(
            child: GlassPanel(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              borderRadius: 18,
              child: Column(
                children: [
                  Icon(items[index].icon, color: items[index].color, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    items[index].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (index != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _SettingList extends StatelessWidget {
  const _SettingList();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.palette_outlined,
            title: '视觉主题',
            trailing: '星夜',
          ),
          _SettingRow(icon: Icons.help_outline, title: '帮助与反馈', trailing: ''),
          _SettingRow(
            icon: Icons.info_outline,
            title: '关于星穹抽卡',
            trailing: 'v1.0.0',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.trailing,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: () {},
            leading: Icon(icon, color: AppColors.cyan, size: 20),
            title: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing.isNotEmpty)
                  Text(
                    trailing,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 14,
            color: Colors.white.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}
