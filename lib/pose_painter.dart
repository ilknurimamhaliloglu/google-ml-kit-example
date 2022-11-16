import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.absoluteImageSize, this.rotation);

  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    String slopeText = '';
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(landmark.x, rotation, size, absoluteImageSize),
              translateY(landmark.y, rotation, size, absoluteImageSize),
            ),
            1,
            paint);
      });

      double? leftShoulderX,
          leftShoulderY,
          rightShoulderX,
          rightShoulderY,
          leftHipX,
          leftHipY,
          rightHipX,
          rightHipY;

      pose.landmarks.forEach((_, landmark) {
        if (landmark.type == PoseLandmarkType.leftShoulder) {
          leftShoulderX = landmark.x;
          leftShoulderY = landmark.y;
        } else if (landmark.type == PoseLandmarkType.rightShoulder) {
          rightShoulderX = landmark.x;
          rightShoulderY = landmark.y;
        } else if (landmark.type == PoseLandmarkType.leftHip) {
          leftHipX = landmark.x;
          leftHipY = landmark.y;
        } else if (landmark.type == PoseLandmarkType.rightHip) {
          rightHipX = landmark.x;
          rightHipY = landmark.y;
        }
      });

      double middleOfShoulderX =
          (rightShoulderX! + ((leftShoulderX! - rightShoulderX!) / 2));
      double middleOfShoulderY =
          (rightShoulderY! + ((leftShoulderY! - rightShoulderY!) / 2));

      double middleOfHipX = (rightHipX! + ((leftHipX! - rightHipX!) / 2));
      double middleOfHipY = (rightHipY! + ((leftHipY! - rightHipY!) / 2));

      double slope = (middleOfHipY - middleOfShoulderY) /
          (middleOfShoulderX - middleOfHipX);

      print(slope);

      if (slope < 5.0) {
        slopeText = 'Dik duruyor';
      } else {
        slopeText = 'Dik durmuyor';
      }

      void paintSpine(
        double middleOfShoulderX,
        double middleOfShoulderY,
        double middleOfHipX,
        double middleOfHipY,
        Paint paintType,
      ) {
        canvas.drawLine(
            Offset(
                translateX(
                    middleOfShoulderX, rotation, size, absoluteImageSize),
                translateY(
                    middleOfShoulderY, rotation, size, absoluteImageSize)),
            Offset(translateX(middleOfHipX, rotation, size, absoluteImageSize),
                translateY(middleOfHipY, rotation, size, absoluteImageSize)),
            paintType);
      }

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(translateX(joint1.x, rotation, size, absoluteImageSize),
                translateY(joint1.y, rotation, size, absoluteImageSize)),
            Offset(translateX(joint2.x, rotation, size, absoluteImageSize),
                translateY(joint2.y, rotation, size, absoluteImageSize)),
            paintType);
      }

      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);

      //Draw spine
      paintSpine(middleOfShoulderX, middleOfShoulderY, middleOfHipX,
          middleOfHipY, rightPaint);
    }

    TextStyle textStyle = const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );
    final textSpan = TextSpan(
      text: slopeText,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final xCenter = (size.width - textPainter.width) - 30;
    final yCenter = (size.height - textPainter.height) - 500;
    final offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
