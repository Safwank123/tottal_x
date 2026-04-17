import 'package:flutter/material.dart';

class CustomNumPad extends StatelessWidget {
  final Function(String) onNumberInvoked;
  final VoidCallback onDeleteInvoked;

  const CustomNumPad({
    super.key,
    required this.onNumberInvoked,
    required this.onDeleteInvoked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFE8EAF1), // Light grey background
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildBtn('1', ''),
              const SizedBox(width: 8),
              _buildBtn('2', 'ABC'),
              const SizedBox(width: 8),
              _buildBtn('3', 'DEF'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBtn('4', 'GHI'),
              const SizedBox(width: 8),
              _buildBtn('5', 'JKL'),
              const SizedBox(width: 8),
              _buildBtn('6', 'MNO'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBtn('7', 'PQRS'),
              const SizedBox(width: 8),
              _buildBtn('8', 'TUV'),
              const SizedBox(width: 8),
              _buildBtn('9', 'WXYZ'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: const SizedBox()),
              const SizedBox(width: 8),
              _buildBtn('0', '', flex: 1),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onDeleteInvoked,
                  child: Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: const Icon(Icons.backspace_outlined, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(String number, String letters, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => onNumberInvoked(number),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
              ),
              if (letters.isNotEmpty)
                Text(
                  letters,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
