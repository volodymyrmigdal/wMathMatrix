(function _Basic_s_() {

'use strict';

let _ = _global_.wTools;
let abs = Math.abs;
let min = Math.min;
let max = Math.max;
let pow = Math.pow;
let pi = Math.PI;
let sin = Math.sin;
let cos = Math.cos;
let sqrt = Math.sqrt;
let sqr = _.math.sqr;

let Parent = null;
let Self = _.Matrix;

_.assert( _.objectIs( _.vectorAdapter ) );
_.assert( _.routineIs( Self ), 'wMatrix is not defined, please include wMatrix.s first' );

// --
// borrow
// --

function _tempBorrow( src, dims, index )
{
  let bufferConstructor;

  _.assert( arguments.length === 3, 'Expects exactly three arguments' );
  _.assert( src instanceof Self || src === null );
  _.assert( _.arrayIs( dims ) || dims instanceof Self || dims === null );

  if( !src )
  {

    // debugger;
    // bufferConstructor = this.array.ArrayType;
    // bufferConstructor = this.longDescriptor;
    bufferConstructor = this.long.longDescriptor.type;
    if( !dims )
    dims = src;

  }
  else
  {

    if( src.buffer )
    bufferConstructor = src.buffer.constructor;

    if( !dims )
    if( src.dims )
    dims = src.dims.slice();

  }

  if( dims instanceof Self )
  dims = dims.dims;

  _.assert( _.routineIs( bufferConstructor ) );
  _.assert( _.arrayIs( dims ) );
  _.assert( index < 3 );

  let key = bufferConstructor.name + '_' + dims.join( 'x' );

  if( this._tempMatrices[ index ][ key ] )
  return this._tempMatrices[ index ][ key ];

  let result = this._tempMatrices[ index ][ key ] = new Self
  ({
    dims,
    buffer : new bufferConstructor( this.AtomsPerMatrixForDimensions( dims ) ),
    inputTransposing : 0,
  });

  return result;
}

//

function tempBorrow1( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 0 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 0 );
  else
  return Self._tempBorrow( null, src , 0 );

}

//

function tempBorrow2( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 1 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 1 );
  else
  return Self._tempBorrow( null, src , 1 );

}

//

function tempBorrow3( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 2 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 2 );
  else
  return Self._tempBorrow( null, src , 2 );

}

// --
// mul
// --

function matrixPow( exponent )
{

  _.assert( _.instanceIs( this ) );
  _.assert( arguments.length === 1, 'Expects single argument' );

  let t = this.tempBorrow( this );

  // self.mul(  );

}

//

function mul_static( dst, srcs )
{

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.arrayIs( srcs ) );
  _.assert( srcs.length >= 2 );

  /* adjust dst */

  if( dst === null )
  {
    let dims = [ this.NrowOf( srcs[ srcs.length-2 ] ) , this.NcolOf( srcs[ srcs.length-1 ] ) ];
    dst = this.makeSimilar( srcs[ srcs.length-1 ] , dims );
  }

  /* adjust srcs */

  srcs = srcs.slice();
  let dstClone = null;

  let odst = dst;
  dst = this.from( dst );

  for( let s = 0 ; s < srcs.length ; s++ )
  {

    srcs[ s ] = this.from( srcs[ s ] );

    if( dst === srcs[ s ] || dst.buffer === srcs[ s ].buffer )
    {
      if( dstClone === null )
      {
        dstClone = dst.tempBorrow1();
        dstClone.copy( dst );
      }
      srcs[ s ] = dstClone;
    }

    _.assert( dst.buffer !== srcs[ s ].buffer );

  }

  /* */

  dst = this.mul2Matrices( dst , srcs[ 0 ] , srcs[ 1 ] );

  /* */

  if( srcs.length > 2 )
  {

    let dst2 = null;
    let dst3 = dst;
    for( let s = 2 ; s < srcs.length ; s++ )
    {
      let src = srcs[ s ];
      if( s % 2 === 0 )
      {
        dst2 = dst.tempBorrow2([ dst3.dims[ 0 ], src.dims[ 1 ] ]);
        this.mul2Matrices( dst2 , dst3 , src );
      }
      else
      {
        dst3 = dst.tempBorrow3([ dst2.dims[ 0 ], src.dims[ 1 ] ]);
        this.mul2Matrices( dst3 , dst2 , src );
      }
    }

    if( srcs.length % 2 === 0 )
    this.CopyTo( odst, dst3 );
    else
    this.CopyTo( odst, dst2 );

  }
  else
  {
    this.CopyTo( odst, dst );
  }

  return odst;
}

