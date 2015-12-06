Problem:    dgeo2
Rows:       8
Columns:    11
Non-zeros:  33
Status:     OPTIMAL
Objective:  z = 67.45 (MINimum)

   No.   Row name   St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 z            B          67.45                             
     2 oneserver[p1]
                    NS             1             1             =          15.5 
     3 oneserver[p2]
                    NS             1             1             =         11.35 
     4 oneserver[p3]
                    NS             1             1             =         16.55 
     5 oneserver[p4]
                    NS             1             1             =          14.6 
     6 oneserver[p5]
                    NS             1             1             =         19.55 
     7 makespan[m1] NU             0                          -0         -1.05 
     8 makespan[m2] NU             0                          -0         -0.95 

   No. Column name  St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 j[m1,p1]     B           0.55                           1 
     2 j[m1,p2]     B              0                           1 
     3 j[m1,p3]     NU             1                           1          -4.1 
     4 j[m1,p4]     NU             1                           1          -0.2 
     5 j[m1,p5]     B              0                           1 
     6 j[m2,p1]     B           0.45                           1 
     7 j[m2,p2]     NU             1                           1          -1.7 
     8 j[m2,p3]     B              0                           1 
     9 j[m2,p4]     B              0                           1 
    10 j[m2,p5]     NU             1                           1          -4.1 
    11 mksp         B           22.5                             

Karush-Kuhn-Tucker optimality conditions:

KKT.PE: max.abs.err = 2.22e-16 on row 3
        max.rel.err = 7.40e-17 on row 3
        High quality

KKT.PB: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

KKT.DE: max.abs.err = 3.55e-15 on column 5
        max.rel.err = 8.88e-17 on column 11
        High quality

KKT.DB: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

End of output
