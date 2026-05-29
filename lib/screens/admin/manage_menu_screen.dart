import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageMenuScreen extends StatelessWidget {
  const ManageMenuScreen({super.key});

  void _openMenuDialog(
    BuildContext context, {
    String? docId,
    Map<String, dynamic>? data,
  }) {
    final name = TextEditingController(text: data?['name'] ?? '');
    final category = TextEditingController(text: data?['category'] ?? '');
    final price = TextEditingController(text: (data?['price'] ?? '').toString());
    final imageUrl = TextEditingController(text: data?['imageUrl'] ?? '');
    final tag = TextEditingController(text: data?['tag'] ?? '');
    final maxSauce = TextEditingController(
      text: (data?['maxSauceSelection'] ?? 2).toString(),
    );
    final extraPrice = TextEditingController(
      text: (data?['extraSambalPrice'] ?? 0).toString(),
    );
    final sauces = TextEditingController(
      text: data?['sauces'] is List
          ? List<String>.from(data!['sauces']).join(', ')
          : 'Sambal Kacang, Sambal Kacang Pedas, Sambal Kicap',
    );

    bool isAvailable = data?['isAvailable'] ?? true;
    bool extraSambalAvailable = data?['extraSambalAvailable'] ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(docId == null ? "Add Menu Item" : "Edit Menu Item"),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _field(name, "Name"),
                      _field(category, "Category"),
                      _field(price, "Price"),
                      _field(imageUrl, "Image URL"),
                      _field(tag, "Tag / Label"),
                      _field(sauces, "Sauces, separate by comma"),
                      _field(maxSauce, "Max Sauce Selection"),
                      SwitchListTile(
                        value: extraSambalAvailable,
                        title: const Text("Extra Sambal Available"),
                        onChanged: (v) {
                          setDialogState(() => extraSambalAvailable = v);
                        },
                      ),
                      _field(extraPrice, "Extra Sambal Price"),
                      SwitchListTile(
                        value: isAvailable,
                        title: const Text("Menu Available"),
                        onChanged: (v) {
                          setDialogState(() => isAvailable = v);
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
                    final menuData = {
                      'name': name.text.trim(),
                      'category': category.text.trim(),
                      'price': double.tryParse(price.text.trim()) ?? 0.0,
                      'imageUrl': imageUrl.text.trim(),
                      'tag': tag.text.trim(),
                      'sauces': sauces.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      'maxSauceSelection':
                          int.tryParse(maxSauce.text.trim()) ?? 2,
                      'extraSambalAvailable': extraSambalAvailable,
                      'extraSambalPrice':
                          double.tryParse(extraPrice.text.trim()) ?? 0.0,
                      'isAvailable': isAvailable,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    if (docId == null) {
                      await FirebaseFirestore.instance
                          .collection('menu')
                          .add(menuData);
                    } else {
                      await FirebaseFirestore.instance
                          .collection('menu')
                          .doc(docId)
                          .set(menuData, SetOptions(merge: true));
                    }

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(docId == null ? "Add" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        onPressed: () => _openMenuDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('menu').snapshots(),
        builder: (context, snapshot) {
          final items = snapshot.data?.docs ?? [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            );
          }

          if (items.isEmpty) {
            return const Center(child: Text("No menu items yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final doc = items[index];
              final data = doc.data();

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.deepOrange.shade50,
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? 'No name',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${data['category'] ?? '-'} • RM ${(data['price'] ?? 0).toString()}",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['isAvailable'] == true
                                ? "Available"
                                : "Unavailable",
                            style: TextStyle(
                              color: data['isAvailable'] == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _openMenuDialog(
                        context,
                        docId: doc.id,
                        data: data,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('menu')
                            .doc(doc.id)
                            .delete();
                      },
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