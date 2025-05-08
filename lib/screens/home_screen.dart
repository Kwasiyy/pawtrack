import 'package:flutter/material.dart';
import 'add_pet_screen.dart';
import 'pet_list_screen.dart';
import 'walk_tracker_screen.dart';
import 'reminders_screen.dart';
import 'pet_tips_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pets = /* fetch your Pet objects */;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Your Floofers', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pets.length,
            itemBuilder: (_, i) => _PetCard(pet: pets[i]),
          ),
        ),
        const SizedBox(height: 24),
        Text('Recent Walks', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        // … maybe a chart or list of recent walks …
      ],
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  const _PetCard({required this.pet});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(pet.photoUrl!, height: 120, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(pet.name, style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}