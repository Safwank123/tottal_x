import 'package:flutter/material.dart';

class SortBottomSheet extends StatefulWidget {
  final String currentSort;
  final Function(String) onApplySort;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onApplySort,
  });

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late String _groupValue;

  @override
  void initState() {
    super.initState();
    _groupValue = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sort", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildRadio("All"),
          _buildRadio("Age: Elder"),
          _buildRadio("Age: Younger"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRadio(String value) {
    return InkWell(
      onTap: () {
        setState(() {
          _groupValue = value;
        });
        widget.onApplySort(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _groupValue,
              activeColor: Colors.blue,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _groupValue = val;
                  });
                  widget.onApplySort(val);
                }
              },
            ),
            Text(value, style: const TextStyle(fontSize: 16   ,color: Colors.black, )),
          ],
        ),
      ),
    );
  }
}