//

function mul( srcs )
{
  let dst = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.arrayIs( srcs ) );

  return dst.Self.mul( dst, srcs );
}

//

function Mul2Matrices( dst, src1, src2 )
{

  src1 = this.fromForReading( src1 );
  src2 = this.fromForReading( src2 );

  if( dst === null )
  {
    dst = this.make([ src1.dims[ 0 ], src2.dims[ 1 ] ]);
  }

  _.assert( arguments.length === 3, 'Expects exactly three arguments' );
  _.assert( src1.dims.length === 2 );
  _.assert( src2.dims.length === 2 );
  _.assert( dst instanceof Self );
  _.assert( src1 instanceof Self );
  _.assert( src2 instanceof Self );
  _.assert( dst !== src1 );
  _.assert( dst !== src2 );
  _.assert( src1.dims[ 1 ] === src2.dims[ 0 ], 'Expects src1.dims[ 1 ] === src2.dims[ 0 ]' );
  _.assert( src1.dims[ 0 ] === dst.dims[ 0 ] );
  _.assert( src2.dims[ 1 ] === dst.dims[ 1 ] );

  let nrow = dst.nrow;
  let ncol = dst.ncol;

  for( let r = 0 ; r < nrow ; r++ )
  for( let c = 0 ; c < ncol ; c++ )
  {
    let row = src1.rowVectorGet( r );
    let col = src2.colVectorGet( c );
    let dot = this.vectorAdapter.dot( row, col );
    dst.atomSet( [ r, c ], dot );
  }

  return dst;
}

//

function mul2Matrices( src1, src2 )
{
  let dst = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  return dst.Self.mul2Matrices( dst, src1, src2 );
}

//

function mulLeft( src )
{
  let dst = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  // debugger;

  dst.mul([ dst, src ])

  return dst;
}

//

function mulRight( src )
{
  let dst = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  // debugger;

  dst.mul([ src, dst ]);
  // dst.mul2Matrices( src, dst );

  return dst;
}

// //
//
// function _mulMatrix( src )
// {
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( src.breadth.length === 1 );
//
//   let self = this;
//   let atomsPerRow = self.atomsPerRow;
//   let atomsPerCol = src.atomsPerCol;
//   let code = src.buffer.constructor.name + '_' + atomsPerRow + 'x' + atomsPerCol;
//
//   debugger;
//   if( !self._tempMatrices[ code ] )
//   self._tempMatrices[ code ] = self.Self.make([ atomsPerCol, atomsPerRow ]);
//   let dst = self._tempMatrices[ code ]
//
//   debugger;
//   dst.mul2Matrices( dst, self, src );
//   debugger;
//
//   self.copy( dst );
//
//   return self;
// }
//
// //
//
// function mulAssigning( src )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( self.breadth.length === 1 );
//
//   let result = self._mulMatrix( src );
//
//   return result;
// }
//
// //
//
// function mulCopying( src )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( src.dims.length === 2 );
//   _.assert( self.dims.length === 2 );
//
//   let result = Self.make( src.dims );
//   result.mul2Matrices( result, self, src );
//
//   return result;
// }

// --
// partial accessors
// --

function zero()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  self.atomEach( ( it ) => self.atomSet( it.indexNd, 0 ) );

  return self;
}

//

