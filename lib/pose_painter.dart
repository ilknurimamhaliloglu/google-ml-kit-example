// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'camera_view.dart';
import 'coordinates_translator.dart';

final List<double> tiltAngleArray = [];
double totalTiltAngle = 0;
double averageTiltAngle = 0;
final List<double> hipsAngleArray = [];
double totalHipsAngle = 0;
double averageHipsAngle = 0;
final List<double> leftQAngleArray = [];
double totalLeftQAngle = 0;
double averageLeftQAngle = 0;
final List<double> rightQAngleArray = [];
double totalRightQAngle = 0;
double averageRightQAngle = 0;
final List<double> shiftAngleArray = [];
double totalShiftAngle = 0;
double averageShiftAngle = 0;

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

double getAverageAngle(
  double angle,
  List<double> angleArray,
  double totalAngle,
  double averageAngle,
) {
  final angleArrayLength = angleArray.length;

  if (!angleArray.contains(angle)) {
    if (angleArrayLength == 20) {
      angleArray.removeAt(0);
    }
    angleArray.add(angle);
  }

  totalAngle = angleArray.reduce((a, b) => a + b);
  averageAngle = totalAngle / angleArrayLength;
  return averageAngle;
}

double getShiftAngle(shiftAngle) {
  final shiftAngleArrayLength = shiftAngleArray.length;

  if (!shiftAngleArray.contains(shiftAngle)) {
    if (shiftAngleArrayLength == 20) {
      shiftAngleArray.removeAt(0);
    }
    shiftAngleArray.add(shiftAngle);
  }

  totalShiftAngle = shiftAngleArray.reduce((a, b) => a + b);
  averageShiftAngle = totalShiftAngle / shiftAngleArrayLength;
  return averageShiftAngle;
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
          rightShoulderX,
          rightShoulderY,
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
          } else if (landmark.type == PoseLandmarkType.rightShoulder) {
            rightShoulderX = landmark.x;
            rightShoulderY = landmark.y;
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

      double middleOfShoulderX =
          (rightShoulderX! + ((leftShoulderX! - rightShoulderX!) / 2));
      double middleOfShoulderY =
          (rightShoulderY! + ((leftShoulderY! - rightShoulderY!) / 2));

      double middleOfHipX = (rightHipX! + ((leftHipX! - rightHipX!) / 2));
      double middleOfHipY = (rightHipY! + ((leftHipY! - rightHipY!) / 2));

      double height = 180;
      const double headHeight = 30;
      double spinalHeight = 0;

      if (!showAccelerationDialog) {
        final double tiltAngle = getAngle(
          // First point is right shoulder coordinates
          Landmark(x: rightShoulderX!, y: rightShoulderY!),
          // Mid point is left shoulder coordinates
          Landmark(x: leftShoulderX!, y: leftShoulderY!),
          // Last point is coordinates of the line parallel to the x-axis
          Landmark(x: rightShoulderX!, y: leftShoulderY!),
        );
        averageTiltAngle = getAverageAngle(
            tiltAngle, tiltAngleArray, totalTiltAngle, averageTiltAngle);

        final double hipsAngle = getAngle(
          // First point is right hip coordinates
          Landmark(x: rightHipX!, y: rightHipY!),
          // Mid point is left hip coordinates
          Landmark(x: leftHipX!, y: leftHipY!),
          // Last point is coordinates of the line parallel to the x-axis
          Landmark(x: rightHipX!, y: leftHipY!),
        );
        averageHipsAngle = getAverageAngle(
            hipsAngle, hipsAngleArray, totalHipsAngle, averageHipsAngle);

        final double leftQAngle = getAngle(
          // First point is left hip coordinates
          Landmark(x: leftHipX!, y: leftHipY!),
          // Mid point is left knee coordinates
          Landmark(x: leftKneeX!, y: leftKneeY!),
          // Last point is is left ankle coordinates
          Landmark(x: leftAnkleX!, y: leftAnkleY!),
        );
        // averageLeftQAngle = getLeftQAngle(leftQAngle);
        averageLeftQAngle = 180 -
            getAverageAngle(leftQAngle, leftQAngleArray, totalLeftQAngle,
                averageLeftQAngle);

        final double rightQAngle = getAngle(
          // First point is right hip coordinates
          Landmark(x: rightHipX!, y: rightHipY!),
          // Mid point is right knee coordinates
          Landmark(x: rightKneeX!, y: rightKneeY!),
          // Last point is is right ankle coordinates
          Landmark(x: rightAnkleX!, y: rightAnkleY!),
        );
        // averageRightQAngle = getRightQAngle(rightQAngle);
        averageRightQAngle = 180 -
            getAverageAngle(rightQAngle, rightQAngleArray, totalRightQAngle,
                averageRightQAngle);

        final double shiftAngle = getAngle(
          // First point is middle of shoulder coordinates
          Landmark(x: middleOfShoulderX, y: middleOfShoulderY),
          // Mid point is middle of hip coordinates
          Landmark(x: middleOfHipX, y: middleOfHipY),
          // Last point is coordinates of the line parallel to the x-axis
          Landmark(x: middleOfShoulderX, y: middleOfHipY),
        );
        averageShiftAngle = getShiftAngle(shiftAngle);

        height = height - headHeight;

        spinalHeight = (height * 2) / 5;

        double shiftCm = ((90 - averageShiftAngle) * spinalHeight) / 90;
        double shiftInch = shiftCm * 0.39;

        if (rightShoulderY! < leftShoulderY!) {
          // Sola Eğik
          slopeText =
              'Left\nTilt: ${averageTiltAngle.toStringAsFixed(1)}°\nHips: ${averageHipsAngle.toStringAsFixed(1)}°\nLeftQ: ${averageLeftQAngle.toStringAsFixed(1)}°\nRightQ: ${averageRightQAngle.toStringAsFixed(1)}°\nShift: ${shiftCm.toStringAsFixed(1)} cm\nShift: ${shiftInch.toStringAsFixed(1)} inch';
        } else if (rightShoulderY! > leftShoulderY!) {
          // Sağa Eğik
          slopeText =
              'Right\nTilt: ${averageTiltAngle.toStringAsFixed(1)}°\nHips: ${averageHipsAngle.toStringAsFixed(1)}°\nLeftQ: ${averageLeftQAngle.toStringAsFixed(1)}°\nRightQ: ${averageRightQAngle.toStringAsFixed(1)}°\nShift: ${shiftCm.toStringAsFixed(1)} cm\nShift: ${shiftInch.toStringAsFixed(1)} inch';
        } else {
          // Eğik Değil
          slopeText = 'Eğik Değil';
        }
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
