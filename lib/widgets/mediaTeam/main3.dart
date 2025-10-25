import 'package:flutter/material.dart';
import '../../const/colors.dart';
import 'aboutus.dart';
import 'ads.dart';
import 'previouscamougous.dart';

class CustomNavigationDrawer extends StatefulWidget {
  final Function(int) onItemTapped;
  final ValueNotifier<bool> isExpandedNotifier;
  final int selectedIndex;

  CustomNavigationDrawer({
    required this.onItemTapped,
    required this.isExpandedNotifier,
    required this.selectedIndex,
  });

  @override
  _CustomNavigationDrawerState createState() => _CustomNavigationDrawerState();
}

class _CustomNavigationDrawerState extends State<CustomNavigationDrawer> {
  void _toggleDrawer() {
    widget.isExpandedNotifier.value = !widget.isExpandedNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isExpandedNotifier,
      builder: (context, isExpanded, child) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: isExpanded ? 310 : 70,
          child: Drawer(
            elevation: 4, // Adjust elevation as needed
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            backgroundColor: AppColors.greenDark, // Dark green background
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: _toggleDrawer,
                  child: SizedBox(
                    height: 70,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: AppColors.greenDark, // Dark green header background
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu, color: AppColors.greenLight), // Icon for drawer toggle
                            SizedBox(width: 10),
                            Text(
                              isExpanded ? 'Media Team' : '',
                              style: TextStyle(
                                color: AppColors.greenLight,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      _buildListTile(0, 'About Us',  Icons.keyboard_double_arrow_right, isExpanded),
                      SizedBox(height: 8),
                      _buildListTile(1, 'Ads',  Icons.keyboard_double_arrow_right, isExpanded),
                      SizedBox(height: 8),
                      _buildListTile(2, 'Previous Campaigns',  Icons.keyboard_double_arrow_right, isExpanded),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ListTile _buildListTile(int index, String title, IconData icon, bool isExpanded) {
    final isSelected = widget.selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : AppColors.greenLight, // Icon color based on selection
      ),
      title: isExpanded
          ? Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.greenLight, // Text color based on selection
        ),
      )
          : null,
      selected: isSelected,
      selectedTileColor: AppColors.greenMedium, // Color for selected item
      shape: isSelected
          ? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners for selected item
      )
          : null,
      onTap: () => widget.onItemTapped(index),
    );
  }
}

class Main3 extends StatefulWidget {
  @override
  _Main3 createState() => _Main3();
}

class _Main3 extends State<Main3> {
  int _selectedIndex = 0;
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier<bool>(false);

  final List<Widget> _pages = [
    AboutUsScreen(),
    AdsScreen(),
    PreviousCampaignsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          CustomNavigationDrawer(
            onItemTapped: _onItemTapped,
            isExpandedNotifier: _isExpandedNotifier,
            selectedIndex: _selectedIndex,
          ),
          Expanded(
            child: Center(
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
