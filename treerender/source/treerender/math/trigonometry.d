module treerender.math.trigonometry;

extern (C) void sincos(double a, double* sina, double* cosb) @nogc pure; // from libm
extern (C) void sincosf(float a, float* sina, float* cosb) @nogc pure; // from libm
extern (C) void sincosl(real a, real* sina, real* cosb) @nogc pure; // from libm

/// Calculate sin and cos at once. Greately reduce calculation time in tight loops.
void sinCos(T)(T a, out T sina, out T cosb) @nogc pure
  if (is(T == float) || is(T == double) || is(T == real))
{
  static if (is(T == float)) {
    return sincosf(a, &sina, &cosb);
  } else static if (is(T == double)) {
    return sincos(a, &sina, &cosb);
  } else {
    return sincosl(a, &sina, &cosb);
  }
}
