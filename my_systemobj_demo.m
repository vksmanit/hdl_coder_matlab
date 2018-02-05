design_name = 'mlhdlc_sysobj_ex';  
testbench_name = 'mlhdlc_sysobj_ex_tb';


mlhdlc_demo_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdlcoderdemos', 'matlabhdlcoderdemos');
mlhdlc_temp_dir = [tempdir 'mlhdlc_sysobj_intro'];

% Create a temporary folder and copy the MATLAB files.
cd(tempdir);
[~, ~, ~] = rmdir(mlhdlc_temp_dir, 's');
mkdir(mlhdlc_temp_dir);
cd(mlhdlc_temp_dir);

copyfile(fullfile(mlhdlc_demo_dir, [design_name,'.m*']), mlhdlc_temp_dir);
copyfile(fullfile(mlhdlc_demo_dir, [testbench_name,'.m*']), mlhdlc_temp_dir);

