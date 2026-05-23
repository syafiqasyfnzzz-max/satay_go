// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  void _showMenuForm(
    BuildContext context, {
    String? docId,
    Map<String, dynamic>? existingData,
  }) {
    final nameController =
        TextEditingController(text: existingData?['name'] ?? '');
    final priceController =
        TextEditingController(text: existingData?['price']?.toString() ?? '');
    final imageController =
        TextEditingController(text: existingData?['imageUrl'] ?? '');
    final extraSambalPriceController = TextEditingController(
      text: existingData?['extraSambalPrice']?.toString() ?? '1.00',
    );

    final categories = ['Chicken', 'Beef', 'Lamb', 'Combo'];
    final tags = ['Popular', 'Bestseller', 'Hot', 'New', 'Combo'];
    final allSauces = [
      'Sambal Kacang',
      'Kuah Kacang Pedas',
      'Sweet Peanut Sauce',
      'No Sauce',
    ];

    String selectedCategory = categories.contains(existingData?['category'])
        ? existingData!['category']
        : 'Chicken';

    String selectedTag =
        tags.contains(existingData?['tag']) ? existingData!['tag'] : 'Popular';

    List<String> selectedSauces = existingData?['sauces'] is List
        ? List<String>.from(existingData!['sauces'])
        : ['Sambal Kacang'];

    if (selectedSauces.isEmpty) {
      selectedSauces = ['Sambal Kacang'];
    }

    bool isAvailable = existingData?['isAvailable'] ?? true;
    bool extraSambalAvailable = existingData?['extraSambalAvailable'] ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                docId == null ? "Add Menu Item" : "Edit Menu Item",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Item Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedCategory = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Price per Set (RM)",
                          hintText: "Example: 15",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: "Image URL",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedTag,
                        decoration: const InputDecoration(
                          labelText: "Tag / Label",
                          border: OutlineInputBorder(),
                        ),
                        items: tags.map((tag) {
                          return DropdownMenuItem(
                            value: tag,
                            child: Text(tag),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedTag = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade500),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Available Sauce Options",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Customer can choose up to 2 sauces",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...allSauces.map((sauce) {
                              final isSelected = selectedSauces.contains(sauce);

                              return CheckboxListTile(
                                value: isSelected,
                                dense: true,
                                activeColor: Colors.deepOrange,
                                contentPadding: EdgeInsets.zero,
                                title: Text(sauce),
                                onChanged: (checked) {
                                  setDialogState(() {
                                    if (checked == true) {
                                      if (sauce == 'No Sauce') {
                                        selectedSauces = ['No Sauce'];
                                      } else {
                                        selectedSauces.remove('No Sauce');

                                        if (selectedSauces.length < 2) {
                                          selectedSauces.add(sauce);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Only 2 sauces can be selected.",
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      selectedSauces.remove(sauce);

                                      if (selectedSauces.isEmpty) {
                                        selectedSauces = ['Sambal Kacang'];
                                      }
                                    }
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        value: extraSambalAvailable,
                        title: const Text("Extra Sambal Available"),
                        subtitle:
                            const Text("Allow customer to add extra sambal"),
                        activeColor: Colors.deepOrange,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setDialogState(() => extraSambalAvailable = value);
                        },
                      ),
                      if (extraSambalAvailable) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: extraSambalPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Extra Sambal Price (RM)",
                            hintText: "Example: 1.00",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SwitchListTile(
                        value: isAvailable,
                        title: const Text("Menu Available"),
                        subtitle: const Text("Show this item to customers"),
                        activeColor: Colors.deepOrange,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setDialogState(() => isAvailable = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        priceController.text.trim().isEmpty ||
                        imageController.text.trim().isEmpty ||
                        selectedSauces.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please complete all required fields"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final data = <String, dynamic>{
                      'name': nameController.text.trim(),
                      'category': selectedCategory,
                      'price':
                          double.tryParse(priceController.text.trim()) ?? 0.0,
                      'imageUrl': imageController.text.trim(),
                      'tag': selectedTag,
                      'sauces': selectedSauces,
                      'maxSauceSelection': 2,
                      'extraSambalAvailable': extraSambalAvailable,
                      'extraSambalPrice': double.tryParse(
                            extraSambalPriceController.text.trim(),
                          ) ??
                          0.0,
                      'isAvailable': isAvailable,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    try {
                      if (docId == null) {
                        data['createdAt'] = FieldValue.serverTimestamp();

                        await FirebaseFirestore.instance
                            .collection('menu')
                            .add(data);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('menu')
                            .doc(docId)
                            .update(data);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              docId == null
                                  ? "Menu item added successfully"
                                  : "Menu item updated successfully",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(docId == null ? "ADD ITEM" : "UPDATE ITEM"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMenuItem(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Menu Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('menu').doc(docId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Menu item deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case "Chicken":
        return Colors.orange;
      case "Beef":
        return Colors.brown;
      case "Lamb":
        return Colors.purple;
      case "Combo":
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case "Chicken":
        return Icons.egg_alt;
      case "Beef":
        return Icons.restaurant;
      case "Lamb":
        return Icons.kebab_dining;
      case "Combo":
        return Icons.fastfood;
      default:
        return Icons.restaurant_menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        title: const Text(
          "Manage Menu CRUD",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        onPressed: () => _showMenuForm(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('menu').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            );
          }

          final menuItems = snapshot.data?.docs ?? [];

          if (menuItems.isEmpty) {
            return const Center(
              child: Text(
                "No menu items yet.\nTap Add Item to create one.",
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final doc = menuItems[index];
              final data = doc.data();

              final name = data['name'] ?? 'Unnamed';
              final category = data['category'] ?? '-';
              final price = ((data['price'] ?? 0) as num).toDouble();
              final available = data['isAvailable'] ?? true;
              final tag = data['tag'] ?? '';
              final imageUrl = data['imageUrl'] ?? '';

              final sauces = data['sauces'] is List
                  ? List<String>.from(data['sauces'])
                  : <String>[];

              final extraSambalAvailable =
                  data['extraSambalAvailable'] ?? false;

              final extraSambalPrice =
                  ((data['extraSambalPrice'] ?? 0) as num).toDouble();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if (imageUrl.toString().isNotEmpty)
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.orange.shade50,
                              child: const Center(
                                child: Icon(
                                  Icons.fastfood,
                                  color: Colors.deepOrange,
                                  size: 45,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    _categoryColor(category).withOpacity(0.12),
                                child: Icon(
                                  _categoryIcon(category),
                                  color: _categoryColor(category),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                available ? "Available" : "Unavailable",
                                style: TextStyle(
                                  color: available ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "RM ${price.toStringAsFixed(2)} / set",
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Category: $category"),
                          Text("Tag: $tag"),
                          Text(
                            "Sauce options: ${sauces.join(', ')}",
                          ),
                          Text(
                            "Max sauce choice: 2",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          Text(
                            extraSambalAvailable
                                ? "Extra sambal: RM ${extraSambalPrice.toStringAsFixed(2)}"
                                : "Extra sambal: Not available",
                            style: TextStyle(
                              color: extraSambalAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showMenuForm(
                                      context,
                                      docId: doc.id,
                                      existingData: data,
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Edit"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _deleteMenuItem(context, doc.id);
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text("Delete"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
