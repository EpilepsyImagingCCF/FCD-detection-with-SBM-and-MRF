clear all; close all;

current_dir = pwd;
addpath(current_dir)

% Change to appropriate subject dir
SUBJECTS_DIR = 'path\to\subjects';
cd(SUBJECTS_DIR)
setenv SUBJECTS_DIR .
addpath('path\to\FreeSurfer matlab dir')

% Change to appropriate prefix for all subjects
Subs_P = dir(fullfile(SUBJECTS_DIR, 'P*'));
Subs_HC = dir(fullfile(SUBJECTS_DIR, 'V*'));
Subs = [Subs_P; Subs_HC];

Subs = {Subs.name};

for order = 1:length(Subs)
    
    s = Subs{order};
    
    IC = MRIread(['',s,'/surf/lh.pial.K.mgh']);
    IC.vol(IC.vol > 2) = 0;
    IC.vol(IC.vol > -2) = 0;
    MRIwrite(IC, ['', s, '/surf/lh.pial.K_filtered_2.mgh']);

    IC_white = read_curv(['', s, '/surf/lh.white.K.crv']);
    IC_white(IC_white > 2) = 0;
    IC_white(IC_white > -2) = 0;
    IC.vol = IC_white';
    MRIwrite(IC, ['', s, '/surf/lh.white.K_filtered_2.mgh']);

    clear IC

    IC = MRIread(['', s, '/surf/rh.pial.K.mgh']);
    IC.vol(IC.vol > 2) = 0;
    IC.vol(IC.vol > -2) = 0;
    MRIwrite(IC, ['', s, '/surf/rh.pial.K_filtered_2.mgh']);    

    IC_white = read_curv(['', s, '/surf/rh.white.K.crv']);
    IC_white(IC_white > 2) = 0;
    IC_white(IC_white > -2) = 0;
    IC.vol = IC_white';
    MRIwrite(IC, ['', s, '/surf/rh.white.K_filtered_2.mgh']);

    clear IC
end

cd(current_dir)