import 'package:matrix2d/matrix2d.dart';
import 'dart:math';

class Anchor {
  double centerX;
  double centerY;
  double radius;

  Anchor({required this.centerX, required this.centerY, required this.radius});
}

List trilaterationMethod(List<Anchor> anchorList, double maxDistance) {
  var matrixA = [];
  var matrixB = [];
  const Matrix2d m2d = Matrix2d();

  for (int idx = 1; idx <= anchorList.length - 1; idx++) {
    // value A
    matrixA.add([
      anchorList[idx].centerX - anchorList[0].centerX,
      anchorList[idx].centerY - anchorList[0].centerY
    ]);
    // value b
    matrixB.add([
      ((pow(anchorList[idx].centerX, 2) +
                  pow(anchorList[idx].centerY, 2) -
                  pow(
                      anchorList[idx].radius > maxDistance
                          ? maxDistance
                          : anchorList[idx].radius,
                      2)) -
              (pow(anchorList[0].centerX, 2) +
                  pow(anchorList[0].centerY, 2) -
                  pow(
                      anchorList[0].radius > maxDistance
                          ? maxDistance
                          : anchorList[0].radius,
                      2))) /
          2
    ]);
  }
  // anchorList = [{3,1},{3,2},{1,2},{1,1}]
  // print(matrixA); => [[0.0, 1.0], [-2.0, 1.0], [-2.0, 0.0]]
  // print(matrixB); => [[-0.9207553403769446], [-3.213201936607501], [-4.713201936607501]]

  var matrixATranspose = transposeDouble(matrixA);
  // print(matrixATranspose);
  // => [[0.0, -2.0, -2.0], [1.0, 1.0, 0.0]]

  var matrixInverse = dim2InverseMatrix(m2d.dot(
          matrixATranspose, matrixA) // m2d.dot => nhân 2 ma trận lại với nhau
      );
  //  print(matrixInverse);
  // => [[0.16666666666666666, 0.16666666666666666], [0.16666666666666666, 0.6666666666666666]]
  var matrixDot = m2d.dot(matrixInverse, matrixATranspose);
  // print(matrixDot);
  // => [[0.16666666666666666, -0.16666666666666666, -0.3333333333333333], [0.6666666666666666, 0.3333333333333333, -0.3333333333333333]]

  var position = m2d.dot(matrixDot, matrixB);
  // print(position);
  // => [[1.9531417449075927], [-0.1138368935846299]]

  return position;
}

// matrix transpose
// tra ve ma tran chua toa do x va y cua cac diem
List transposeDouble(List list) {
  var shape = list.shape;
  // print(shape); => [3,2]
  var temp = List.filled(shape[1], 0.0)
      .map((e) => List.filled(shape[0], 0.0))
      .toList();
  // print(temp); => [[0,0,0],[0,0,0]]
  for (var i = 0; i < shape[1]; i++) {
    // 0 -> 2
    for (var j = 0; j < shape[0]; j++) {
      // 0 -> 3
      temp[i][j] = list[j][i];
    }
  }
  return temp;
}

// inverse matrix
List dim2InverseMatrix(List list) {
  // print(list); => [[8.0, -2.0], [-2.0, 2.0]]
  var shape = list.shape;
  var temp = List.filled(shape[1], 0.0)
      .map((e) => List.filled(shape[0], 0.0))
      .toList();
  var determinant = list[0][0] * list[1][1] - list[1][0] * list[0][1]; // 12
  temp[0][0] = list[1][1] / determinant;
  temp[0][1] = -list[0][1] / determinant;
  temp[1][0] = -list[1][0] / determinant;
  temp[1][1] = list[0][0] / determinant;

  return temp;
}