function identify()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  self.atomEach( ( it ) => it.indexNd[ 0 ] === it.indexNd[ 1 ] ? self.atomSet( it.indexNd, 1 ) : self.atomSet( it.indexNd, 0 ) );

  return self;
}

//

function diagonalSet( src )
{
  let self = this;
  let length = Math.min( self.atomsPerCol, self.atomsPerRow );

  if( src instanceof Self )
  src = src.diagonalVectorGet();

  src = self.vectorAdapter.FromMaybeNumber( src, length );

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( self.dims.length === 2 );
  _.assert( src.length === length );

  for( let i = 0 ; i < length ; i += 1 )
  {
    self.atomSet( [ i, i ], src.eGet( i ) );
  }

  return self;
}

//

function diagonalVectorGet()
{
  let self = this;
  let length = Math.min( self.atomsPerCol, self.atomsPerRow );
  let strides = self._stridesEffective;

  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( self.dims.length === 2 );

  let result = self.vectorAdapter.FromSubLongWithStride( self.buffer, self.offset, length, strides[ 0 ] + strides[ 1 ] );

  return result;
}

//

function triangleLowerSet( src )
{
  let self = this;
  let nrow = self.nrow;
  let ncol = self.ncol;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( self.dims.length === 2 );

  _.assert( _.numberIs( src ) || src instanceof Self );

  if( src instanceof Self )
  {

    _.assert( src.dims[ 0 ] >= self.dims[ 0 ] );
    _.assert( src.dims[ 1 ] >= min( self.dims[ 0 ]-1, self.dims[ 1 ] ) );

    for( let r = 1 ; r < nrow ; r++ )
    {
      let cl = min( r, ncol );
      for( let c = 0 ; c < cl ; c++ )
      self.atomSet( [ r, c ], src.atomGet([ r, c ]) );
    }

  }
  else
  {

    for( let r = 1 ; r < nrow ; r++ )
    {
      let cl = min( r, ncol );
      for( let c = 0 ; c < cl ; c++ )
      self.atomSet( [ r, c ], src );
    }

  }

  return self;
}

//

function triangleUpperSet( src )
{
  let self = this;
  let nrow = self.nrow;
  let ncol = self.ncol;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( self.dims.length === 2 );

  _.assert( _.numberIs( src ) || src instanceof Self );

  if( src instanceof Self )
  {

    _.assert( src.dims[ 1 ] >= self.dims[ 1 ] );
    _.assert( src.dims[ 0 ] >= min( self.dims[ 1 ]-1, self.dims[ 0 ] ) );

    for( let c = 1 ; c < ncol ; c++ )
    {
      let cl = min( c, nrow );
      for( let r = 0 ; r < cl ; r++ )
      self.atomSet( [ r, c ], src.atomGet([ r, c ]) );
    }

  }
  else
  {

    for( let c = 1 ; c < ncol ; c++ )
    {
      let cl = min( c, nrow );
      for( let r = 0 ; r < cl ; r++ )
      self.atomSet( [ r, c ], src );
    }

  }

  return self;
}

// --
// transformer
// --

// function applyMatrixToVector( dstVector )
// {
//   let self = this;
//
//   _.assert( 0, 'deprecated' );
//
//   self.vectorAdapter.matrixApplyTo( dstVector, self );
//
//   return self;
// }

//

// function matrixHomogenousApply( dstVector )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1 )
//   _.assert( 0, 'not tested' );
//
//   self.vectorAdapter.matrixHomogenousApply( dstVector, self );
//
//   return self;
// }

