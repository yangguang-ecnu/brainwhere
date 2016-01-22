A template for recording and reporting FMRI methods based on Appendix A in :

Poldrack, R. A., Fletcher, P. C., Henson, R. N., Worsley, K. J., Brett, M., & Nichols, T. E. (2008). Guidelines for reporting an fMRI study NeuroImage, 40(2), 409–414. doi:10.1016/j.neuroimage.2007.11.048



# Experimental Design #

## Design Specification ##
  * NUMBER OF SESSIONS:
  * RUNS PER SESSION: 5
  * BLOCKS OR TRIALS PER RUN: 12
  * LENGTH OF EACH TRAIL:
  * INTER-TRIAL INTERVAL: FIXED OR VARIABLE
  * LENGTH OF INTER-TRIAL INTERVAL, OR MEAN, RANGE, AND DISTRIBUTION OF VARIABLE ISIS:
  * (for blocked designs:) LENGTH OF BLOCKS:
  * (for event-related designs:) DESIGN OPTIMIZED FOR EFFICIENCY, AND IF SO,  HOW:
  * (for mixed designs:) CORRELATION BETWEEN BLOCK AND EVENT REGRESSORS:

## Task Specification ##
Instructions:
  * What were participants asked to do?
Stimuli:
  * What were the stimuli and how many were there?
  * Did specific stimuli repeat across trials?

## Planned Comparisons ##
  * If experiment has multiple conditions, what are the specific planned comparisons, or is an omnibus ANOVA used?


# Human Subjects #

## Details on Participant Sample ##
  * NUMBER OF PARTICIPANTS:
  * AGE (MEAN AND RANGE):
  * HANDEDNESS:
  * NUMBER OF MALES/FEMALES:
  * INCLUSION/EXCLUSION/GROUPING CRITERIA: Dx AD or Multi-modality amnestic MCI (Heilman, Phinney, newspaper ads)
  * SUBJECTS REJECTED POST-SCAN? REASONS?
  * VARIABLES EQUATED ACROSS GROUPS:

## Ethics Approval ##
  * IRB:
  * MR SAFETY SCREENING:

## Behavioral Performance ##
  * BEHAVIORAL DATA COLLECTED:
    * e.g., RT, accuracy


# Data Acquisition #

## Image Properties - as Acquired ##
  * MRI MANUFACTURER/TESLA/MODEL:
  * NUMBER OF EXPERIMENTAL SESSIONS AND VOLUMES PER SESSION:
  * PULSE SEQUENCE TYPE (GRADIENT/SPIN ECHO, EPI/SPIRAL, ETC):
  * PARALLEL IMAGING PARAMETERS (E.G., SENSE/GRAPPA, ACCELERATION FACTOR):
  * FOV, MATRIX SIZE, SLICE THICKNESS, INTERSLICE GAP:
  * ACQUISITION ORIENTATION (AXIAL, SAGITTAL, CORONAL, OBLIQUE, AC-PC):
  * WHOLE-BRAIN? (IF NOT: SHOW OR DESCRIBE AREA OF ACQUISITION):
  * ORDER OF ACQUISITION SLICES (SEQUENTIAL OR INTERLEAVED? ASCENDING OR DESCENDING?):
  * TE/TR/FLIP ANGLE:

# Data Preprocessing #
  * SOFTWARE USED AND VERSION NUMBERS:
    * NOTE: If any participants required different processing operations or settings, specify these differences explicitly.

