import 'package:flutter/material.dart';
import '../../const/colors.dart';
import 'package:untitled/widgets/visittime/show.dart';
import 'package:untitled/widgets/visittime/uploadimage.dart';
import 'form.dart';

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
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            backgroundColor: AppColors.greenDark,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: _toggleDrawer,
                  child: SizedBox(
                    height: 70,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: AppColors.greenDark,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list, color: AppColors.greenLight), // الأيقونة بجانب النص
                            SizedBox(width: 10), // مساحة بين الأيقونة والنص
                            Text(
                              isExpanded ? 'Visited Team' : '',
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
                      _buildListTile(0, 'Shows', Icons.keyboard_double_arrow_right, isExpanded),

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
        color: isSelected ? Colors.black : AppColors.light, // تغيير لون الأيقونة
      ),
      title: isExpanded
          ? Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : AppColors.greenLight, // تغيير لون النص
        ),
      )
          : null,
      selected: isSelected,
      selectedTileColor: AppColors.greenLight, // تغيير لون العنصر المحدد
      shape: isSelected
          ? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // شكل دائري للعنصر المحدد
      )
          : null,
      onTap: () => widget.onItemTapped(index),
    );
  }
}

class Mainvisit extends StatefulWidget {
  @override
  _Mainvisit createState() => _Mainvisit();
}

class _Mainvisit extends State<Mainvisit> {
  int _selectedIndex = 0;
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier<bool>(true);

  final List<Widget> _pages = [
    ShowsScreen(),

  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _pages.length) { // التحقق من الفهرس قبل التحديد
      setState(() {
        _selectedIndex = index;
      });
    }
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