function matrixApplyTo( dstVector )
{
  let self = this;

  if( self.hasShape([ 3, 3 ]) )
  {

    let dstVectorv = self.vectorAdapter.From( dstVector );
    let x = dstVectorv.eGet( 0 );
    let y = dstVectorv.eGet( 1 );
    let z = dstVectorv.eGet( 2 );

    let s00 = self.atomGet([ 0, 0 ]), s10 = self.atomGet([ 1, 0 ]), s20 = self.atomGet([ 2, 0 ]);
    let s01 = self.atomGet([ 0, 1 ]), s11 = self.atomGet([ 1, 1 ]), s21 = self.atomGet([ 2, 1 ]);
    let s02 = self.atomGet([ 0, 2 ]), s12 = self.atomGet([ 1, 2 ]), s22 = self.atomGet([ 2, 2 ]);

    dstVectorv.eSet( 0 , s00 * x + s01 * y + s02 * z );
    dstVectorv.eSet( 1 , s10 * x + s11 * y + s12 * z );
    dstVectorv.eSet( 2 , s20 * x + s21 * y + s22 * z );

    return dstVector;
  }
  else if( self.hasShape([ 2, 2 ]) )
  {

    let dstVectorv = self.vectorAdapter.From( dstVector );
    let x = dstVectorv.eGet( 0 );
    let y = dstVectorv.eGet( 1 );

    let s00 = self.atomGet([ 0, 0 ]), s10 = self.atomGet([ 1, 0 ]);
    let s01 = self.atomGet([ 0, 1 ]), s11 = self.atomGet([ 1, 1 ]);

    dstVectorv.eSet( 0 , s00 * x + s01 * y );
    dstVectorv.eSet( 1 , s10 * x + s11 * y );

    return dstVector;
  }

  return Self.mul( dstVector, [ self, dstVector ] );
}

//

function matrixHomogenousApply( dstVector )
{
  let self = this;
  let _dstVector = self.vectorAdapter.From( dstVector );
  let dstLength = dstVector.length;
  let ncol = self.ncol;
  let nrow = self.nrow;
  let result = new Array( nrow );

  _.assert( arguments.length === 1 )
  _.assert( dstLength === ncol-1 );

  result[ dstLength ] = 0;
  for( let i = 0 ; i < nrow ; i += 1 )
  {
    let row = self.rowVectorGet( i );

    result[ i ] = 0;
    for( let j = 0 ; j < dstLength ; j++ )
    result[ i ] += row.eGet( j ) * _dstVector.eGet( j );
    result[ i ] += row.eGet( dstLength );

  }

  for( let j = 0 ; j < dstLength ; j++ )
  _dstVector.eSet( j, result[ j ] / result[ dstLength ] );

  return dstVector;
}

//

function matrixDirectionsApply( dstVector )
{
  let self = this;
  let dstLength = dstVector.length;
  let ncol = self.ncol;
  let nrow = self.nrow;

  _.assert( arguments.length === 1 )
  _.assert( dstLength === ncol-1 );

  debugger;

  Self.mul( v, [ self.submatrix([ [ 0, v.length ], [ 0, v.length ] ]), v ] );
  self.vectorAdapter.normalize( v );

  return dstVector;
}
//

function positionGet()
{
  let self = this;
  let l = self.length;
  let loe = self.atomsPerElement;
  let result = self.colVectorGet( l-1 );

  _.assert( arguments.length === 0, 'Expects no arguments' );

  // debugger;
  result = self.vectorAdapter.FromSubLong( result, 0, loe-1 );

  //let result = self.elementsInRangeGet([ (l-1)*loe, l*loe ]);
  //let result = self.vectorAdapter.FromSubLong( this.buffer, 12, 3 );

  return result;
}

//

function positionSet( src )
{
  let self = this;
  src = self.vectorAdapter.FromLong( src );
  let dst = this.positionGet();

  _.assert( src.length === dst.length );

  self.vectorAdapter.assign( dst, src );
  return dst;
}

//

function scaleMaxGet( dst )
{
  let self = this;
  let scale = self.scaleGet( dst );
  let result = _.avector.reduceToMaxAbs( scale ).value;
  return result;
}

//

function scaleMeanGet( dst )
{
  let self = this;
  let scale = self.scaleGet( dst );
  let result = _.avector.reduceToMean( scale );
  return result;
}

//

function scaleMagGet( dst )
{
  let self = this;
  let scale = self.scaleGet( dst );
  let result = _.avector.mag( scale );
  return result;
}

//

