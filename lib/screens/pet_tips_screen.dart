// lib/screens/pet_tips_screen.dart
import 'package:flutter/material.dart';

class PetTipsScreen extends StatelessWidget {
  const PetTipsScreen({Key? key}) : super(key: key);

  // Example data – swap out or load from a service as you like
  static const _tips = <Map<String, Object>>[
    {
      'icon': Icons.water_drop,
      'title': 'Keep Fresh Water',
      'description': 'Always make sure your pet has access to fresh, clean water.'
    },
    {
      'icon': Icons.restaurant,
      'title': 'Balanced Diet',
      'description': 'Feed your pet a diet appropriate for its age, size, and activity level.'
    },
    {
      'icon': Icons.pets,
      'title': 'Regular Exercise',
      'description': 'Take dogs for daily walks and let cats play to keep them healthy and happy.'
    },
    {
      'icon': Icons.cleaning_services,
      'title': 'Grooming',
      'description': 'Brush your pet’s coat regularly and bathe as needed to prevent mats and skin issues.'
    },
    {
      'icon': Icons.medical_services,
      'title': 'Vet Check-ups',
      'description': 'Schedule routine veterinary exams to catch health issues early.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _tips.length,
      itemBuilder: (context, index) {
        final tip = _tips[index];
        return Card(
          child: ListTile(
            leading: Icon(
              tip['icon'] as IconData,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              tip['title'] as String,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              tip['description'] as String,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      },
    );
  }
}
