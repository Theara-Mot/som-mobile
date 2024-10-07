import 'package:flutter/material.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/model/class_model.dart';
import 'package:som_mobile/service/class_service.dart';
import 'package:som_mobile/util/build_backappbar.dart';
import 'package:som_mobile/util/build_button.dart';
import '../../util/build_textfield.dart';

class LevelPage extends StatefulWidget {
  @override
  _LevelPageState createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  final NameService _levelService = NameService('levels');
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLevelId;
  bool _isVisible = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: BuildBackAppbar(
        title: 'Levels',
        onActionPressed: () {
          setState(() {
            _isVisible = !_isVisible;
            if (!_isVisible) {
              _levelController.clear();
              _selectedLevelId = null;
            }
          });
        },
        actionIcon: !_isVisible ? Icons.add : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildTextField(
              labelText: 'Search Level',
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 8),
            if (_isVisible) ...[
              buildTextField(
                labelText: 'Enter Level Name',
                controller: _levelController,
              ),
              BuildButton(
                text: _selectedLevelId == null ? 'Add Level' : 'Update Level',
                onPressed: () async {
                  if (_selectedLevelId == null) {
                    await _levelService.addName(CDModel(id: '', name: _levelController.text));
                  } else {
                    await _levelService.updateName(CDModel(id: _selectedLevelId!, name: _levelController.text));
                    _selectedLevelId = null;
                  }
                  _levelController.clear();
                  _isVisible = false;
                  setState(() {});
                },
              ),
            ],
            StreamBuilder<List<CDModel>>(
              stream: _levelService.getNames(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final levels = snapshot.data ?? [];

                // Filter levels based on the search query
                final filteredLevels = levels.where((level) => level.name.toLowerCase().contains(_searchQuery)).toList();

                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredLevels.length,
                    itemBuilder: (context, index) {
                      final level = filteredLevels[index];
                      return GestureDetector(
                        onTap: () {
                          _isVisible = true;
                          _levelController.text = level.name;
                          _selectedLevelId = level.id;
                          setState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    child: Text('${index + 1}'),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    level.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await _levelService.deleteName(level.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