function scaleGet( dst )
{
  let self = this;
  let l = self.length-1;
  let loe = self.atomsPerElement;

  if( dst )
  {
    if( _.arrayIs( dst ) )
    dst.length = self.length-1;
  }

  if( dst )
  l = dst.length;
  else
  dst = self.vectorAdapter.From( self.long.longMakeZeroed( self.length-1 ) );

  let dstv = self.vectorAdapter.From( dst );

  _.assert( arguments.length === 0 || arguments.length === 1 );

  for( let i = 0 ; i < l ; i += 1 )
  dstv.eSet( i , self.vectorAdapter.mag( self.vectorAdapter.FromSubLong( this.buffer, loe*i, loe-1 ) ) );

  return dst;
}

//

function scaleSet( src )
{
  let self = this;
  src = self.vectorAdapter.FromLong( src );
  let l = self.length;
  let loe = self.atomsPerElement;
  let cur = this.scaleGet();

  _.assert( src.length === l-1 );

  for( let i = 0 ; i < l-1 ; i += 1 )
  self.vectorAdapter.mulScalar( self.eGet( i ), src.eGet( i ) / cur[ i ] );

  let lastElement = self.eGet( l-1 );
  self.vectorAdapter.mulScalar( lastElement, 1 / lastElement.eGet( loe-1 ) );

}

//

function scaleAroundSet( scale, center )
{
  let self = this;
  scale = self.vectorAdapter.FromLong( scale );
  let l = self.length;
  let loe = self.atomsPerElement;
  let cur = this.scaleGet();

  _.assert( scale.length === l-1 );

  for( let i = 0 ; i < l-1 ; i += 1 )
  self.vectorAdapter.mulScalar( self.eGet( i ), scale.eGet( i ) / cur[ i ] );

  let lastElement = self.eGet( l-1 );
  self.vectorAdapter.mulScalar( lastElement, 1 / lastElement.eGet( loe-1 ) );

  /* */

  debugger;
  center = self.vectorAdapter.FromLong( center );
  let pos = self.vectorAdapter.slice( scale );
  pos = self.vectorAdapter.FromLong( pos );
  self.vectorAdapter.mulScalar( pos, -1 );
  self.vectorAdapter.addScalar( pos, 1 );
  self.vectorAdapter.mulVectors( pos, center );

  self.positionSet( pos );

}

//

function scaleApply( src )
{
  let self = this;
  src = self.vectorAdapter.FromLong( src );
  let ape = self.atomsPerElement;
  let l = self.length;

  for( let i = 0 ; i < ape ; i += 1 )
  {
    let c = self.rowVectorGet( i );
    c = self.vectorAdapter.FromSubLong( c, 0, l-1 );
    self.vectorAdapter.mulVectors( c, src );
  }

}

// --
// reducer
// --

function closest( insElement )
{
  let self = this;
  insElement = self.vectorAdapter.FromLong( insElement );
  let result =
  {
    index : null,
    distance : +Infinity,
  }

  _.assert( arguments.length === 1, 'Expects single argument' );

  for( let i = 0 ; i < self.length ; i += 1 )
  {

    let d = self.vectorAdapter.distanceSqr( insElement, self.eGet( i ) );
    if( d < result.distance )
    {
      result.distance = d;
      result.index = i;
    }

  }

  result.distance = sqrt( result.distance );

  return result;
}

//

function furthest( insElement )
{
  let self = this;
  insElement = self.vectorAdapter.FromLong( insElement );
  let result =
  {
    index : null,
    distance : -Infinity,
  }

  _.assert( arguments.length === 1, 'Expects single argument' );

  for( let i = 0 ; i < self.length ; i += 1 )
  {

    let d = self.vectorAdapter.distanceSqr( insElement, self.eGet( i ) );
    if( d > result.distance )
    {
      result.distance = d;
      result.index = i;
    }

  }

  result.distance = sqrt( result.distance );

  return result;
}

//

function elementMean()
{
  let self = this;

  let result = self.elementAdd();

  self.vectorAdapter.divScalar( result, self.length );

  return result;
}

