import 'package:flutter/material.dart';

import '../../models/order_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusSteps = ['Pending', 'Preparing', 'Ready', 'Completed'];
    final currentStepIndex = statusSteps.indexOf(order.status);

    return Scaffold(
      appBar: AppBar(title: const Text("Track Order")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: ${order.orderId}",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Text("Order Status",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: statusSteps.length,
                itemBuilder: (context, index) {
                  final isCompleted = index <= currentStepIndex;
                  final isCurrent = index == currentStepIndex;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.deepOrange
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                              border: isCurrent
                                  ? Border.all(
                                      color: Colors.orangeAccent, width: 4)
                                  : null,
                            ),
                          ),
                          if (index != statusSteps.length - 1)
                            Container(
                              width: 2,
                              height: 50,
                              color: index < currentStepIndex
                                  ? Colors.deepOrange
                                  : Colors.grey[300],
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          statusSteps[index],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCompleted ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
