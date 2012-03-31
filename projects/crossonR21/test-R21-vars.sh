3dDeconvolve -nodata 100 1.0 -num_stimts 3 -polort -1 \
-local_times -x1D stdout: \
-stim_times 1 '1D: 14.0 38.0 62.0 84.0' 'WAV(0,0,6,10,0,0)' \
-stim_times 2 '1D: 14.0 38.0 62.0 84.0' 'GAM(8.6, .547, 0)' \
-stim_times 3 '1D: 14.0 38.0 62.0 84.0' 'SPMG1(10)' \
| 1dplot -thick -one -stdin -xlabel Time -ynames WAV GAM.5 SPMG1.10
