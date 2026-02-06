import 'package:flutter/material.dart';

class InputDecorations {
  // Un método estático para decorar los "Inputs" (campos de texto)
  static InputDecoration authInputDecoration({
    required String hintText,
    required String labelText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      // Borde cuando el input está habilitado pero no seleccionado
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF01488e), // Tu color corporativo
        ),
      ),
      // Borde cuando estamos escribiendo en el input
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF01488e),
          width: 2,
        ),
      ),
      hintText: hintText,
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.grey),
      // Icono opcional al principio del campo
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Color(0xFF01488e))
          : null,
    );
  }
}