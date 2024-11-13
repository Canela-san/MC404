.text
.global node_op
node_op:
    lw t0, 0(a0) # a
    lb t1, 4(a0) # b
    lb t2, 5(a0) # c
    lh t3, 6(a0) # d
    
    # a + b - c + d
    
    add a0, t0, t1
    sub a0, a0, t2
    add a0, a0, t3
    
    ret