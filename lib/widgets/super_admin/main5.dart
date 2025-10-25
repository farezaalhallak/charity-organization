import 'package:flutter/material.dart';
import '../../const/colors.dart';
import 'package:untitled/widgets/receptionist/previousDonationRequest.dart';
import 'package:untitled/widgets/receptionist/previousrequest.dart';
import 'package:untitled/widgets/receptionist/userid.dart';
import 'package:untitled/widgets/store/storelog.dart';
import 'package:untitled/widgets/super_admin/permission.dart';
import 'package:untitled/widgets/super_admin/permissionto%20role.dart';
import 'package:untitled/widgets/super_admin/profileinfo.dart';
import 'package:untitled/widgets/super_admin/requestDonationLog.dart';
import 'package:untitled/widgets/super_admin/role.dart';
import 'package:untitled/widgets/visittime/show.dart';

import 'camoaugns.dart';
import 'campaignDonationLog.dart';
import 'complaint.dart';
import 'decrease.dart';
import 'employee.dart';
import 'fundlog.dart';

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
            backgroundColor: AppColors.greenDark, // تعديل لون الخلفية
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: _toggleDrawer,
                  child: SizedBox(
                    height: 70,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: AppColors.greenDark, // تعديل لون الخلفية
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list, color: AppColors.greenLight), // الأيقونة بجانب النص
                            SizedBox(width: 10), // مساحة بين الأيقونة والنص
                            Text(
                              isExpanded ? 'Super Admin' : '',
                              style: TextStyle(
                                color: AppColors.greenLight, // تعديل لون النص
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
                      _buildListTile(0, 'Campaign DonationLogs', Icons.keyboard_double_arrow_right, isExpanded),
                      SizedBox(height: 5),
                      _buildListTile(1, 'Show Complaint', Icons.keyboard_double_arrow_right, isExpanded),
                      SizedBox(height: 5),
                      _buildListTile(2, 'Employee', Icons.keyboard_double_arrow_right, isExpanded),
                      SizedBox(height: 5),
                      _buildListTile(3, 'FundLogs', Icons.keyboard_double_arrow_right, isExpanded),
                      SizedBox(height: 5),
                      _buildListTile(4, 'PermissionS', Icons.keyboard_double_arrow_right, isExpanded),
                      SizedBox(height: 5),
                      _buildListTile(5, 'Role', Icons.keyboard_double_arrow_right, isExpanded),
                      SizedBox(height: 5),
                      _buildListTile(6, 'ProfileInfo', Icons.keyboard_double_arrow_right, isExpanded),
                      SizedBox(height: 5),
                      _buildListTile(7, 'Request Donation Logs', Icons.keyboard_double_arrow_right, isExpanded),
                      SizedBox(height: 5),
                      _buildListTile(8, 'Campaign', Icons.keyboard_double_arrow_right, isExpanded),
                      _buildListTile(9, 'decrease fund', Icons.keyboard_double_arrow_right, isExpanded),

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

// Main5.dart
class Main5 extends StatefulWidget {
  @override
  _Main5 createState() => _Main5();
}

class _Main5 extends State<Main5> {
  int _selectedIndex = 0;
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier<bool>(true);

  final List<Widget> _pages = [
    CampaignDonationLogsScreen(),
    ShowComplaintScreen(),
    EmployeeScreen(),
    FundLogsScreen(),
    PermissionScreen(),
    RoleScreen(),
    ProfileInfoScreen(),
    RequestDonationLogsScreen(),
    CampaignListScreen(),
    DecreaseFundScreen()
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
