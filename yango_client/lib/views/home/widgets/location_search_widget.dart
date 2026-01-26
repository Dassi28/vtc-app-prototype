import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class LocationSearchWidget extends StatefulWidget {
  final Function(String) onDestinationSelected;

  const LocationSearchWidget({
    super.key,
    required this.onDestinationSelected,
  });

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [
    'Marché Central, Yaoundé',
    'Aéroport International de Yaoundé',
    'Université de Yaoundé I',
    'Centre Commercial',
  ];

  final List<String> _searchResults = [];
  bool _isSearching = false;

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    await Future.delayed(const Duration(milliseconds: 500));

    // In real app, use Google Places API
    setState(() {
      _searchResults.clear();
      _searchResults.addAll([
        '$query, Yaoundé, Cameroun',
        '$query Centre, Douala',
        'Quartier $query, Yaoundé',
      ]);
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search input
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une destination',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _onSearch,
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (_searchResults.isEmpty && _searchController.text.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Recherches récentes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ..._recentSearches.map((search) => _buildLocationTile(
                              icon: Icons.history,
                              title: search,
                              onTap: () => widget.onDestinationSelected(search),
                            )),
                      ] else ...[
                        ..._searchResults.map((result) => _buildLocationTile(
                              icon: Icons.location_on,
                              title: result,
                              onTap: () => widget.onDestinationSelected(result),
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey[600]),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}
