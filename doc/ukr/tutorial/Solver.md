# Матричне рішення

Розглядаються засоби для рішення систем лінійних рівнянь.

### Рішення системи лінійних рівнянь

Рішення системи з двох лінійних рівнянь

```
1*x1 - 2*x2 = -7;
3*x1 + 4*x2 = 39;
```

В компактній формі:

```
A*x = y
```

Знайти невідомі значення можна використавши статичну рутину `Solve`.

```js

var A = _.Matrix.MakeSquare
([
  1, -2,
  3,  4
]);
var y = [ -7, 39 ];
var x = _.Matrix.Solve( null, A, y );

console.log( `x :\n${ x }` );
/* log : x : [ 5, 6 ] */

```

Рутина `Solve` знайшла рішення для системи лінійних рівнянь заданої матрицею `A` та вектором `y`. Значення `x1` - `5`, a `x2` - `6`.

[Повернутись до змісту](../README.md#Туторіали)