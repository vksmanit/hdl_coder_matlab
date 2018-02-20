% Auto generated function to execute the generated cosimulation test bench
% 
% Generated by MATLAB 8.4 and HDL Coder 3.5

function run_hdl_matmul_cosim

% Launch HDL simulator
disp('### Launching ModelSim for cosimulation ');
launch_hdl_matmul_cosim;

% Wait for HDL simulator to ready
disp('### Waiting for ModelSim to start ');
pingHdlSim(180);

% Clear persistent variables before simulation
l_clearPersistentVariable;

% Clear persistent variables after simulation
onCleanupObj = onCleanup(@() l_clearPersistentVariable);

% Add current working directory to search path
savedPathVar = addpath(pwd);
restorePathObj = onCleanup(@() path(savedPathVar));

% Run generated test bench
disp('### Simulating generated test bench ');
% Exercise the compiled version of hdl_matmul_cosim in the generated test bench.
% To debug the test bench with the original function "hdl_matmul_cosim",
% replace the next line with "hdl_matmul_tb_cosim"
coder.runTest('localRunTest_hdl_matmul','hdl_matmul_cosim');
% To recompile MATLAB function "hdl_matmul_cosim",
% run the re-compilation function "localRecompile_hdl_matmul_cosim".
disp('### Finished Simulation');

end

function l_clearPersistentVariable
% Clear reference DUT function
clear hdl_matmul;

% Clear cosimulation System object wrapper function
clear hdl_matmul_sysobj_cosim;

% Clear cosimulation function
clear hdl_matmul_cosim;

% Clear generated MEX function
clear hdl_matmul_cosim_mex

end
