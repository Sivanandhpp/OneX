import 'package:flutter/material.dart';
import 'package:onex/global/theme_color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onex/screens/instagram/instagram_options.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.scaffoldBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(color: ThemeColor.primaryBlack),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Welcome back to",
                style: GoogleFonts.ubuntu(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: ThemeColor.grey),
              ),
              Row(
                children: [
                  Text(
                    "Your ",
                    style: GoogleFonts.ubuntu(
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                        color: ThemeColor.grey),
                  ),
                  Text(
                    "#OneX",
                    style: GoogleFonts.ubuntu(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.primaryTextColor),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(color: ThemeColor.primaryBlack),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Social Media Features!",
                    style: GoogleFonts.ubuntu(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.primaryTextColor),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InstagramOptions()),
                            );
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                                color: ThemeColor.primaryTextColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32))),
                            child: Center(
                              child: Text(
                                "FaceBook Options",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.secondaryTextColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                                color: ThemeColor.waGreen,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32))),
                            child: Center(
                              child: Text(
                                "WhatsApp Options",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColor.secondaryTextColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InstagramOptions()),
                      );
                    },
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: <Color>[
                              const Color(0xFFFAFF16),
                              const Color(0xFF8B62FF),
                            ],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      child: Center(
                        child: Text(
                          "Instagram Options",
                          style: GoogleFonts.ubuntu(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ThemeColor.secondaryTextColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
