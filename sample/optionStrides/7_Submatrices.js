if( typeof 'module' !== undefined )
require( 'wmathmatrix' );

let _ = wTools;

var matrix = _.Matrix
({
  buffer : [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ],
  dims : [ 4, 3 ],
  offset : 1,
  strides : [ 4, 1 ],
});

console.log( `matrix :\n${ matrix.toStr() }` );
/* log : matrix :
+1,  +2,  +3,
+5,  +6,  +7,
+9,  +10, +11,
+13, +14, +15,
*/

var sub1 = matrix.submatrix( [ [ 1, 4 ], [ 0, 2 ] ] );
console.log( `submatrix1 :\n${ sub1.toStr() }` );
/* log : matrix :
+5,  +6,
+9,  +10,
*/

var sub2 = matrix.submatrix( [ [ 1, 4 ], [ 1, 3 ] ] );
console.log( `submatrix1 :\n${ sub1.toStr() }` );
/* log : matrix :
+6,  +7,
+10, +11,
*/

sub1.mul( [ sub1, 2 ] );
sub2.mul( [ sub2, 3 ] );
console.log( matrix.toStr() );
/* log : matrix :
+1,  +2,  +3,
+10, +36, +21,
+27, +60, +33,
+13, +14, +15,
*/