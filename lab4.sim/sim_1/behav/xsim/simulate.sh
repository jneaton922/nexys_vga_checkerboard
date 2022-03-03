#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2021.2 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Wed Mar 02 20:44:06 EST 2022
# SW Build 3367213 on Tue Oct 19 02:47:39 MDT 2021
#
# IP Build 3369179 on Thu Oct 21 08:25:16 MDT 2021
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# simulate design
echo "xsim testbench_vgactl_behav -key {Behavioral:sim_1:Functional:testbench_vgactl} -tclbatch testbench_vgactl.tcl -log simulate.log"
xsim testbench_vgactl_behav -key {Behavioral:sim_1:Functional:testbench_vgactl} -tclbatch testbench_vgactl.tcl -log simulate.log