//

function minmaxColWise()
{
  let self = this;

  let minmax = self.distributionRangeSummaryValueColWise();
  let result = Object.create( null );

  result.min = self.long.longMakeUndefined( self.buffer, minmax.length );
  result.max = self.long.longMakeUndefined( self.buffer, minmax.length );

  for( let i = 0 ; i < minmax.length ; i += 1 )
  {
    result.min[ i ] = minmax[ i ][ 0 ];
    result.max[ i ] = minmax[ i ][ 1 ];
  }

  return result;
}

//

function minmaxRowWise()
{
  let self = this;

  let minmax = self.distributionRangeSummaryValueRowWise();
  let result = Object.create( null );

  result.min = self.long.longMakeUndefined( self.buffer, minmax.length );
  result.max = self.long.longMakeUndefined( self.buffer, minmax.length );

  for( let i = 0 ; i < minmax.length ; i += 1 )
  {
    result.min[ i ] = minmax[ i ][ 0 ];
    result.max[ i ] = minmax[ i ][ 1 ];
  }

  return result;
}

//

function determinant()
{
  let self = this;
  let l = self.length;

  if( l === 0 )
  return 0;

  let iterations = _.math.factorial( l );
  let result = 0;

  _.assert( l === self.atomsPerElement );

  /* */

  let sign = 1;
  let index = [];
  for( let i = 0 ; i < l ; i += 1 )
  index[ i ] = i;

  /* */

  function add()
  {
    let r = 1;
    for( let i = 0 ; i < l ; i += 1 )
    r *= self.atomGet([ index[ i ], i ]);
    r *= sign;
    // console.log( index );
    // console.log( r );
    result += r;
    return r;
  }

  /* */

  function swap( a, b )
  {
    let v = index[ a ];
    index[ a ] = index[ b ];
    index[ b ] = v;
    sign *= -1;
  }

  /* */

  let i = 0;
  while( i < iterations )
  {

    for( let s = 0 ; s < l-1 ; s++ )
    {
      let r = add();
      //console.log( 'add', i, index, r );
      swap( s, l-1 );
      i += 1;
    }

  }

  /* */

  // 00
  // 01
  //
  // 012
  // 021
  // 102
  // 120
  // 201
  // 210

  // console.log( 'determinant', result );

  return result;
}

// --
// relations
// --

let Statics = /* qqq : split static routines. ask how */
{

  /* borrow */

  _tempBorrow,
  tempBorrow : tempBorrow1,
  tempBorrow1,
  tempBorrow2,
  tempBorrow3,

  /* mul */

  mul : mul_static,
  mul2Matrices : Mul2Matrices,

  /* var */

  _tempMatrices : [ Object.create( null ) , Object.create( null ) , Object.create( null ) ],

}

/*
map
filter
reduce
zip
*/

// --
// declare
// --

let Extension =
{

  // borrow

  _tempBorrow,
  tempBorrow : tempBorrow1,
  tempBorrow1,
  tempBorrow2,
  tempBorrow3,

  // mul

  pow : matrixPow,
  mul,
  mul2Matrices,
  mulLeft,
  mulRight,

  // partial accessors

  zero,
  identify,
  diagonalSet,
  diagonalVectorGet,
  triangleLowerSet,
  triangleUpperSet,

  // transformer

  matrixApplyTo,
  matrixHomogenousApply,
  matrixDirectionsApply,

  positionGet,
  positionSet,
  scaleMaxGet,
  scaleMeanGet,
  scaleMagGet,
  scaleGet,
  scaleSet,
  scaleAroundSet,
  scaleApply,

  // reducer

  closest,
  furthest,

  elementMean,

  minmaxColWise,
  minmaxRowWise,

  determinant,

  //

  Statics,

}

_.classExtend( Self, Extension );
_.assert( Self.mul2Matrices === Mul2Matrices );
_.assert( Self.prototype.mul2Matrices === mul2Matrices );

})();
