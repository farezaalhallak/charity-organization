import 'package:flutter/material.dart';
import 'package:untitled/seconde.dart';
import 'package:untitled/widgets/receptionist/charge.dart';
import 'package:untitled/widgets/receptionist/donationCampaigns.dart';
import 'package:untitled/widgets/super_admin/main5.dart';
import '../../globals.dart' as globals;
//import 'package:untitled/widgets/LoginPage.dart';

import 'package:untitled/widgets/adminsLogin/getAdminPermissions.dart';
import 'package:untitled/widgets/adminsLogin/login.dart';
//import 'package:untitled/widgets/dr.dart';
import 'package:untitled/widgets/mediaTeam/AddCampaignScreen.dart';
import 'package:untitled/widgets/mediaTeam/aboutus.dart';
import 'package:untitled/widgets/mediaTeam/ads.dart';
import 'package:untitled/widgets/mediaTeam/main3.dart';
import 'package:untitled/widgets/mediaTeam/previouscamougous.dart';
import 'package:untitled/widgets/receptionist/PreviousDonationCampaigns.dart';
import 'package:untitled/widgets/receptionist/addcomplaint.dart';
import 'package:untitled/widgets/receptionist/camoaugns.dart';
import 'package:untitled/widgets/receptionist/createacount.dart';
import 'package:untitled/widgets/receptionist/donationforfund.dart';
import 'package:untitled/widgets/receptionist/main4.dart';
import 'package:untitled/widgets/receptionist/p.dart';
import 'package:untitled/widgets/receptionist/previousDonationRequest.dart';
import 'package:untitled/widgets/receptionist/previousrequest.dart';

import 'package:untitled/widgets/receptionist/request.dart';
import 'package:untitled/widgets/receptionist/requestdetials.dart';
import 'package:untitled/widgets/receptionist/userid.dart';
import 'package:untitled/widgets/store/Categories.dart';
import 'package:untitled/widgets/store/item.dart';
import 'package:untitled/widgets/store/main2.dart';
import 'package:untitled/widgets/store/storelog.dart';
import 'package:untitled/widgets/store/subcategories.dart';

import 'package:untitled/widgets/super_admin/camoaugns.dart';
import 'package:untitled/widgets/super_admin/campaignDonationLog.dart';
import 'package:untitled/widgets/super_admin/complaint.dart';
import 'package:untitled/widgets/super_admin/decrease.dart';
import 'package:untitled/widgets/super_admin/employee.dart';
import 'package:untitled/widgets/super_admin/fundlog.dart';
import 'package:untitled/widgets/super_admin/permission.dart';
import 'package:untitled/widgets/super_admin/permissionto%20role.dart';
import 'package:untitled/widgets/super_admin/profileinfo.dart';
import 'package:untitled/widgets/super_admin/requestDonationLog.dart';
import 'package:untitled/widgets/super_admin/role.dart';
import 'package:untitled/widgets/visittime/form.dart';
import 'package:untitled/widgets/visittime/mainvisit.dart';
import 'package:untitled/widgets/visittime/show.dart';
import 'package:untitled/widgets/visittime/uploadimage.dart';

import 'const/colors.dart';

//import 'lottie.dart';
//import 'myapp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: AppColors.greenLight,
        scaffoldBackgroundColor: AppColors.greenLight,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.greenLight, // لون الـ AppBar
          foregroundColor: AppColors.greenMedium, // لون النص في الـ AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.greenDark, 
            foregroundColor: AppColors.light, // لون النص في الأزرار
    ),
        ),
          iconTheme: IconThemeData(
            color: AppColors.light, // لون الأيقونات الافتراضي
          ),



      ),
      home: Main3 (),
    );
  }
}
