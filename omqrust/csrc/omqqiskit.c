#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct { int n; size_t dim; double *re, *im; } qc;

qc q_new(int n) {
  qc q; q.n = n; q.dim = (size_t)1 << n;
  q.re = calloc(q.dim, sizeof(double));
  q.im = calloc(q.dim, sizeof(double));
  q.re[0] = 1.0;
  return q;
}
void q_free(qc q) { free(q.re); free(q.im); }

void q_gate(qc *q, int t, double m00, double m01, double m10, double m11) {
  size_t bit = (size_t)1 << t;
  for (size_t i = 0; i < q->dim; i++) {
    if (i & bit) continue;
    size_t j = i | bit;
    double ar = q->re[i], ai = q->im[i], br = q->re[j], bi = q->im[j];
    q->re[i] = m00 * ar + m01 * br;  q->im[i] = m00 * ai + m01 * bi;
    q->re[j] = m10 * ar + m11 * br;  q->im[j] = m10 * ai + m11 * bi;
  }
}
void q_h(qc *q, int t) { double s = 0.70710678118654752; q_gate(q, t, s, s, s, -s); }
void q_x(qc *q, int t) { q_gate(q, t, 0, 1, 1, 0); }
void q_z(qc *q, int t) { q_gate(q, t, 1, 0, 0, -1); }

void q_cx(qc *q, int c, int t) {
  size_t cb = (size_t)1 << c, tb = (size_t)1 << t;
  for (size_t i = 0; i < q->dim; i++) {
    if ((i & cb) && !(i & tb)) {
      size_t j = i | tb; double r, m;
      r = q->re[i]; q->re[i] = q->re[j]; q->re[j] = r;
      m = q->im[i]; q->im[i] = q->im[j]; q->im[j] = m;
    }
  }
}

void q_counts(qc *q, int shots) {
  size_t *cnt = calloc(q->dim, sizeof(size_t));
  for (int s = 0; s < shots; s++) {
    double r = (double)rand() / ((double)RAND_MAX + 1.0), acc = 0;
    size_t pick = q->dim - 1;
    for (size_t i = 0; i < q->dim; i++) {
      acc += q->re[i] * q->re[i] + q->im[i] * q->im[i];
      if (r < acc) { pick = i; break; }
    }
    cnt[pick]++;
  }
  printf("{");
  int first = 1;
  for (size_t i = 0; i < q->dim; i++) {
    if (!cnt[i]) continue;
    if (!first) printf(", ");
    first = 0;
    printf("'");
    for (int b = q->n - 1; b >= 0; b--) putchar((i >> b) & 1 ? '1' : '0');
    printf("': %zu", cnt[i]);
  }
  printf("}\n");
  free(cnt);
}

#ifndef OMQ_LIB
int main(void) {
  srand((unsigned)time(NULL));
  qc q = q_new(2);
  q_h(&q, 0);
  q_cx(&q, 0, 1);
  puts("OMQqiskit Bell test");
  q_counts(&q, 1024);
  q_free(q);
  return 0;
}
#endif