## Pre-processing: general ##
  * ORDER OF PREPROCESSING OPERATIONS:
  * QUALITY CONTROL MEASURES: (talk to Kristin) BC: despike for all
  * UNWARPING OF B0:
  * SLICE TIMING CORRECTION:
    * Reference slice and type of interpolation used (e.g., “Slice timing correction to the first slice as performed, using SPM5's Fourier phase shift interpolation”):
  * MOTION CORRECTION
    * REFERENCE SCAN:
    * IMAGE SIMILARITY METRIC:
    * TYPE OF INTERPOLATION USED:
    * DEGREES-OF-FREEDOM:
    * OPTIMIZATION METHOD:

## Intersubject registration ##
  * INTERSUBJECT REGISTRATION METHOD USED:
    * illustration of voxels present in all sujects:
    * indication of average BOLD sensitivity within each voxel in the mask
  * TRANSFORMATION MODEL AND OPTIMIZATION:
    * transformation model (linear/affine, nonlinear):
    * type of any non-linear transformations (polynomial, discrete cosine basis):
    * number of parameters (e.g. 12 parameter affine, 3x2x3 DCT basis):
    * regularization: image-similarity metric
    * interpolation method
  * OBJECT IMAGE INFORMATION (image used to determine transformation to atlas):
    * if anatomic MRI: coplanar with functional acquisition?
  * FUNCTIONAL ACQUISITION COREGISTERED TO ANATOMICAL? if so, how?
    * segmented gray image?
    * functional image (single or mean)?
  * ATLAS/TARGET INFORMATION:
  * BRAIN IMAGE TEMPLATE SPACE, NAME, MODALITY, AND RESOLUTION:
    * e.g., "FSL's MNI Avg152, T1 2x2x2 mm"; "SPM's MNI gray matter template 2x2x2 mm":
  * COORDINATE SPACE:
    * e.g. MNI, Talairach, or MNI converted to Talairach
    * If MNI converted to Talairach, what method (e.g., Brett's mni2tal):
    * How locations/labels were determined (e.g., paper atlas, Talairach Daemon, manual inspection, etc.):

## Smoothing ##
  * SIZE AND TYPE OF SMOOTHING KERNEL: 5 mm on raw data
    * e.g. 12 mm FHWM Gaussian

# Statistical Modeling #

## General Issues ##
  * For novel methods that are not described in detail in a separate paper, provide explicit description and validation of method either in the text or as an appendix.

## Intrasubject FMRI Modeling Info ##

  * STATISTICAL MODEL AND ESTIMATION METHOD:
    * Multiple regression is most common statistical model. Estimation methods are typically ordinary least squares (OLS), OLS with adjustment for autocorrelation (i.e., variance correction and use of effective degrees-of-freedom), or generalized least squares (i.e., OLS after whitening).
  * BLOCK/EPOCH-BASED OR EVENT-RELATED MODEL:
  * HEMODYNAMIC RESPONSE FUNCTION (HRF) is likely one of:
    1. assumed HRF model (e.g., SPM's canonical diff of gammas HRF, FSL's canonical gammma HRF):
    1. HRF basis set (list basis set):
    1. estimated HRF (supply methods for estimating HRF):
  * ADDITIONAL REGRESSORS USED:
    * e.g., temporal derivatives, motion, behavioral covariates
  * ANY ORTHOGONALIZATION OF REGRESSORS:
  * DRIFT MODELLING/HIGH-PASS FILTERING: linearly detrend individual timeseries
    * e.g., “DCT with cut off of X seconds”; “Gaussian-weighted running line smoother, cut-off 100 seconds”, or “cubic polynomial”
  * AUTOCORRELATION MODEL TYPE:
    * e.g., for SPM2/SPM5, ‘Approximate AR(1) autocorrelation model estimated at omnibus F-significant voxels (Pb0.001), used globally over the whole brain’;
    * e.g., for FSL, ‘Autocorrelation function estimated locally at each voxel, tapered and regularized in space.’).
  * CONTRAST CONSTRUCTION:
    * i.e., exactly what terms are subtracted from what? Define these in terms of task or stimulus conditions (e.g., using abstract names such as AUDSTIM, VISSTIM) instead of underlying psychological concepts

## Group Modeling Info ##

# Statistical Inference #

## Inference on Statistic Image (thresholding) ##

## ROI Analysis ##

Per BC:
  * Harvard-Oxford ROIs likely too big
  * candidate: Warenga's OLD-ONLY all-words-together data
  * take direct from her images, or derive by eye-balling her boundaries on H-O atlas
  * dependent variable will be single average AUC for each ROI


# Figures and Tables #

## Figures ##

## Tables ##