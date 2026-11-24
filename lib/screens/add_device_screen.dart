import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/choice_buttons.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final List<String> pairingCode = ['4', '8', '2', '9', '1', '3'];

  String selectedType = 'Phone';
  bool alertOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add device'),
        backgroundColor: kBg,
        foregroundColor: kText,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      // The form stays at most 480 px wide and centered on tablets.
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Device name
                const Text(
                  'Device name',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  style: const TextStyle(color: kText),
                  cursorColor: kAccent,
                  // Tapping outside the field closes the keyboard
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: 'For example: My tablet',
                    hintStyle: const TextStyle(color: kMuted),
                    filled: true,
                    fillColor: kCard,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Device type
                const Text(
                  'Device type',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ChoiceButtons(
                  options: const ['Phone', 'Tablet', 'Laptop', 'Earbuds'],
                  selected: selectedType,
                  onSelected: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Pairing code: six boxes that share the width
                const Text(
                  'Pairing code',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (int i = 0; i < pairingCode.length; i++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kBorder),
                            ),
                            child: Text(
                              pairingCode[i],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter this code on the other device. Expires in 4 min 30 s',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Alert switch (the whole row is tappable)
                AppCard(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    title: const Text(
                      'Alert me when it drops below 20%',
                      style: TextStyle(fontSize: 15),
                    ),
                    value: alertOn,
                    onChanged: (value) {
                      setState(() {
                        alertOn = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons (both just go back, this is a mockup)
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: kBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Add device',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: kMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
