import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:satay_master_pro/models/satay_item.dart';
import 'package:satay_master_pro/providers/auth_provider.dart';
import 'package:satay_master_pro/widgets/dialogs/customize_cart_dialog.dart';
import 'package:satay_master_pro/widgets/dialogs/login_required_dialog.dart';

class ProductCard extends ConsumerWidget {
  final SatayItem item;

  const ProductCard({
    super.key,
    required this.item,
  });

  bool get _isNetworkImage {
    return item.imageUrl.startsWith('http://') ||
        item.imageUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.value != null;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        if (!item.isAvailable) return;

        if (!isLoggedIn) {
          showLoginRequiredDialog(context);
          return;
        }

        showDialog(
          context: context,
          builder: (context) => CustomizeCartDialog(item: item),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildContent(context, isLoggedIn),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: item.imageUrl.isEmpty
          ? _placeholderImage()
          : _isNetworkImage
              ? Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepOrange,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _placeholderImage();
                  },
                )
              : Image.asset(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return _placeholderImage();
                  },
                ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          color: Colors.grey,
          size: 42,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isLoggedIn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "RM ${item.price.toStringAsFixed(2)} / set",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "1 Set = 10 sticks",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: item.isAvailable
                  ? () {
                      if (!isLoggedIn) {
                        showLoginRequiredDialog(context);
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (context) => CustomizeCartDialog(item: item),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: item.isAvailable
                    ? Colors.deepOrange.shade50
                    : Colors.grey.shade200,
                foregroundColor: item.isAvailable
                    ? Colors.deepOrange
                    : Colors.grey.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                item.isAvailable ? "Add to Cart" : "Out of Stock",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}