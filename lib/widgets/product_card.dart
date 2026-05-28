import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:satay_master_pro/models/satay_item.dart';
import 'package:satay_master_pro/providers/auth_provider.dart';
import 'package:satay_master_pro/widgets/dialogs/customize_cart_dialog.dart';
import 'package:satay_master_pro/widgets/dialogs/login_required_dialog.dart';

class ProductCard extends ConsumerStatefulWidget {
  final SatayItem item;

  const ProductCard({super.key, required this.item});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  final GlobalKey _imageKey = GlobalKey();
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.value != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Transform.scale(
          scale: _isHovered ? 1.03 : 1.0,
          child: GestureDetector(
            onTap: () {
              if (!widget.item.isAvailable) return;

              if (!isLoggedIn) {
                showLoginRequiredDialog(context);
                return;
              }
              showDialog(
                context: context,
                builder: (context) => CustomizeCartDialog(item: widget.item),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.07).round()),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(context),
                  _buildCardContent(context, isLoggedIn),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Image.network(
        widget.item.imageUrl,
        key: _imageKey,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.fastfood, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, bool isLoggedIn) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              "RM ${widget.item.price.toStringAsFixed(2)} / set",
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "1 Set = 10 sticks",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor:
                      widget.item.isAvailable ? Colors.deepOrange.shade50 : Colors.grey.shade200,
                  foregroundColor: widget.item.isAvailable ? Colors.deepOrange : Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: widget.item.isAvailable
                    ? () {
                        if (!isLoggedIn) {
                          showLoginRequiredDialog(context);
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (context) => CustomizeCartDialog(item: widget.item),
                        );
                      }
                    : null,
                child: Text(
                  widget.item.isAvailable ? "Add to Cart" : "Out of Stock",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


