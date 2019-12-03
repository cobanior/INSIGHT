# INSIGHT

## What is this?
This is a machine learning algorithm made to run on the Altera DE1 FPGA board, which takes user-inputted coordinates, 
and plots a best fit curve via VGA.

## What's in this repository?
All the files to make this work. The relevant files are as follows:
* background.v
  * This is the grapher module 
  * Takes in coefficients of a third-degree polynomial and draws to VGA display
* compute.v
  * Compute module
  * Takes in x-value and coefficients, outputs y-value
* polynomial_reg.v
  * Training module
  * Takes in coordinates, and fits a third-degree polynomial to the data

Created by Orest Cobani and Achu Mukundan
