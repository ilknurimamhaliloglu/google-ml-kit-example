// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'camera_view.dart';
import 'coordinates_translator.dart';

final tiltAngleArray = [];
double totalTiltAngle = 0;
double averageTiltAngle = 0;
final hipsAngleArray = [];
double totalHipsAngle = 0;
double averageHipsAngle = 0;
final leftQAngleArray = [];
double totalLeftQAngle = 0;
double averageLeftQAngle = 0;
final rightQAngleArray = [];
double totalRightQAngle = 0;
double averageRightQAngle = 0;

class Landmark {
  double x;
  double y;
  Landmark({
    required this.x,
    required this.y,
  });
}

double getAngle(
  Landmark firstPoint,
  Landmark midPoint,
  Landmark lastPoint,
) {
  final double radians =
      atan2(lastPoint.y - midPoint.y, lastPoint.x - midPoint.x) -
          atan2(firstPoint.y - midPoint.y, firstPoint.x - midPoint.x);
  double degrees = radians * 180.0 / pi;

  // Angle should never be negative
  degrees = degrees.abs();

  if (degrees > 180.0) {
    // Always get the acute representation of the angle
    degrees = 360.0 - degrees;
  }

  return degrees;
}

double getTiltAngle(tiltAngle) {
  final tiltAngleArrayLength = tiltAngleArray.length;

  if (!tiltAngleArray.contains(tiltAngle)) {
    if (tiltAngleArrayLength == 20) {
      tiltAngleArray.removeAt(0);
    }
    tiltAngleArray.add(tiltAngle);
  }

  totalTiltAngle = tiltAngleArray.reduce((a, b) => a + b);
  averageTiltAngle = totalTiltAngle / tiltAngleArrayLength;
  return averageTiltAngle;
}

double getHipsAngle(hipsAngle) {
  final hipsAngleArrayLength = hipsAngleArray.length;

  if (!hipsAngleArray.contains(hipsAngle)) {
    if (hipsAngleArrayLength == 20) {
      hipsAngleArray.removeAt(0);
    }
    hipsAngleArray.add(hipsAngle);
  }

  totalHipsAngle = hipsAngleArray.reduce((a, b) => a + b);
  averageHipsAngle = totalHipsAngle / hipsAngleArrayLength;
  return averageHipsAngle;
}

double getLeftQAngle(leftQAngle) {
  final leftQAngleArrayLength = leftQAngleArray.length;

  if (!leftQAngleArray.contains(leftQAngle)) {
    if (leftQAngleArrayLength == 20) {
      leftQAngleArray.removeAt(0);
    }
    leftQAngleArray.add(leftQAngle);
  }

  totalLeftQAngle = leftQAngleArray.reduce((a, b) => a + b);
  averageLeftQAngle = totalLeftQAngle / leftQAngleArrayLength;
  return 180 - averageLeftQAngle;
}

