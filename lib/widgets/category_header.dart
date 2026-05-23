import 'package:flutter/material.dart';

class CategoryHeader extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryHeader({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"label": "All", "emoji": "🔥", "width": 110.0},
      {"label": "Chicken", "emoji": "🐔", "width": 160.0},
      {"label": "Beef", "emoji": "🥩", "width": 130.0},
      {"label": "Lamb", "emoji": "🐑", "width": 130.0},
      {"label": "Combo", "emoji": "🍱", "width": 145.0},
    ];

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final label = categories[index]["label"] as String;
          final emoji = categories[index]["emoji"] as String;
          final width = categories[index]["width"] as double;

          final isSelected = selectedCategory == label;

          return SizedBox(
            width: width,
            height: 52,
            child: ChoiceChip(
              selected: isSelected,
              selectedColor: Colors.deepOrange,
              backgroundColor: Colors.white,
              showCheckmark: false,
              labelPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isSelected
                      ? Colors.deepOrange
                      : Colors.orange.shade100,
                ),
              ),
              label: Center(
                child: Text(
                  "$emoji  $label",
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              onSelected: (_) {
                onCategorySelected(label);
              },
            ),
          );
        },
      ),
    );
  }
}

class CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  CategoryHeaderDelegate({
    required this.child,
  });

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: child,
    );
  }

  @override
  bool shouldRebuild(
    covariant CategoryHeaderDelegate oldDelegate,
  ) {
    return oldDelegate.child != child;
  }
}