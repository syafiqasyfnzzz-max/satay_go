// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PickupDetailsForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController pickupTimeController;

  const PickupDetailsForm({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.pickupTimeController,
  }) : super(key: key);

  @override
  State<PickupDetailsForm> createState() => _PickupDetailsFormState();
}

class _PickupDetailsFormState extends State<PickupDetailsForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pickup Details",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: widget.nameController,
          decoration: const InputDecoration(
            labelText: "Customer Name",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: const InputDecoration(
            labelText: "Phone Number",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            // Check if the picked time is valid (before 9:59 PM)
            if (picked != null) {
              final lastOrderTime = TimeOfDay(hour: 21, minute: 59); // 9:59 PM
              final now = TimeOfDay.now();

              // Ensure the selected time is not in the past or after the last order time
              bool isTimeValid = false;
              if (picked.hour > now.hour ||
                  (picked.hour == now.hour && picked.minute >= now.minute)) {
                if (picked.hour < lastOrderTime.hour ||
                    (picked.hour == lastOrderTime.hour &&
                        picked.minute <= lastOrderTime.minute)) {
                  isTimeValid = true;
                }
              }

              if (isTimeValid) {
                setState(() {
                  widget.pickupTimeController.text = picked.format(context);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          "Please select a valid pickup time before 9:59 PM.")),
                );
              }
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: widget.pickupTimeController,
              decoration: const InputDecoration(
                labelText: "Pickup Time",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
