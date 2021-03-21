import 'package:flutter/material.dart';

TextFormField globalTextFormField(String initialValue, void Function(String) onSaved, {InputDecoration decoration}) {
  if (decoration == null) {
    decoration = new InputDecoration(
        border: InputBorder.none
    );
  }
  return TextFormField(
      initialValue : initialValue,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      onSaved: onSaved,
      decoration: decoration
  );
}