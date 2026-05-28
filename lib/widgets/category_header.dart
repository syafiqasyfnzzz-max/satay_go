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
      "All",
      "Chicken",
      "Beef",
      "Lamb",
      "Combo",
    ];

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () => onCategorySelected(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepOrange : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? Colors.deepOrange.shade700 : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.deepOrange.withAlpha((255 * 0.5).round()),
                            blurRadius: 15,
                            spreadRadius: -5,
                            offset: const Offset(0, 5),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withAlpha((255 * 0.1).round()),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
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
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

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