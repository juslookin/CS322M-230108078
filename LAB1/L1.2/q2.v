module q2(
    input [3:0]A,
    input [3:0]B,
    output C
);

assign C = (A[0]&B[0] | ~A[0]&~B[0]) & (A[1]&B[1] | ~A[1]&~B[1]) & (A[2]&B[2] | ~A[2]&~B[2]) & (A[3]&B[3] | ~A[3]&~B[3]);
endmodule
