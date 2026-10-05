#include <stdio.h>
#include <stdlib.h>
typedef struct { size_t rows, cols; double *d; } nd;
nd nd_new(size_t r, size_t c) { nd a = {r, c, calloc(r * c, sizeof(double))}; return a; }
void nd_free(nd a) { free(a.d); }
nd nd_arange(size_t n) { nd a = nd_new(1, n); for (size_t i = 0; i < n; i++) a.d[i] = (double)i; return a; }
int nd_reshape(nd *a, size_t r, size_t c) { if (r * c != a->rows * a->cols) return -1; a->rows = r; a->cols = c; return 0; }
double nd_sum(nd a) { double s = 0; for (size_t i = 0; i < a.rows * a.cols; i++) s += a.d[i]; return s; }
double nd_mean(nd a) { return nd_sum(a) / (double)(a.rows * a.cols); }
nd nd_dot(nd a, nd b) {
  nd o = nd_new(a.rows, b.cols);
  for (size_t i = 0; i < a.rows; i++)
    for (size_t j = 0; j < b.cols; j++)
      for (size_t k = 0; k < a.cols; k++)
        o.d[i * o.cols + j] += a.d[i * a.cols + k] * b.d[k * b.cols + j];
  return o;
}
void nd_print(nd a) {
  for (size_t i = 0; i < a.rows; i++) {
    for (size_t j = 0; j < a.cols; j++) printf("%g ", a.d[i * a.cols + j]);
    printf("\n");
  }
}
int main(void) {
  nd a = nd_arange(12); nd_reshape(&a, 3, 4);
  nd b = nd_arange(12); nd_reshape(&b, 4, 3);
  nd c = nd_dot(a, b);
  puts("OMQnumpy"); nd_print(a);
  printf("sum=%g mean=%g\n", nd_sum(a), nd_mean(a));
  puts("a.b ="); nd_print(c);
  nd_free(a); nd_free(b); nd_free(c);
  return 0;
}