double getRightQAngle(rightQAngle) {
  final rightQAngleArrayLength = rightQAngleArray.length;

  if (!rightQAngleArray.contains(rightQAngle)) {
    if (rightQAngleArrayLength == 20) {
      rightQAngleArray.removeAt(0);
    }
    rightQAngleArray.add(rightQAngle);
  }

  totalRightQAngle = rightQAngleArray.reduce((a, b) => a + b);
  averageRightQAngle = totalRightQAngle / rightQAngleArrayLength;
  return 180 - averageRightQAngle;
}

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

    final slopePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

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
          leftShoulderZ,
          rightShoulderX,
          rightShoulderY,
          rightShoulderZ,
          leftHipX,
          leftHipY,
          rightHipX,
          rightHipY,
          leftKneeX,
          leftKneeY,
          rightKneeX,
          rightKneeY,
          leftAnkleX,
          leftAnkleY,
          rightAnkleX,
          rightAnkleY;

      pose.landmarks.forEach((_, landmark) {
        if (landmark.likelihood > 0.5) {
          if (landmark.type == PoseLandmarkType.leftShoulder) {
            leftShoulderX = landmark.x;
            leftShoulderY = landmark.y;
            leftShoulderZ = landmark.z;
          } else if (landmark.type == PoseLandmarkType.rightShoulder) {
            rightShoulderX = landmark.x;
            rightShoulderY = landmark.y;
            rightShoulderZ = landmark.z;
          } else if (landmark.type == PoseLandmarkType.leftHip) {
            leftHipX = landmark.x;
            leftHipY = landmark.y;
          } else if (landmark.type == PoseLandmarkType.rightHip) {
            rightHipX = landmark.x;
            rightHipY = landmark.y;
          } else if (landmark.type == PoseLandmarkType.leftKnee) {
            leftKneeX = landmark.x;
            leftKneeY = landmark.y;
          } else if (landmark.type == PoseLandmarkType.rightKnee) {
            rightKneeX = landmark.x;
            rightKneeY = landmark.y;
          } else if (landmark.type == PoseLandmarkType.leftAnkle) {
            leftAnkleX = landmark.x;
            leftAnkleY = landmark.y;
          } else if (landmark.type == PoseLandmarkType.rightAnkle) {
            rightAnkleX = landmark.x;
            rightAnkleY = landmark.y;
          }
        }
      });

      print('M1: ${rightShoulderX!}, ${rightShoulderY!}');
      print('S1: ${leftShoulderX!}, ${leftShoulderY!}');

      if (!showAccelerationDialog) {
        final double tiltAngle = getAngle(
          // First point is right shoulder coordinates
          Landmark(x: rightShoulderX!, y: rightShoulderY!),
          // Mid point is left shoulder coordinates
          Landmark(x: leftShoulderX!, y: leftShoulderY!),
          // Last point is coordinates of the line parallel to the x-axis
          Landmark(x: rightShoulderX!, y: leftShoulderY!),
        );
        averageTiltAngle = getTiltAngle(tiltAngle);
        // print(averageTiltAngle);

        final double hipsAngle = getAngle(
          // First point is right hip coordinates
          Landmark(x: rightHipX!, y: rightHipY!),
          // Mid point is left hip coordinates
          Landmark(x: leftHipX!, y: leftHipY!),
          // Last point is coordinates of the line parallel to the x-axis
          Landmark(x: rightHipX!, y: leftHipY!),
        );
        averageHipsAngle = getHipsAngle(hipsAngle);

        final double leftQAngle = getAngle(
          // First point is left hip coordinates
          Landmark(x: leftHipX!, y: leftHipY!),
          // Mid point is left knee coordinates
          Landmark(x: leftKneeX!, y: leftKneeY!),
          // Last point is is left ankle coordinates
          Landmark(x: leftAnkleX!, y: leftAnkleY!),
        );
        averageLeftQAngle = getLeftQAngle(leftQAngle);

        final double rightQAngle = getAngle(
          // First point is right hip coordinates
          Landmark(x: rightHipX!, y: rightHipY!),
          // Mid point is right knee coordinates
          Landmark(x: rightKneeX!, y: rightKneeY!),
          // Last point is is right ankle coordinates
          Landmark(x: rightAnkleX!, y: rightAnkleY!),
        );
        averageRightQAngle = getRightQAngle(rightQAngle);

        if (rightShoulderY! < leftShoulderY!) {
          // Sola Eğik
          slopeText =
              'Sola Eğik\nTilt:, ${averageTiltAngle.toStringAsFixed(1)}\nHips: ${averageHipsAngle.toStringAsFixed(1)}\nLeftQ: ${averageLeftQAngle.toStringAsFixed(1)}\nRightQ: ${averageRightQAngle.toStringAsFixed(1)}';
        } else if (rightShoulderY! > leftShoulderY!) {
          // Sağa Eğik
          slopeText =
              'Sağa Eğik\nTilt: ${averageTiltAngle.toStringAsFixed(1)}\nHips: ${averageHipsAngle.toStringAsFixed(1)}\nLeftQ: ${averageLeftQAngle.toStringAsFixed(1)}\nRightQ: ${averageRightQAngle.toStringAsFixed(1)}';
        } else {
          // Eğik Değil
          slopeText = 'Eğik Değil';
        }
      }

      double middleOfShoulderX =
          (rightShoulderX! + ((leftShoulderX! - rightShoulderX!) / 2));
      double middleOfShoulderY =
          (rightShoulderY! + ((leftShoulderY! - rightShoulderY!) / 2));

      double middleOfHipX = (rightHipX! + ((leftHipX! - rightHipX!) / 2));
      double middleOfHipY = (rightHipY! + ((leftHipY! - rightHipY!) / 2));

      // double rangeX = (middleOfShoulderX - middleOfHipX).abs();
      // print(rangeX);
      //   if (rangeX < 30.0) {
      //     slopeText = 'Dik duruyor';
      //   } else {
      //     slopeText = 'Dik durmuyor';
      //   }

      //   if (slope < 5.0) {
      //     slopeText = 'Dik duruyor';
      //   } else {
      //     slopeText = 'Dik durmuyor';
      //   }

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
          middleOfHipY, slopePaint);
    }

    TextStyle textStyle = const TextStyle(
      color: Colors.red,
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
