% Auto generated wrapper function for cosimulation System object

% Generated by MATLAB 8.4 and HDL Coder 3.5

function [c_out,state_store] = hdl_matmul_sysobj_cosim(a_in,b_in)

% Declare persistent variables
persistent cosim_sys_obj;

if isempty(cosim_sys_obj)
   % Instantiate cosimulation System object
   InputSignals = {'a_in','b_in'};
   OutputSignals = {'c_out','state_store'};
   OutputSigned = [true,true];
   OutputFractionLengths = [0 0];
   TCLPreSimulationCommand = [....
    'puts "Running Simulink Cosimulation block.";' char(10) ...
    ' puts "Chip Name: --> hdl_matmul";' char(10) ...
    ' puts "Target language: --> VHDL";' char(10) ...
    ' puts "Target directory: --> /home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/hdlsrc";' char(10) ...
    ' puts [clock format [clock seconds]];' char(10) ...
    '# Clock force command;' char(10) ...
    'force /hdl_matmul/clk 0 0ns, 1 5ns -r 10ns;' char(10) ...
    '# Clock enable force command;' char(10) ...
    'force /hdl_matmul/clk_enable 0 0ns, 1 27ns;' char(10) ...
    '# Reset force command;' char(10) ...
    'force /hdl_matmul/reset 1 0ns, 0 27ns;' char(10) ...
    ''];
   TCLPostSimulationCommand = 'echo "done"';
   PreRunTime = {30,'ns'};
   SampleTime = {10,'ns'};
   cosim_sys_obj = hdlcosim( ...
      'InputSignals', InputSignals, ...
      'OutputSignals',OutputSignals, ...
      'OutputSigned',OutputSigned, ...
      'OutputFractionLengths',OutputFractionLengths, ...
      'TCLPreSimulationCommand',TCLPreSimulationCommand, ...
      'TCLPostSimulationCommand',TCLPostSimulationCommand,...
      'PreRunTime', PreRunTime, ...
      'Connection', {'Shared'}, ...
      'SampleTime',  SampleTime);
end

[c_out,state_store] = step(cosim_sys_obj,a_in,b_in);

