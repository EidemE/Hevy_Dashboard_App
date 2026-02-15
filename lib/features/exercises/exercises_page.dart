import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/sidebar.dart';
import '../import/providers/import_provider.dart';
import '../../core/models/exercise_stats.dart';
import 'widgets/exercise_chart_card.dart';
import 'package:diacritic/diacritic.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  String _searchQuery = '';
  String _sortBy = 'workouts';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ImportProvider>(
          builder: (context, provider, child) {
            if (provider.exerciseStats.isEmpty) {
              return Text(AppLocalizations.of(context)!.allExercises);
            }
            final filteredAndSorted = _filterAndSort(provider.exerciseStats);
            return Text(AppLocalizations.of(context)!.allExercisesCount(filteredAndSorted.length));
          },
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: AppLocalizations.of(context)!.changeSorting,
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'workouts',
                child: Text(AppLocalizations.of(context)!.sortByWorkouts),
              ),
              PopupMenuItem(
                value: 'sets',
                child: Text(AppLocalizations.of(context)!.sortBySets),
              ),
              PopupMenuItem(
                value: 'weight',
                child: Text(AppLocalizations.of(context)!.sortByMaxWeight),
              ),
              PopupMenuItem(
                value: 'totalWeight',
                child: Text(AppLocalizations.of(context)!.sortByTotalWeight),
              ),
              PopupMenuItem(
                value: 'name',
                child: Text(AppLocalizations.of(context)!.sortByName),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sort,
                      size: 18,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getSortLabel(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: Consumer<ImportProvider>(
        builder: (context, provider, child) {
          if (provider.exerciseStats.isEmpty) {
            return SafeArea(
              top: false,
              child: _buildEmptyState(),
            );
          }

          final filteredAndSorted = _filterAndSort(provider.exerciseStats);

          return SafeArea(
            top: false,
            child: Column(
              children: [
                // Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchExercises,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
                    itemCount: filteredAndSorted.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ExerciseChartCard(
                          stats: filteredAndSorted[index],
                          csvData: provider.data,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<ExerciseStats> _filterAndSort(List<ExerciseStats> stats) {
    final query = _normalizeSearch(_searchQuery);

    // Filter
    var filtered = stats.where((stat) {
      if (query.isEmpty) return true;
      return _normalizeSearch(stat.name).contains(query);
    }).toList();

    // Sort
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'workouts':
          comparison = a.totalWorkouts.compareTo(b.totalWorkouts);
          break;
        case 'sets':
          comparison = a.totalSets.compareTo(b.totalSets);
          break;
        case 'weight':
          comparison = a.maxWeight.compareTo(b.maxWeight);
          break;
        case 'totalWeight':
          comparison = a.totalWeight.compareTo(b.totalWeight);
          break;
        case 'name':
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  String _normalizeSearch(String input) {
    return removeDiacritics(input).trim().toLowerCase();
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'workouts':
        return AppLocalizations.of(context)!.sortLabelWorkouts;
      case 'sets':
        return AppLocalizations.of(context)!.sortLabelSets;
      case 'weight':
        return AppLocalizations.of(context)!.sortLabelWeight;
      case 'totalWeight':
        return AppLocalizations.of(context)!.sortLabelTotal;
      case 'name':
        return AppLocalizations.of(context)!.sortLabelName;
      default:
        return '';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noExercisesFound,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noExercisesFoundDesc,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
