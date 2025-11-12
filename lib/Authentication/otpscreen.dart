import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Otpscreen extends StatefulWidget {
  const Otpscreen({super.key});

  @override
  State<Otpscreen> createState() => _OtpscreenState();
}

class _OtpscreenState extends State<Otpscreen> {
  List<String> otp = List.filled(6, '');
  int resendTimer = 30;
  bool isLoading = false;
  String mobileNumber = '9876543210';
  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (resendTimer > 0) {
        setState(() => resendTimer--);
        _startResendTimer();
      }
    });
  }

  void _handleOTPChange(String value, int index) {
    setState(() {
      otp[index] = value;
      // Auto move to next field
      if (value.isNotEmpty && index < 5) {
        FocusScope.of(context).nextFocus();
      }
      // Auto move to previous field on backspace
      if (value.isEmpty && index > 0) {
        FocusScope.of(context).previousFocus();
      }
    });
  }
  void _resendOTP() {
    setState(() {
      otp = List.filled(6, '');
      resendTimer = 30;
    });
    _startResendTimer();
    // Add your resend OTP logic here
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 40),
              child: Text(
                "We Just Send an Message",
                style: GoogleFonts.dmSans(
                  // color: , // Example text color
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            SizedBox(height: height * 0.02),

            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  TextSpan(
                    text: "Enter the security code we send to \n",
                    style: GoogleFonts.dmSans(
                      // color: Apptheme.blackcolor, // Example text color
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  TextSpan(
                    text: "mobile number: ",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      // color: Apptheme.blackcolor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
            codecontainer(width),
          ],
        ),
      ),
    );
  }

  Widget codecontainer(double width) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return SizedBox(
              width: width * 0.13,
              child: TextField(
                onChanged: (value) => _handleOTPChange(value, index),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        // Resend OTP
        Center(
          child: TextButton(
            onPressed: resendTimer == 0 ? _resendOTP : null,
            child: Text(
              resendTimer == 0
                  ? 'Resend OTP'
                  : 'Resend in $resendTimer seconds',
            ),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: width * 0.03),
                // backgroundColor: Apptheme.submitcolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: Text(
                "verify",
                style: GoogleFonts.poppins(
                  fontSize: width * 0.04,
                  // color: Apptheme.whitecolor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
