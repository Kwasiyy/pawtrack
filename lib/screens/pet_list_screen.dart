import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/walk.dart';
import '../services/database_service.dart';
import '../services/walk_service.dart';
import 'add_pet_screen.dart';
import 'walk_tracker_screen.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => PetListScreenState();
}

class PetListScreenState extends State<PetListScreen> {
  final List<Pet> _pets = [];
  final _databaseService = DatabaseService.instance;
  final _walkService = WalkService();
  final Map<String, List<Walk>> _petWalks = {};

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petsList = prefs.getStringList('pets') ?? [];
      
      final loadedPets = petsList
          .map((petJson) => Pet.fromJson(jsonDecode(petJson)))
          .toList();

      // Fetch walks for each pet
      final petWalks = <String, List<Walk>>{};
      for (final pet in loadedPets) {
        if (pet.id != null) {
          petWalks[pet.id!] = await _walkService.getWalks(pet.id!);
        }
      }

      setState(() {
        _pets.clear();
        _pets.addAll(loadedPets);
        _petWalks.clear();
        _petWalks.addAll(petWalks);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pets: $e')),
        );
      }
    }
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              pet.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${pet.petType} • ${pet.breed ?? "Unknown breed"}'),
                Text(
                  '${pet.age ?? "?"} years old • ${pet.gender}',
                ),
                if (pet.weight != null)
                  Text('Weight: ${pet.weight!.toStringAsFixed(1)} kg'),
                Text(
                  'Sterilized: ${pet.isSterilized ? "Yes" : "No"}',
                ),
              ],
            ),
            isThreeLine: true,
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.file(
                        File(pet.photoUrl!),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.pets,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.pets,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.directions_walk),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WalkTrackerScreen(
                          petId: pet.id!,
                        ),
                      ),
                    );
                    if (result == true && mounted) {
                      _fetchPets(); // Refresh walks after returning
                    }
                  },
                  tooltip: 'Start Walk',
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete_outline, color: Colors.red),
                            title: const Text('Delete Pet'),
                            subtitle: Text('This will delete ${pet.name} and all their data'),
                            onTap: () async {
                              Navigator.pop(context); // Close bottom sheet
                              // Show confirmation dialog
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Pet?'),
                                  content: Text('Are you sure you want to delete ${pet.name}? This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('DELETE'),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirm == true && mounted) {
                                final success = await _databaseService.deletePet(pet.id!);
                                if (success && mounted) {
                                  _fetchPets(); // Refresh the list
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${pet.name} has been deleted')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          if (pet.id != null) _buildPetOverview(pet),
          const Divider(),
          if (pet.id != null) _buildWalkHistory(pet.id!),
        ],
      ),
    );
  }

  Widget _buildPetOverview(Pet pet) {
    final walks = _petWalks[pet.id] ?? [];
    final totalDistance = walks.fold(0.0, (sum, walk) => sum + walk.distance);
    final totalDuration = walks.fold(0, (sum, walk) => sum + walk.durationSeconds);
    final totalWalks = walks.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildStatCard(
              'Distance',
              '${totalDistance.toStringAsFixed(0)}m',
              Icons.straighten,
            ),
          ),
          Expanded(
            child: _buildStatCard(
              'Time',
              _formatDuration(Duration(seconds: totalDuration)),
              Icons.timer,
            ),
          ),
          Expanded(
            child: _buildStatCard(
              'Walks',
              '$totalWalks',
              Icons.directions_walk,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkHistory(String petId) {
    final walks = _petWalks[petId] ?? [];
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Walks',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (walks.isEmpty)
            const Text('No walks recorded yet')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: walks.length,
              itemBuilder: (context, index) {
                final walk = walks[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.directions_walk),
                  title: Text('${walk.distance.toStringAsFixed(0)} meters'),
                  subtitle: Text(
                    '${Duration(seconds: walk.durationSeconds).inMinutes} minutes',
                  ),
                  trailing: Text(
                    walk.startTime.toString().substring(0, 10),
                    style: TextStyle(color: cs.primary),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPets,
        child: _pets.isEmpty
            ? const Center(
                child: Text('No pets added yet'),
              )
            : ListView.builder(
                itemCount: _pets.length,
                itemBuilder: (context, index) => _buildPetCard(_pets[index]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPetScreen(),
            ),
          );
          if (result == true && mounted) {
            _fetchPets();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
