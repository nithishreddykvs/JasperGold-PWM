clear -all
analyze -sv12 pwm.sv
elaborate -top pwm

clock clk
reset rst
