

# INTRODUCTION #
This wiki attached to my brainwhere google project is where I am consolidating my imaging notes and resources. Whenever possible I'm documenting here first, and then transferring to email, slides, etc. Why this wiki instead of a word doc or other format:
  1. **Revision tracking**. Changes here are automatically tracked. The content is currently under heavy development, and users relying on it for ongoing work need to know what has changed. See below for how to track changes.
  1. **Speed**. The wiki syntax is fast to write, provides automatic table-of-contents updating, and, because editing and access are both on-line, it doesn't require manual tracking and management of versions. Readers know they are always seeing the most up-to-date content.
  1. **Access**. Readers can view from any browser on any device, and I can edit from almost any browser.
  1. **Reliability**. For me, MS Word crashes are more frequent than browser crashes or unexpected loss of internet connectivity.

I do hate that sections are not automatically numbered and automatic style formatting is minimal, so I may transfer to a more formal format once the guide has reached some arbitrary level of completeness.

## tracking changes to this guide ##
Changes to this guide are [tracked](https://code.google.com/p/brainwhere/source/list?repo=wiki), and you can receive alerts about updates via [newsfeed](https://code.google.com/feeds/p/brainwhere/hgchanges/basic?repo=wiki).

## text conventions ##

  * Text in <font color='LightGray'>light gray </font> is generally placeholder text for headings or sections that haven't been written or transferred here yet. Black text is complete enough to contain at least some useful information, but that doesn't mean that more won't be added later.
  * "TBD" is a placeholder reminding myself that there's something to be done there.
  * You may notice that heading and section formatting is inconsistent. Right now focus is on building content. Formatting will be cleaned up once evolution of guide slows down.
  * In code blocks I try to adhere to a few fairly standard conventions:
    * "\" at the end of a line tells the shell to continue reading the command on the following line rather than executing the current line
    * "`<something in these>`" generally indicates a required argument, and "`[something in these]`" generally indicates an optional argument
    * the "$" in front of a command such as "` $ aScriptOrCommand.sh` " indicates that aScriptOrCommand.sh was executed on the commandline
    * Here is an example code block that contains all of these conventions:
```
$ registerTo1mmMNI152.sh

Usage: 
registerTo1mmMNI152.sh                                        \
  -s <subjectID>                                              \
  -t <t1.nii>                                                 \
  -o <FullPathToOutdir>                                       \
[ -l <lesion.nii>                                             \ ]
[ -e <epi.nii>                                                \ ]
[ -c <clusterMasksRegisteredToAboveEPI.nii>                   \ ]
[ -c <anotherEPIregisteredCusterMask.nii>                     \ ]
[ -b <buckFileOrOtherDecimalValueImage.nii>                   \ ]
[ -b <anotherEPIregisteredBuckOrOtherDecimalValueImage.nii>     ]

```


## jumping-in: independent pre-reading ##

Helpful background resources to cover before you start in-person training:
  * [Dr. Mumford's](http://mumford.bol.ucla.edu/) introduction/review of GLM basics: ["Statistical Modeling and Inference (for non-FMRI data)"](http://mumford.bol.ucla.edu/stat_modeling_2009.pdf)
  * "[Functional MRI: An Introduction to Methods](http://www.amazon.com/Functional-MRI-Introduction-Peter-Jezzard/dp/019852773X)" chapters 1, 7, 11, 12, 17
  * AFNI documentation:
    * ["FMRI Basics"](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni01_intro/FMRI_basics.pdf)
    * ["AFNI & FMRI: Introduction, Concepts, Principles"](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni01_intro/afni01_intro.pdf)
    * ["Time Series Analysis in AFNI"](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni04_fmri/afni04_fmri.pdf)

## jumping-in: AFNI tutorials ##
If you already have some MRI and command-line experience, these AFNI tutorials can help get your toes wet even without in-person training:
  * ["AFNI start to finish: How to Analyze Your Data in AFNI"](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni16_start_to_finish/afni16_start_to_finish.pdf)
    * example data are in AFNI\_data6/FT\_analysis/ [(download AFNI\_data6.tgz)](http://afni.nimh.nih.gov/pub/dist/edu/data/AFNI_data6.tgz)
    * per pdf: run s01.ap.simple, inspect results, then run s02.apalign, inspect results
    * then see [this in-depth tutorial](http://afni.nimh.nih.gov/pub/dist/edu/data/CD.expanded/AFNI_data6/FT_analysis/tutorial) covering the same data
  * ["Deconvolution Signal Models"](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni06_decon/afni06_decon.pdf)
    * example data are in AFNI\_data2/ED/ [(download AFNI\_data2.tgz)](http://afni.nimh.nih.gov/pub/dist/edu/data/AFNI_data2.tgz)
  * [afni\_proc.py help page](http://afni.nimh.nih.gov/pub/dist/doc/program_help/afni_proc.py.html) has single-session processing examples
    * example data are in AFNI\_data4/sb23/ [(download AFNI\_data4.tgz)](http://afni.nimh.nih.gov/pub/dist/edu/data/AFNI_data4.tgz)

### a note about modern AFNI ###
In November 2006 AFNI authors released [afni\_proc.py](http://afni.nimh.nih.gov/pub/dist/doc/program_help/afni_proc.py.html), an umbrella script for processing and analyzing single-session FMRI data. There are a number of reasons to use afni\_proc.py instead of scripting individual commands:
  1. **Dogma**: AFNI authors recommend the use of afni\_proc.py, and expect that message board questions will reference afni\_proc.py output.
  1. **Efficiency**: afni\_proc.py is fast and reduces opportunities for user error. Users can perform start-to-finish analysis of single-session data without scripting anything themselves.
  1. **Consistency**: files generated by afni\_proc.py are consistently named, which is not commonly a strength of user-written scripts.
  1. **Flexibility**: processing and analysis steps can be changed by simply providing different arguments to the afni\_proc.py command.

As an example, the legacy BRRC preprocessing and deconvolution steps are easily re-implemented in afni\_proc.py. Traditionally this basic pipeline has been performed in three user-scripted steps:

  * STEP 1:  [3dTcat](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTcat.html) -rlt++ to remove warm-up TRs and low-frequency drift (producing output images named `*`treg+orig per lab convention):
```
3dTcat \
-rlt++ \
-prefix s01pre.epi.treg \ 
's01pre.epi01+orig[8..51]' 's01pre.epi01+orig[52..96]' 's01pre.epi01+orig[97..141]' 's01pre.epi01+orig[142..185]'  \
's01pre.epi02+orig[8..51]' 's01pre.epi02+orig[52..96]' 's01pre.epi02+orig[97..141]' 's01pre.epi02+orig[142..185]'  \
's01pre.epi03+orig[8..51]' 's01pre.epi03+orig[52..96]' 's01pre.epi03+orig[97..141]' 's01pre.epi03+orig[142..185]' 
```
  * STEP 2:  [3dvolreg](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dvolreg.html): EPI motion correction that spatially aligns each TR of a session to the first TR of the session's first EPI run (first = first preserved TR after warm-up TRs have been removed), producing 3D+time motion-corrected EPI images (named `*`reg+orig per lab convention):
```
3dvolreg \
-prefix s01pre.epi.reg \
-clipit \
-base 's01pre.epi01+orig[0]' \
s01pre.epi.treg
```
  * STEP 3: [3dDeconvolve](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dDeconvolve.html) -stim\_minlag -stim\_maxlag: deconvolve and regress EPI voxel intensities against the stimulus time series to produce `*`.resp+orig file (containing the 3D+time estimated impulse response) and `*`.buck+orig file (containing goodness of fit and statistical significance):
```
3dDeconvolve \
-input s01pre.epi.reg \
-polort 0 \
-numstimts 1 \
-stim_file 1 stimFile_allRuns.1D \
-stim_minlag 1 0 \
-stim_maxlag 1 15 \
-iresp s01pre.resp \
-rout -nocout \
bucket s01pre.buck
```


Identical results are produced by this single afni\_proc.py command, but with many fewer opportunities for user error :

```
afni_proc.py \
-subj_id s01pre \
-dsets epirun??.trega+orig.HEAD \
-blocks volreg regress \
-tcat_remove_first_trs 8 \
-volreg_align_to first \
-volreg_interp -Fourier \
-volreg_opts_vr -clipit \
-volreg_zpad 1 \
-regress_stim_files stimFile_allRuns.1D \
-regress_basis 'TENT(0,25.5,16)' \
-regress_no_motion \
-regress_opts_3dD -rout -nocout -jobs 8
```

One of the biggest advantages of afni\_proc.py is that it enables users to easily change processing and analysis methods. Major changes to the above BRRC pipeline can be implemented with very little work:
  * to add spatial smoothing of 5 mm FWHM, just add "blur" to the list of blocks (`-blocks volreg blur regress`), and add an argument to specify the smoothing kernel size (`-blur_size 5.0`)
  * scale EPI data to a voxel-wise per-run mean of 100 by simply adding "scale" to the list of processing blocks (`-blocks volreg blur scale regress`)
  * model head motion in the regression simply by omitting `-regress_no_motion`
  * add the argument `-regress_reml_exec` to trigger [3dREMLfit](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dREMLfit.html) to perform GLS regression with REML estimation of the temporal auto-correlation structure

One perceived limitation of afni\_proc.py is that it uses tent functions for 3dDeconvolve unconstrained FIR deconvolution instead of the stick functions invoked in traditional `3dDeconvolve -stim_minlag -stim_maxlag` calls. This shift from stick (Dirac delta) functions to tent functions appears to have occurred in 2004, and slides 54+ in [this presentation](http://psyphz.psych.wisc.edu/web/afni/class_handouts/afni_3dDeconvolve/regression.pdf) are the only ANFI resource I've seen that discusses both. All recent AFNI documentation about unconstrained FIR deconvolution uses tent functions exclusively.

The good news is that tent function parameters can be specified to produce results that are identical to the old-style stick function deconvolution. (TBD: give  BRRC examples, maybe show how to make tent parameters identical to minlag/maxlag/TR. If not here, in another section).


## resources ##
These are resources I reference throughout this guide. Become one with them. And please let me know if you find helpful resources that I should add to this list.

You may want to start with the independent pre-reading listed above.

### video tutorials ###

My video tutorials can all be found at my [youtube channel (user stowler)](http://www.youtube.com/stowler). They are just screencasts with me talking over them. Or not, sometimes.

Because youtube's playlists aren't very fancy yet, I've also excerpted my video tutorials to [their own page](http://code.google.com/p/brainwhere/wiki/annotatedPlaylists).

(If I find anything else outside of the open courseware listed above, I'll link to it in this section.)

<a href='Hidden comment: 
Maybe I"ll include this logo in places where I link to videos: http://www.annapolisonpointe.com/wp-content/uploads/2011/09/youtube_logo_small1.png
'></a>


### AFNI documentation (a deep and inchoate sea of knowledge) ###
  * [AFNI message board](http://afni.nimh.nih.gov/afni/community/)
  * [AFNI documentation portal ](http://afni.nimh.nih.gov/afni/doc/)
  * [latest documents used in AFNI classes](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni_handouts/)
  * [individual AFNI program help files ](http://afni.nimh.nih.gov/afni/doc/program_help/index.html)
    * [log of AFNI program changes](http://afni.nimh.nih.gov/pub/dist/doc/program_help/history_all.html)
  * some [AFNI reference manuals](http://afni.nimh.nih.gov/afni/doc/manual/) contain information omitted from program help:
    * [main AFNI manual](http://afni.nimh.nih.gov/pub/dist/doc/afni_manuals/afni200.pdf) and its [sample datasets](http://afni.nimh.nih.gov/pub/dist/data/)
    * 3dDeconvolve [manual](http://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf)
    * 3dRegAna [manual](http://afni.nimh.nih.gov/pub/dist/doc/manual/3dRegAnam.pdf)
    * [a combined manual](http://afni.nimh.nih.gov/pub/dist/doc/manual/ANOVAm.pdf) for 3dANOVA, 3dANOVA2, and 3dANOVA3
  * [AFNI HOWTOs](http://afni.nimh.nih.gov/pub/dist/HOWTO/howto/) (some say at top: "This analysis method is effective but antiquated")
  * AFNI tutorials and sample data: see independent pre-reading section
  * [the ACE and JAM exams](http://afni.nimh.nih.gov/afni/community/)
  * [AFNI FAQ](http://afni.nimh.nih.gov/afni/doc/faq)
  * [AFNI author Gang's webpage](http://afni.nimh.nih.gov/sscc/gangc)

### non-AFNI software resources ###

In addition to the open courseware linked below, these are helpful resources for non-AFNI software packages:

  * [FMRIB Software Library (FSL)](http://www.fmrib.ox.ac.uk/fsl/)
    * [FSL mailing list archive](https://www.jiscmail.ac.uk/cgi-bin/webadmin?A0=fsl)
    * [documentation for individual FSL tools](http://www.fmrib.ox.ac.uk/fsl/fsl/list.html)
    * [free materials from expensive yearly FSL course](http://www.fmrib.ox.ac.uk/fslcourse/)


### open courseware ###

  * [FSL course slides](http://www.fmrib.ox.ac.uk/fslcourse/)
  * [SPM course slides](http://www.fil.ion.ucl.ac.uk/spm/course/)
  * The excellent SPM-oriented [Methods For Dummies](http://www.fil.ion.ucl.ac.uk/mfd/index.html) series [(archived yearly)](http://www.fil.ion.ucl.ac.uk/mfd/page2/page2.html)
  * UCLA has a mature training program organized and taught by luminaries:
    * UCLA Advanced Neuroimaging Summer School:
      * 2007 and 2008 lectures archived on [iTunes U](http://deimos3.apple.com/WebObjects/Core.woa/Browse/ucla-public.1447345863)
      * [2009 lectures](http://www.brainmapping.org/Live.php) archived at [livestream](http://www.livestream.com/nitp2009)
      * [2010 lectures](http://www.brainmapping.org/NITP/Summer2010.php) archived at [livestream](http://www.livestream.com/nitpsummercourse)
    * UCLA's two-semseter Principals of Neuroimaging sequence:
      * [2010-2011 wiki](http://airto.hosted.ats.ucla.edu/wiki/index.php/Principles_of_Neuroimaging_-_2010-2011), with links to materials
      * 2009-2010: [PNA wiki](http://airto.hosted.ats.ucla.edu/wiki/index.php/Principles_of_Neuroimaging_A_%282009%29)
      * 2008 PNA [calendar with links to materials](http://www.brainmapping.org/NITP/PNA/index2008.php)
    * Susan Bookheimer's [class slides for Functional Neuroanatomy for the Neuropsychologist](http://www.ccn.ucla.edu/bmcweb/bmc_bios/SusanBookheimer/Psych292.php) (TBD: need lecture recording)
  * MIT's [HST.583 Functional Magnetic Resonance Imaging: Data Acquisition and Analysis](http://ocw.mit.edu/courses/health-sciences-and-technology/hst-583-functional-magnetic-resonance-imaging-data-acquisition-and-analysis-fall-2008/index.htm)
  * GSU/GA Tech Center for Advanced Brain Imaging (CABI) [FMRI course by Chris Rorden and Paul Corballis](http://www.cabiatl.com/CABI/resources/Course/)
    * [Sample fMRI Block Design Analysis using FSL](http://www.cabiatl.com/Resources/Course/tutorial/html/block.html)
    * [Sample fMRI Event Design Analysis using FSL](http://www.cabiatl.com/Resources/Course/tutorial/html/event.html)
    * [Sample fMRI Block Design Analysis using SPM](http://www.cabiatl.com/Resources/Course/tutorial/html/blockspm.html)
    * [MRIcron Peristimulus Plots](http://www.cabiatl.com/Resources/Course/tutorial/html/peri.html)


### additional sample datasets ###
  * [BIRN datasets](http://www.birncommunity.org/resources/data/alphabetical-list-of-data/)
  * [more BIRN datasets](http://www-calit2.nbirn.net/bdr/bdr_current_data.shtm)
  * [official NIFTI-1 test images](http://nifti.nimh.nih.gov/nifti-1/data) (including left hem/right hem confirmation)



### text chapters ###
(TBD)


### slides ###
  * Dr. Mumford's UCLA Advanced Neuroimaging Summer School [slides](http://mumford.bol.ucla.edu/)

### how-to guides ###
  * Dr. Tom Johnstone's [guide to AFNI FMRI processing](http://brainimaging.waisman.wisc.edu/~tjohnstone/AFNI_I.html)
  * The [Image Analysis Wiki](http://imaging.mrc-cbu.cam.ac.uk/imaging/AnalysisPrinciples) from the Cambridge [Cognition and Brain Sciences Unit](http://www.mrc-cbu.cam.ac.uk/)

## on keeping a lab manual ##
Please keep a lab manual. Religiously. Electronic or ink, so long as you record what you do. Everything you do. I promise it will pay off.

My personal preference: Ilana Levy turned me on to [Evernote](http://www.evernote.com), which changed my life. It synchronize notes across Mac, Windows, iPad, iPhone, Android, robust web interface and god knows wherever else. (Supernerds: it also has a reasonable applescript dictionary for automation).

The only hand-typed data I don't put into Evernote are future appointment reminders (which go to google calendar / doodle), and instructions and code (which are hosted, backed-up, and versioned on googlecode via mercurial).


<a href='Hidden comment: 
<font color="LightGray">
= PRIMER: NEUROANATOMY =

== ((CNS STRUCTURES)) ==
=== brain ===
==== prosencephalon ====
===== telencephalon =====
===== diencephalon =====
==== mesencephalon ====
==== rhombencephalon ====
===== metencephalon =====
===== myelencephalon =====
==== vascularization ====

=== ((spinal cord)) ===

== ((CELLS)) ==
=== ((cortical layers)) ===
=== ((What"s the matter with white matter?)) ===

== PROCESSES ==
=== BOLD-influencing processes ===
=== ((neuronal plasticity)) ===
=== ((stroke and stroke recovery)) ===
=== ((age-related white matter pathology)) ===
=== ((coritcal atrophy)) ===
=== ((sulcal and gyral development)) ===

= PRIMER: COMMAND LINE AND SCRIPTING =

== GENERAL COMMAND-LINE PROGRAMS ==
=== the prompt ===
=== navigating and viewing: pwd, cd, ls -l, .., cat, less, display ===
=== changing things: touch, cp, mv, rm, chmod, chown ===
=== redirection: |, >, >>, et al. ===
== SCRIPTING ==
'></a>

# BASIC BRAIN IMAGE MANIPULATION #

## What are AFNI, FSL, SPM, ITKSNAP, mricron, ImageJ, Freesurfer, SPM, BrainVisa, etc? ##
There are a number of neuroimaging software packages available for you to download and use. In general these packages are written by teams of imagers, statisticians, and software engineers whose intention is to provide free, high-quality brain imaging software for the academic neuroimaging community. These packages vary widely in their functions, interfaces, and complexity, as well as the speed with which their authors provide updates.

### opensource ###
The majority of neuroimaging software used to produce data for peer-reviewed literature is some flavor of "opensource". This means that the underlying sourcecode written by the software authors is available for inspection and adaptation by other neuroimagers.

### mailing lists: where users and authors meet ###
Many of the large neuroimaging suites have active mailing lists or web forums where software authors and users post questions and answers. When you have a question your first step should be to check the software's documentation, followed by searching the mailing list or forum archives. More often then not you'll find an answer there. Failing that, you're likely to receive a helpful and speedy (1-2 days) response if you posting a clearly-worded question or problem with contains specific information about what you'd like to know or what problem you're having. If you're reporting a bug, be sure to include your software and operating system versions. Most software authors are **shockingly** available to answer questions from friendly users.

The resources section above contains links to mailing lists and web forums.

<a href='Hidden comment: 

== What is a 3d brain volume? ==
=== voxels ===
=== intensity values ===
=== alignment in space and 3d slicing ===
=== layering ===

== file names and formats ==
=== AFNI native format: .HEAD & .BRIK / .BRIK.gz pair ===
=== ANALYZE: .hdr & .img pair ===
=== NIFTI format: .nii / .nii.gz ===
=== dicoms from the scanner ===
=== converting among file formats ===
==== fslchfiletype ====
==== 3dcopy, 3dAFNItoNIFTI ====
==== dcm2nii ====
==== imagej ====
=== AFNI"s growing support for NIFTI ===
* http://nifti.nimh.nih.gov/nifti-1/support/AFNIandNIfTI1
* http://nifti.nimh.nih.gov/nifti-1/AFNIextension1/
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=16023&t=16017#reply_16023
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=16574&t=6484#reply_16574
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=7239&t=7238#reply_7239
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=21789&t=7463#reply_21789
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=31021&t=30990#reply_31021
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=30856&t=30854#reply_30856
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=29872&t=29872#reply_29872
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=26699&t=26695#reply_26699
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=26223&t=26223#reply_26223
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=25946&t=25937#reply_25946
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=26092&t=25969#reply_26092
* run 3dDeconvolve with –float and prefix w/ .nii http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=24900&t=10655#reply_24900
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=24500&t=24500#reply_24500
* http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=23273&t=22959#reply_23273
* my post: http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=34879&t=34877#reply_34879
* floats: http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=7220&t=7219#reply_7220



Unknown end tag for &lt;/font&gt;


'></a>
## viewing 3D and 4D brian MRI data ##

&lt;wiki:gadget url="http://hosting.gmodules.com/ig/gadgets/file/116395649177698326297/gss-screencasts-visFMRI.xml?nocache" width="800" height="1100" border="1" title="" /&gt;

<a href='Hidden comment: 

== rotating images in space: swaping axes ==
(e.g. INT2_s01 lesion that opened fine in AFNI but not in fslview)
=== diagnose misorientation: fslview and fslhd ===
=== why not to use afni gui for diagnosis? ===
=== fix misorientation: 3dresample -orient ===
=== fix misorientation: fslswapdim ===
==== first z and y, then x ====

== rotating images in space: arbitrary rotation with imagej ==

== skull stripping ==
=== bet ===
=== 3dautomask/3dSkullStrip ===

'></a>
## binary masks ##

### creating spheres centered on coordinates ###
It it is sometimes useful to create a spherical mask centered on a coordinate. The coordinate may be from a priori hypotheses based on previous analyses, or it may be the peak of some activation seen in present work. AFNI provides at least two ways to create a spherical ROI.

Let's assume that we would like to place a sphere of 8 mm radius in the medial preforntal cortex (AFNI tlrc coordinates (1, -40, 16), and we have a tlrc'd anatomical images that should serve as the template for the overall image geometry. One way to create this mask is with 3dUndump:

```
echo "1 -40 16" | 3dUndump -prefix mPFC_3dUndump -master anat+tlrc.HEAD -xyz -srad 8 -
```

This creates a mask image with intensity of one in the sphere and zeros everywhere else. See the [3dUndump help page](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dUndump.html) for additional options.

Another, slightly less intuitive, way to do this is with a 3dcalc command. Pay attention to the signs in this example, as the coordinate signs must be swapped in the 3dcalc formula:

```
3dcalc -a anat.HEAD -expr 'step(64-(x-1)*(x-1)-(y+40)*(y+40)-(z-16)*(z-16))' -prefix mPFC_3dcalc
```

This creates the same foreground=1 / background=0 mask as the 3dUndump command above.

### extracting average values from within a mask ###
AFNI's [3dmaskave ](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dmaskave.html) can be used to extract the average value of a 3d or 4d image for only the voxels contained in the mask. For example, let's say you want to know the average R<sup>2 value for a small hand-drawn a priori anatomical region of interest. The R</sup>s values are stored in the 0th subbrick of the buckfile produced by 3dDeconvolve. 3dmaskave will print this single mean value to the terminal when you execute:

```
3dmaskave -mask myApriorROI+tlrc.HEAD buck+tlrc.HEAD'[0]'
```

Similarly, let's say that you would like to extract the average impulse response function from the same masked area so that you can plot the estimated IRF. If there are 9 TRs in the timeseries containing your estimated IRF (the "iresp" or "resp" file), this command will return 9 average values for you to plot as the average estimated IRF for that region of interest:

```
3dmaskave -mask myAprioriROI+tlrc.HEAD resp+tlrc.HEAD
```




## anatomical atlases available in FSL ##
### reminder: What is a digital brain atlas? ###
  * A gold-standard 3D map of brain regions that the research community uses as  a common template or guide in research.
    * the map is aligned with a “standard brain” which 1) has a particular orientation in space, and 2) is sliced into a particular coordinate system
    * we call this “standard space” or “MNI space” or “Talarach space”
  * Can compare other 3D brains images with an atlas by aligning the anatomy with the atlas and reslicing to match the standard brain’s coordinate system. This is called registering a brain image to an atlas or registering a brain image into standard space
### reminder: What is an atlas good for? ###
  * investigating properties of a structure or region of interest without having to hand-draw ROIs: just use pre-drawn boundaries from the atlas
  * …and the inverse: find out what structures are part of a given phenomenon: atrophy, lesion map, or fmri activation
  * sometimes all you have is a coordinate: center of gravity or peak intensity: finding the name of a structure given a coordinate in the structure
  * common coordinate system for communication
### displaying atlases in fslview ###
  1. open MNI 152 1mm standard T1 brain (File –> Open Standard -> MNI152\_T1\_brain)
  1. open and display an atlas in MNI 1mm space : start w/ Harvard/Oxford cortical
    * Harvard/Oxford cortical (File -> Open Standard -> [to parent folder](up.md) -> data -> atlases -> HarvardOxford -> HarvardOxford-cort-maxprob-thr25-1mm.nii.gz)
    * reminder: turn layer on/off, change transparency, order of layers
    * notice that each atlas compartment has a specific intensity number associated with it: not a BA number, not related to tissue properties, just an  arbitrary label  to identify the region, allow it to be associated with a specific color for display, and allow it to be isolated in mathematical operations
  1. Tools –> Toolbars -> Atlas Tools
    * displays atlas toolbox in fslview
    * for each of the atlases listed in the toolbox, the anatomic label for the crosshair location is displayed
    * probabilistic atlas: first region listed is most probable, and the display shows the % of atlas participants for whom the voxel under the crosshairs was identified as being part of that structure
    * “Structures…” button to see probability map
    * top selector: choose the atlas you’re viewing
    * bottom: click  “Locate selected structure”
    * click on structure and fslview will display it centered under the crosshairs
    * "Atlases..." button
  * Other fslview atlases
    * Harvard/Oxford subcortical (File -> Open Standard -> (up) -> data -> atlases -> HarvardOxford -> HarvardOxford-sub-maxprob-thr25-1mm)
  * Can display these atlases in any other tool that can open nifti images
### identifying a coordinate's region via the commandline ###
#### fsl's atlas query ####
Example: atlasquery -a "Harvard-Oxford Cortical Structural Atlas" -c -42,-38,50
<a href='Hidden comment: 
==== afni"s whereami ====
=== editing atlases via the commandline (combining regions, removing regions? more?) ===
=== editing atlases in itksnap ===
==== combining regions ====
==== dividing regions ====
==== removing regions ====
'></a>

## spatial registration ##
### templates/space (MNI, TLRC) ###
### tools: flirt, fnirt, 3dvolreg, etc ###
  * http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=31187&t=31167#reply_31187
  * http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=33911&t=33911#reply_33911
### nonlinear spatial registration ###

High-degree-of-freedom nonlinear registration to a template brain aligns external dimensions **and** major internal features such as ventricles, fissures, and major sulci. This is usually a high resolution (~1 mm3) T1-to-T1 registration, but other volumes from a session -- such as masks, EPIs, and derived SPMs -- can be brought into the target space too.

Crosson lab linux users can save time and errors by registering multiple images from a session in a single execution of my script, **registerTo1mmMNI152.sh**. This script automates about 10 error-prone commands per volume, including:

  * verification of input files (existence, geometry, orientation)
  * rotation of axes into RPI orientation if necessary (**3dresample -orient rpi**)
  * skull-striping of T1 (**bet -R**)
  * conversion of masks (lesion, cluster) to data type char (**fslmaths**)
  * nonlinear registration of 3danat\_brain to 1mm MNI152 template (**flirt** and **fnirt**)
  * alignment of  other user-specified non-T1 images to 1mm MNI152 template by calculating, concatenating, and applying linear and nonlinear transformations (**flirt**, **fnirt**, and **applywarp**)
  * (TBD: automatically deoblique input files for ancient afni code that can't handle oblique data)

The usage information is provided below for reference, and is current as of Jan 27, 2011, but to be certain of current usage options just execute the script with no arguments, as below:

```
$ registerTo1mmMNI152.sh

Usage: registerTo1mmMNI152.sh                                 \
  -s <subjectID>                                              \
  -t <t1.nii>                                                 \
  -o <FullPathToOutdir>                                       \
[ -l <lesion.nii>                                             \ ]
[ -e <epi.nii>                                                \ ]
[ -c <clusterMasksRegisteredToAboveEPI.nii>                   \ ]
[ -c <anotherEPIregisteredCusterMask.nii>                     \ ]
[ -b <buckFileOrOtherDecimalValueImage.nii>                   \ ]
[ -b <anotherEPIregisteredBuckOrOtherDecimalValueImage.nii>     ]

WEAKNESSES:
- erases embeded commandline history (applywarp not implemented in afni...yet)
- UNTESTED ASSUMPTION: brain extraction implementation is good compromise for all brains (bet -R)
- UNTESTED ASSUMPTION: variability in brain extraction quality does not affect registration to MNI152
- UNTESTED ASSUMPTION: best choices for final interpolation (masks: nearest neighbor; decimal values: sinc)
```

_It is essential that you verify the quality of your T1-to-template registration, as that is the registration on which all others are based. This is very easy to do in fslview: load your nonlinearly-registered T1 as a layer above the template, and toggle its visibility to inspect the alignment of external dimensions and major internal features such as ventricles, fissures, subcortical nuclei, and major sulci._

(TBD: follow-up on my post: http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=36163&t=27837#reply_36163)

## AFNI's "views": orig, ACPC, and TAL ##
TBD
### untalairaching ###
  * http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=27436&t=26948#reply_27436

## reslicing without moving (aka resampling) ##
Other than AFNI's graphical viewer, most image display and processing programs require that two images have the same number of rows, columns, and slices to view them together or perform arithmetic operations on them (subtracting, multiplying, etc). In cases in which the images are already aligned with each other, all you need to do is reslice them to match. Reslicing from a low resolution to a higher resolution is called upsampling, and can usually be done without degrading the image quality. Reslicing from a high resolution to a lower resolution is called downsampling, and it changes image intensities.

### upsampling (low resolution to high resolution) ###
Upsampling your data from low resolution to a higher resolution should not change the distribution of intensities in your image, but it is a good idea to check before and after.

Example: to convert an image already in MNI 2mm space into MNI 1mm space for comparison with an MNI 1mm atlas, use AFNI's 3dresample, either by referencing a higher-resolution template:
```
3dresample \
-master $FSLDIR/data/standard/MNI152_T1_1mm.nii.gz \
-prefix someMaskOrParameter_1mm.nii.gz \
-inset someMaskOrParameter_2mm.nii.gz
```

...or by specifying new voxel dimensions on the command line:

```
3dresample \
-dxyz 1.0 1.0 1.0 \
-prefix someMaskOrParameter_1mm.nii.gz \
-inset someMaskOrParameter_2mm.nii.gz
```

FSL's flirt also provides a way to do this, but may not maintain AFNI header information or multiple 3D volumes in a 4D file:

```
flirt \
-in someMaskOrParameter_2mm.nii.gz \
-ref $FSLDIR/data/standard/MNI152_T1_1mm.nii.gz \
-out someMaskOrParameter_1mm.nii.gz \
-init ~/id.mat \
-applyisoxfm 1
```

where ~/id.mat is the identity matrix stored in a text file that you create:
```
1 0 0 0
0 1 0 0
0 0 1 0
0 0 0 1
```


### downsampling (high resolution to low resolution) ###
[3dfractionize message thread from bob cox](http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=435&t=435)

## converting data type (bit depth) ##
  * fslmaths -odt
## extracting 3D images from a 4D file ##
A four-dimensional volume is a **single** file that contains **multiple** 3D volumes. Each 3D volume in it might be an individual time point in an EPI timeseries, or a statistic in the output from analysis (e.g. in the single 4D file output as an ANOVA result, volume 0 might be an F-stat, volume 1 an R-sq, and volume 2 a t-stat for a post-hoc test). You may sometimes want to separate one of these 3D volumes from the others, allowing it to occupy its own 3D file. AFNI's 3dcalc is one way to do this.

Example: the output from 3dttest contains two 3D volumes inside of its single 4d file:
```
$ 3dinfo myttestoutput.nii.gz
...
...
Number of values stored at each pixel = 2
  -- At sub-brick #0 '#0' datum type is float:     -5.04083 to       15.0832
  -- At sub-brick #1 '#1' datum type is float:     -5.24584 to       8.19693
     statcode = fitt;  statpar = 14
...
...
```

To save volume 0 of the two-volume 3dttest output into its own file:

```
3dcalc \
-a myttestoutput.nii.gz['0'] \
-prefix myttestoutput_vol0.nii.gz \
-expr 'a'
```

...and to isolate volume 1 from the same 3dttest output:
```
3dcalc \
-a myttestoutput.nii.gz['1'] \
-prefix myttestoutput_vol1.nii.gz \
-expr 'a'
```

These two commands leave the original 3dttest 4D file unchanged, but create copies of each of its two 3D volumes, one volume per new 3D file. Each of these volumes can now be analysed separately by programs that understand 3D images. You may verify that the metadata in each of these two new 3D files matches the original 4D file:
```
$ 3dinfo myttestoutput_vol0.nii.gz
...
...
Number of values stored at each pixel = 1
  -- At sub-brick #0 '#0' datum type is float:     -5.04083 to       15.0832
...
...
```
```
$ 3dinfo myttestoutput_vol1.nii.gz
...
...
Number of values stored at each pixel = 1
  -- At sub-brick #0 '#1' datum type is float:     -5.24584 to       8.19693
     statcode = fitt;  statpar = 14
...
...
```

AFNI's 3dbucket is another way to do this for bucket files:
```
3dbucket -fbuc -prefix new_dset old_dset'[0]' 
```



# WHAT IS BOLD FMRI AND SHOULD I BELIEVE IN IT? #
  * SLIDES WITH AUDIO: My current favorite BOLD intro talk is a 1.5-hour overview given by FSL's Mark Jenkinson at UCLA's 2007 NITP summer school [(iTunesU link)](http://deimos3.apple.com/WebObjects/Core.woa/Browse/ucla-public.1457096534.01457096536.1457511133?i=1128185302)
  * What is "negative BOLD?"

## limitations of BOLD ##
### limitations of image acquistion ###
  * Typical EPI signal dropout means there are areas of the brain with very poor SNR/sensivity/power.
    * DIAGNOSIS & DISCLOSURE: mean epi images highlighting average dropout
  * Living participants move during image acquisition. Retrospective motion correction (off-line or in scanner) aligns TRs with each other in space, but doesn't fix a number of very real problems created by motion:
    * changes to EPI-related distortion: distortions migrate around the brain as brain moves in the instrument
      * DIAGNOSIS & DISCLOSURE: TBD
    * intensity artifacts associated with movement (e.g. striping)
      * DIAGNOSIS & DISCLOSURE: TBD
    * intensity artifacts along visible edges in the image (motion-related edge artifacts)
      * DIAGNOSIS & DISCLOSURE: TBD
    * voxels changing their spin history by moving in the gradients
      * DIAGNOSIS & DISCLOSURE: TBD
### limitations of BOLD experimental design ###
### limitations of BOLD analysis methods ###







# FMRI SINGLE-SESSION ANALYSIS #

## SINGLE-SESSION PRE-STATISTICAL PROCESSING ##
  * [fsl slides](http://www.fmrib.ox.ac.uk/fslcourse/lectures/feat1_part1.pdf)

### reconstructing and inspecting scanner data ###

#### converting 2D slices to 3D/4D data ####
  * CURRENTLY PRESCRIBED: dcm2nii
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:
  * ALTERNATIVE:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:

#### inspecting for bad data, noting for censorship ####
  * AFNI's [3dToutcount](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dToutcount.html) may do a fair job detecting outliers due to motion, but not k-space spikes according to [BIRN's 2006 HBM poster](http://www.nmr.mgh.harvard.edu/martinos/publications/posters/HBM-2006/HBM06_GreveD.pdf))
  * [BIRN's 2006 HBM poster](http://www.nmr.mgh.harvard.edu/martinos/publications/posters/HBM-2006/HBM06_GreveD.pdf) describes a method for detecting k-space spikes that is insensitive to motion. This is implemented in freesurfer as commands `spikedet` and `spikedet-sess`.
  * [BIRN QA procedures](https://xwiki.nbirn.org:8443/xwiki/bin/view/Function-BIRN/AutomatedQA) based on [Friedman, L., Glover, G., "Report on a Multicenter fMRI Quality Assurance Protocol", J Magn Reson Imaging. June 2006. 23(6):827-39.](http://www.ncbi.nlm.nih.gov/pubmed/16649196)
  * Tom Nichols' [SPMd](http://www-personal.umich.edu/~nichols/SPMd/) SPM toolbox.
  * Stanford [ArtRepair](http://cibsr.stanford.edu/tools/ArtRepair/ArtRepair.htm) Software, implemented as SPM toolbox.
  * Johns Hopkins / UCL [RobustWLS](http://www.icn.ucl.ac.uk/motorcontrol/imaging/robustWLS.html), implemented as SPM toolbox.
  * Informatica Biomedica [AQuA](http://pangea.upv.es/mi/index.php?option=com_content&task=view&id=3&Itemid=5), implemented as an SPM toolbox.
  * CURRENTLY PRESCRIBED:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:
  * ALTERNATIVE:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:

#### discarding warm-up TRs (disdacqs) from each EPI run (if not censoring) ####
  * CURRENTLY PRESCRIBED:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:
  * ALTERNATIVE:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:

#### concatenating disdacq’d data (if necessary) ####
  * CURRENTLY PRESCRIBED:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:
  * ALTERNATIVE:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:

### slice timing correction ###
  * can it be done on nifti volumes or just .BRIK/.HEAD?
  * must do before motion correction (MC changes slice membership)
  * http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=28537&t=28489&v=f
  * 2007 NITP: Jenkinson recommends modeling temporal derivative instead of explicit STC, is has advantage of soaking up variability in HRF. TBD: research AFNI implementation.
  * 2009 ANFI board post: http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=28537&t=28489&v=f
  * 2008 Article: "Integration of motion correction and physiological noise regression in fMRI"
  * CURRENTLY PRESCRIBED:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:
  * ALTERNATIVE:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:

### motion correction ###
  * CURRENTLY PRESCRIBED:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:
  * ALTERNATIVE:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:

### spatial filtering ("smoothing") & SNR ###
  * aka smoothing, bluring
  * 3dBlurInMask, which will blur only inside a specified mask. This will prevent leakage of non-brain noise into the brain data.
  * 3dmerge
  * CURRENTLY PRESCRIBED:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
      * increases signal to noise ratio
      * reach required "smoothness" for Gaussian random field theory (common technique for cluster-based inference)
    * ARGUMENTS AGAINST:
      * reduces or eliminates activation areas smaller than smoothing kernel
      * may not be needed by chosen threshold method (e.g. randomization, FDR)
  * ALTERNATIVE:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:

### temporal filtering ###
  * low frequency drifts
  * high frequency noise
  * CURRENTLY PRESCRIBED: bandpass filtering for boxcar designs
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR: high-pass portion can even be used on event-related designs. Otherwise drift is interpreted as noise.
    * ARGUMENTS AGAINST: must be cautious when don't know frequency of expected response (e.g. event-related design)
  * ALTERNATIVE:
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR:
    * ARGUMENTS AGAINST:

### intensity normalization ###
  * CURRENTLY PRESCRIBED: Scale 4D volume intensities such that the mean intensity of each session (run?) is identical across sessions.
    * METHOD: ("Grand Mean Scaling" in FSL?)
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR: Between-session variability in 4D global intensity is strictly a nuisance variable.
    * ARGUMENTS AGAINST:  Isn't this same thing accomplished by rescaling to percent signal change?
  * ALTERNATIVE: Proportional Global Signal Scaling (PGSS): scale 3D volume intensities such that the mean intensity of each 3D volume in a scanning session is constant across the session.
    * METHOD:
    * ORDER IN PROCESSING STREAM:
    * ARGUMENTS FOR: The "global" differences in 3D-volume-to-3D-volume mean changes are nusiance effects related to hardware or physiological noise.
    * ARGUMENTS AGAINST: 1) One bright volume drives down the intensities of other volumes. 2) 3D global BOLD intensity may be correlated with an experimental condition. {Junghöfer, 2005, p15719}

### rescaling ###
  * CURRENTLY PRESCRIBED: Rescale EPI intensities (which are in arbitrary units from the scanner) so that the mean intensity of each voxel over its timecourse is 100.
    * METHOD: (?FSL: "Grand Mean Scaling?"). Use the scale block in afni\_proc.py, which essentially does this:
      1. 3dTstat -prefix epi\_mean.nii epi.nii
      1. 3dcalc -a epi.nii -b epi\_mean.nii -expr 'min(200, a/b\*100)**step(a)**step(b)' -prefix epi.scale.nii
    * ORDER IN PROCESSING STREAM: afni\_proc.py performs this after blurring and right before motion correction and regression
    * WRITING IT UP: "...and voxel-wise timecourse rescaling to percent of mean signal level, thus scaling subsequent regression parameter estimates into percent signal change measures."
    * ARGUMENTS FOR: This allows you to interpreted rescaled intensities as percent of mean such that an intensity value of 103, for example, represents 103% of the mean intensity, or a 3% increase from the mean. This also allows the later regression parameter estimates to be interpreted as percent signal change (e.g. a beta of 3 calculated as a regressor's parameter estimate means that regressor is associated with a 3% increase in signal).
    * ARGUMENTS AGAINST: None that I can think of.
  * ALTERNATIVE: Leave the EPI intensities as they are from the scanner.
    * METHOD: Just don't do anything.
    * ORDER IN PROCESSING STREAM:n/a
    * ARGUMENTS FOR: Laziness?
    * ARGUMENTS AGAINST: Doesn't afford the advantages listed above for rescaling.






## SINGLE-SESSION ESTIMATES AND TESTS AT THE INDIVIDUAL VOXEL LEVEL ##

After preprocessing to prepare a single session's EPI timeseries for analysis, the next step is to perform a **linear regression** that describes the relationship between your explanatory variables (stimulus timing, head motion, etc.) and your dependent variable (single-session EPI timeseries). Software like AFNI, SPM, and FSL help you perform this regression for each voxel individually, resulting in voxel-wise statistics that describe the fit between your EPI timeseries and your regressors. These voxel-wise regression results typically include measures of goodness of fit and statistical significance for individual regressors **and** for the full model. For example, a typical AFNI regression of two regressors (visually presented faces and houses) produces the following statistics for each voxel:

| | **GOODNESS OF FIT** | **STATISTICAL SIGNIFICANCE** |
|:|:--------------------|:-----------------------------|
| **full-model** (all regressors of interest vs. baseline) | Rsq ([3dDeconvolve manual](http://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf) section 1.2.6) | F-stat ([3dDeconvolve manual](http://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf) section 1.2.5) |
| **regressor 1** (timing of visual stimulus: faces) | partial Rsq ([3dDeconvolve manual](http://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf) section 1.2.10), and Beta (regressor coefficient) | partial F-stat for Beta ([3dDeconvolve manual](http://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf) section 1.2.9) |
| **regressor 2** (timing of visual stimulus: houses) | partial Rsq ([3dDeconvolve manual](http://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf) section 1.2.10), and Beta (regressor coefficient) | partial F-stat for Beta ([3dDeconvolve manual](http://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf) section 1.2.9) |

(Regression refreshers:)
  * [R-square](http://en.wikipedia.org/wiki/Coefficient_of_determination) is a goodness-of-fit measure: it indicates how well a regressor or set of regressors approximates the real data. R-square of 1.0 indicates a perfect fit, and R-square of 0 indicates no predictive value. **Remember that [unadjusted R-square inflates](http://en.wikipedia.org/wiki/Coefficient_of_determination#Inflation_of_R2) with increasing number of regressors in the model, so you cannot compare R-square values among models with differing numbers of regressors**.
Though all FMRI analysis software packages employ this regression-based approach for analyzing single sessions, analyses can vary in a number of ways even when performed with the same software:

  * **HRF model:** Investigators can choose how to model the expected HRF associated with individual stimulus events. A number of fixed-shape HRF responses are available (e.g. boxcar, canonical gamma curves), and some software packages can perform free deconvolution: an estimation of the HRF shape at each voxel based on that voxel's single-session data. See below for more information.
  * **Temporal autocorrelation:** Ordinary least squares (OLS) regression assumes independence among data points. EPI timeseries frequently violate that assumption: TRs collected within a few seconds of each other are necessarily non-independent, which is called temporal autocorrelation. It is increasingly common for FMRI software to include a regression method that tolerates this temporal autocorrelation. See below for more information.
  * **Formatting for higher-level analysis:** after the calculation of individual session statistics for a number of sessions or individuals, investigators are able to use those singe-session statistics to perform higher-level analyses such as group comparisons or pre/post-treatment comparisons. Some higher-level analysis software, like FSL, expect the single-session statistics to be stored in a particular format that includes rigid standards for file naming and directory structure. FSL's single-session analysis automatically creates single-session results that conform with its own standards for higher-level analysis.

These factors are among those that affect what software packages investigators choose to use for calculation of single-session stats.

### DECONVOLUTION VS FIXED-SHAPE REGRESSION ###
  * Simple fixed-shape regression (AFNI [explanation slides](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni04_fmri/afni04_fmri.pdf) and [exercise](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni_handouts/afni05_regression.pdf)) vs. [deconvolution](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni_handouts/afni06_decon.pdf)
  * deconvolution should only be performed when TRs are short (2-3s) and inter-stimulus intervals a) jittered, b) > 10s, or both (see [recent AFNI post by Robert Cox](http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=36742&t=36735)) (TBD: provide more substantial source, maybe create a section on multicollinearity, including 3dDeconvolve manual section 1.2.4 as reference)

### CORRECTING FOR TEMPORAL AUTOCORRELATION ###
  * (3dDeconvolve vs. 3dREMLfit)
  * Canonical Papers: {Woolrich, 2001, p15715}, {Zarahn, 1997, p15713}

### STIMULUS CONTRASTS IN A SINGLE SESSION ###

  * (include links to Deconvolvem.pdf, and GLTSYM syntax/guide/example)
  * easy contrast syntax appeared in [Summer 2004](http://afni.nimh.nih.gov/pub/dist/doc/misc/Decon/DeconSummer2004.html)

### AFNI's 3dDeconvolve ###
  * INPUT:
  * OUTPUT: (adapted from the manual:) Output consists of an AFNI 'bucket' type dataset containing (for each voxel)
    1. the least squares estimates of the linear regression coefficients
    1. t-statistics for significance of the coefficients
    1. partial F-statistics for significance of individual input stimuli
    1. the F-statistic for significance of the overall regression model
    * The program can optionally output extra datasets containing
      * the estimated impulse response function
      * the fitted model and error (residual) time series
  * STATISTICAL ASSUMPTIONS:
    * Verifying:
  * ARGUMENTS FOR:
  * ARGUMENTS AGAINST:
  * (TBD: ZZ requests creating z-score maps)
  * (TBD: in FIR deconvolution, use AUC as indication of response magnitude...see Example 1.4.4.5 in [Deconvolvem.pdf](http://afni.nimh.nih.gov/pub/dist/doc/manual/Deconvolvem.pdf))
  * (TBD: fit in a note about [summer 2004](http://afni.nimh.nih.gov/pub/dist/doc/misc/Decon/DeconSummer2004.html) addition of -stim\_times and rtype syntax)


### AFNI's 3dREMLfit ###
  * INPUT:
  * OUTPUT:
  * STATISTICAL ASSUMPTIONS:
    * Verifying:
  * ARGUMENTS FOR:
  * ARGUMENTS AGAINST:


### FSL's FEAT/FILM ###
  * INPUT:
  * OUTPUT:
  * STATISTICAL ASSUMPTIONS:
    * Verifying:
  * ARGUMENTS FOR:
  * ARGUMENTS AGAINST:


### SPM 5 ###
  * INPUT:
  * OUTPUT:
  * STATISTICAL ASSUMPTIONS:
    * Verifying:
  * ARGUMENTS FOR:
  * ARGUMENTS AGAINST:

### SPM 8 ###
  * INPUT:
  * OUTPUT:
  * STATISTICAL ASSUMPTIONS:
    * Verifying:
  * ARGUMENTS FOR:
  * ARGUMENTS AGAINST:






## SINGLE-SESSION ESTIMATES AND TESTS AT THE REGION LEVEL ##

### CONTROLLING FALSE POSITIVES: correcting for multiple tests to protect against alpha inflation ###
  * [Dr. Mumford](http://mumford.bol.ucla.edu/) at UCLA has an excellent [overview](http://mumford.bol.ucla.edu/mult_test_2009.pdf)
  * [FSL course](http://www.fmrib.ox.ac.uk/fslcourse/) slides on [inference testing, family-wise error, clustering, FDR, and TFCE](http://www.fmrib.ox.ac.uk/fslcourse/lectures/randomise.pdf)
  * [Gang's AFNI page](http://afni.nimh.nih.gov/sscc/gangc/mcc.html) on multiple testing correction
  * FWE vs FDR: see AFNI slides #36+ about ["Multi-Voxel Statistics"](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni07_advanced/afni07_advanced.pdf)

#### Strict voxelwise p-values ####

One poorly-supported alpha protection choice is to set a very strict voxelwise p-value threshold (p<.00001). Not much empirical support. (TBD: add reference).

#### Family-wise error (FWE) correction methods ####

##### FWE correction: bonferroni #####
Bonferroni correction is generally considered too conservative for FWE correction in FMRI.  Voxels aren't truly independent, so the number of independent tests performed is actually fewer than number of voxels. (TBD: reference).

##### FWE correction: cluster-size thresholds based on gaussian random field theory #####
A number of FWE correction methods are based on gaussian random field theory, including the frequently used cluster-size criterion {Worsley, 1992, p10172}. Creating ROIs from supra-threshold activity is one way to construct ROIs for further analysis, however there are ways to misuse these ROIs and [authors should be cautious about their application](brainImagingGuide#appropriate_use_of_functional_ROIs.md).

There is some debate about whether unsmoothed FMRI data meet the assumptions of gaussian random field theory, but is it possible that the robustness of the correction methods and the smoothness inherent in the acquired images are sufficient to allow valid application FMRI data that have not been smoothed off-line. (TBD: need reference).

###### FWE correction: AFNI clusters ######

Remember to clusterize in acquisition space whenever possible. There are [compelling reasons](http://code.google.com/p/brainwhere/wiki/brainImagingGuide#when_to_register_to_a_common_template) to complete as much processing and analysis as possible before registration to a common template.

STEP 1:  CALCULATE CLUSTER SIZE CRITERION: **[3dClustSim](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dClustSim.html)** is the updated version of AFNI AlphaSim. It calculates the minimum number of voxels necessary to achieve a given FWE-corrected alpha level based on:
  * desired FWE-corrected alpha level (**-athr**)
  * uncorrected voxel-wise alpha level (the p-value slider in the main AFNI window: **-pthr**. Defaults are .02, .01, .005, .002, .001, .0005, .0002, .0001)
  * image and voxel dimensions (**-nxyz** and **-dxyz**)
  * smoothing (**-fwhm**)
  * number of iterations in simulation (**-iter** ; default is 10^3)
  * type of clustering (**-NN**; 1=faces must touch, 2=at least edges must touch, 3=at least corners must touch)

```
3dClustSim \
-nxyz 36 64 64 \
-dxyz 4.0 3.75 3.75 \
-BALL \
-fwhm 0 \
-athr .05 .02 .01 \
-iter 10000 \
-NN 123 \
-nodec
```

The above command produces three tables of minimum cluster sizes, expressed in number of voxels. The third table, below, contains results for clustering based on NN=3 ("faces or edges or corners" touching). The table tells us, for example, that if we're using an uncorrected p-threshold of .0002 (per the ANFI slider), and we want a whole-brain family-wise-corrected alpha of .05, our clusters must contain at least two voxels. If we need to convert from voxel count to microliters for reporting or for a script that requires volume in microliters, we can do so by multiplying voxel count by microliter voxel volume.  For example: If our voxels are 4 mm thick and 3.75x3.75 mm in-plane, then 4 mm x 3.75 mm x 3.75 mm = 56.25 microliters, which amounts to a minimum cluster volume of 112.5 microliters when we multiply by the two-voxel criterion specified in the 3dClustSim output:

```
# CLUSTER SIZE THRESHOLD(pthr,alpha) in Voxels
# -NN 3  | alpha = Prob(Cluster >= given size)
#  pthr  |  0.050  0.020  0.010
# ------ | ------ ------ ------
 0.020000      11     12     13
 0.010000       7      7      8
 0.005000       5      5      6
 0.002000       4      4      4
 0.001000       3      3      4
 0.000500       3      3      3
 0.000200       2      3      3
 0.000100       2      2      2
```


STEP 2: CREATE CLUSTER MASKS: ANFI provides two ways to create supra-threshold masks of activity clusters: 1) interactive clustering via AFNI's "CLUSTERIZE" button, and 2) command-line clustering via AFNI command **[3dmerge](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dmerge.html)**
  * OPTION 1: In the main AFNI window, set your overlay threshold (r/rsq/tstat/etc) and click the "CLUSTERIZE" button:
    * See AFNI instructions: [interactive clustering in AFNI](http://afni.nimh.nih.gov/pub/dist/doc/misc/Clusterize/Clusterize.html) . Here's the short version:
    1. Set the "NN level" to 3 to allow the most liberal cluster criterion: "faces or edges or corners" touching. (This is the old "rmm" field that used to require manual calculation of center-to-center voxel distance)
    1. Set the "Voxels" field to your minimum cluster size measured in number of voxels (not microliters).
    1. click the APPLY or SET button
    1. click the RPT button to open the "AFNI Cluster Results" window, in which you type the prefix for the mask you are about to create, and clic the "SaveMsk" button to create the mask.

  * OPTION 2: create equivalent output via the AFNI command **[3dmerge](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dmerge.html)**:
```
3dmerge \
-dxyz=1 \
-1clust_order 1.75 [minimum number of voxels to keep in cluster] \
-2thresh -0.16 0.16 \
-1dindex 0 -1tindex 0 \
-prefix /path/to/your/outputClusterMask.nii.gz \
/path/to/your/inputSPM.nii
```


##### FWE correction: threshold-independent cluster selection based on non-parametric permutation testing #####
  * (Poldrack's reference:) Nichols, T.E., Holmes, A.P. (2002). Nonparametric permutation tests for functional neuroimaging: a primer with examples. Human Brain Mapping, 15, 1–25.


#### False discovery rate (FDR) ####
  * (Poldrack's reference:) Genovese, C.R., Lazar, N.A., Nichols, T. (2002). Thresholding of statistical maps in functional neuroimaging using the false discovery rate. Neuroimage, 15, 870–8.
  * update: Chumbley, J.R., Friston, K.J. (2009). False discovery rate revisited: FDR and topological inference using Gaussian random fields. Neuroimage, 44, 62–70.

##### AFNI's q-values #####
A brief description of FDR and q-value from the AFNI message board:

> Hi Joe,

> As you know, the p-value is the probability of a false positive, which can be viewed as the expected rate of false positives among all of the data values. So if you have 10,000 voxels (in your dataset or mask), and a p-value of 0.001, then you can expect 10 false positives in your dataset.

> Contrast that slightly with the q-value, which is the expected rate of false positives _among the voxels surviving your threshold_. To put it another way, it is the expected number of false positives in your dataset (or mask), divided by the number of voxels surviving the threshold.

> With the same dataset of 10,000 and p-value of 0.001, you expect 10 false positives. If 10 voxels (or less) survive the threshold, then q is 1 (I expect that it is capped). If 200 voxels survive, the q = 10/200 = .05. If ALL of your voxels survive, then q = 10/10000 = 0.001 (which is p).

> So the larger percentage of voxels that survives the threshold, the closer q gets to p.

> But it is entirely data dependent, and should vary over every sub-brick that you check.

  * see AFNI slides #36+ about ["Multi-Voxel Statistics"](http://afni.nimh.nih.gov/pub/dist/edu/latest/afni07_advanced/afni07_advanced.pdf)
  * commands:
    * fdrval
    * cdf
    * 3dFDR
    * 3drefit -UNFDR
    * 3drefit –ADDFDR -FDRmask YourMask+tlrc –STATmask anotherMask correlation\_z+tlrc
  * [a March, 2009 Bob Cox note about change to q-value formula](http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=28815&t=28815#reply_28815)
  * [a Dec, 2009 explanation of q-value limits](http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=31805&t=31805)


### CONTROLLING FALSE NEGATIVES: power analysis ###
  * [Dr. Mumford](http://mumford.bol.ucla.edu/) at UCLA describes approach and tool in second half of this [presentation](http://mumford.bol.ucla.edu/per_ch_power_2009.pdf)


### LOCALIZING ACTIVITY ###
One way to review the anatomic distribution of activity (or a lesion, or any other data coded as a 2D or 3D mask) is **clusterReporter.sh**, a brainwhere script that reports on the intersections of a priori atlas regions and your activity or lesion mask.

To map the location of your functional activity:
  1. in brains with large lesions, first trace the lesion to create a lesion mask (itksnap)
  1. [generate cluster mask](brainImagingGuide#FWE_correction:_AFNI_clusters.md) in acquisition space
  1. nonlinearly transform your cluster mask into MNI space via brainwhere's **[registerTo1mmMNI152.sh](brainImagingGuide#nonlinear_spatial_registration.md)**
  1. execute **clusterReporter.sh**:

The usage information is provided below for reference, and is current as of Jan 27, 2011, but to be certain of current usage options just execute the script with no arguments, as below:

```
$ clusterReporter.sh

Usage: clusterReporter.sh                                  \
  -m /path/to/maskOfClustersOrLesionOrAnythingElse.nii     \
[ -i /path/to/intensityVolumeForPeakReporting.nii          \ ]
  -o /path/to/outputTextFile.txt                           \
  -a <exact name of ONE atlas on which to localize the your -m mask (see below) >

Names of the a priori atlases you may include after -a:
(view any: fslview /data/birc/RESEARCH/brainwhere/utlitiesAndData/localization/[atlasName].nii.gz)

  atlasName                       atlasDescription
  --------------------------------------------------------------------------------------
  1mmHarvardOxfordCortical        48 regions, as distributed with FSL
  1mmHarvardOxfordSubcortical     21 regions, as distributed with FSL
  1mmCrosson3roiOnly              3 custom regions: posterior perisylvian, lateral frontal, medial frontal
  1mmCrosson3roi                  3 custom regions as above, surrounded by remaining 34 regions from original 48-region mask
  1mmCrosson2roiVisOnly           2 regions from Harvard Oxford cortical: occipital pole and intracalcarine cortex
```

You will have already diligently inspected the quality of your T1-to-template nonlinear registration before executing clusterReporter.sh, but a second important inspection is one in which you view the localization atlas overlaid on each participant's warped T1. Visually confirm that the anatomical boundaries of the a priori atlas regions match your participant's template-registered anatomy.






## SINGLE-SESSION ESTIMATES AND TESTS AT THE HEMISPHERE LEVEL ##
### LATERALITY INDEX ###
  * a calculation of hemispheric asymmetry, LI = (L-R)/(L+R)
  * results in LI=0 for perfect bilaterally (including zero activation on R and L), -1 for complete RH lateralization, and +1 for complete LH lateralization
  * for your lit searches: sometimes aka "asymmetry index"
  * this is one way to reduce data dimensions for subsequent analysis
  * sad to lose such rich variance, but
  * ...can be a way to equate for sensitivity
  * can be calculated for individual L/R pairs of ROIs or entire hemispheres
  * compelling because of its analogy to the Wada
  * In a cogent methods review from UCL, Seigher (2008), recommends three methods that minimize or eliminate the influence of thresholds:
    * a method based on entire voxel distributions {Branco, 2006, p09872}
    * a method based on z-score of the signal change {Nagata, 2001, p09975}
    * a bootstrapping method that is robust to outliers {Wilke, 2006, p09418}. See SPM toolbox in {Wilke, 2007, p09217}





## SINGLE-SESSION ESTIMATES AND TESTS AT THE WHOLE-BRAIN LEVEL ##





## SINGLE-SESSION ESTIMATES AND TESTS OF BRAIN "CONNECTIVITY" ##



# FMRI INTERSESSION DIFFERENCES FOR A SINGLE SUBJECT #

  * FSL authors say don't combine sessions in single regression. Instead use multi-level analysis:
    * (TBD: link here)
  * SPM authors: ??
    * SPM message board thread from 20110224: ["fixed effects analysis across two sessions"](https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind1102&L=SPM&P=R81041&1=SPM&9=A&I=-3&J=on&d=No+Match%3BMatch%3BMatches&z=4)



<font color='LightGray'>
<h1>((FMRI GROUP ANALYSIS</h1>
<h2>((GROUP ANALYSIS VIA GLM (regression, ttest, ANOVA, etc.) ))</h2>
<h2>((GROUP ANALYSIS VIA NETWORK MODELS))</h2>
<h3>((ICA))</h3>
<h3>((DCM))</h3>
<h3>((structural connectivity))</h3>
<h3>((functional connectivity))</h3>
<h3>((GCA))</h3>
</font>

<font color='LightGray'>
<h1>((FMRI ANALYSIS OF THE RESTING/DEFAULT NETWORK))</h1>
<h1>((FMRI SPARSE TEMPORAL SAMPLING))</h1>
<a href='http://www.fmrib.ox.ac.uk/fslfaq/#feat_sparse'>http://www.fmrib.ox.ac.uk/fslfaq/#feat_sparse</a>
<a href='https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind04&L=FSL&D=0&1=FSL&9=A&I=-3&J=on&d=No+Match%3BMatch%3BMatches&z=4&P=96712'>https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind04&amp;L=FSL&amp;D=0&amp;1=FSL&amp;9=A&amp;I=-3&amp;J=on&amp;d=No+Match%3BMatch%3BMatches&amp;z=4&amp;P=96712</a>
</font>



# FMRI CONTROVERSIES #

## when to register to a common template ##
Arguments for late registration to a common template:
  * All brains differ in their similarity to a common template, so registration into template space before the calculation of individual-level stats corrupts the individual stats with an unmodeled nuisance variance: each brain's degree of similarity to the template brain.
  * Because registration also spatially smooths your data, clusterizing AFTER registration to a template artificially inflates cluster size: voxel has become a weighted sum of neighbors, which introduces non-real spatial correlations that cannot currently be modeled during the calculation of minimum cluster size criterion.

## appropriate use of functional ROIs ##

In a [2007 SCAN "Tools of the Trade" editorial](http://scan.oxfordjournals.org/content/2/1/67.short), Russ Poldrack provides a concise three-page summary of the ways in which ROI analysis is useful in FMRI, and the ways in which it can be misused.

Misuse can result in problems with circularity and non-independence which may artificially inflate significance, goodness of fit, and effect size. MIT and UCSD authors recently discussed this problem in a [2009 analysis originally titled "Voodoo Correlations in Social Neuroscience"](http://pps.sagepub.com/lookup/doi/10.1111/j.1745-6924.2009.01125.x) {Vul, 2009, p10054}. This garnered about two-dozen careful replies in the literature, some of which the original authors address in "[Reply to Comments on 'Puzzlingly High Correlations in fMRI Studies of Emotion, Personality, and Social Cognition](http://pps.sagepub.com/lookup/doi/10.1111/j.1745-6924.2009.01132.x)'" {Vul, 2009, p10118}.

<font color='LightGray'>
<h2>((when to smooth and how much))</h2>
<h2>((when to SLT))</h2>
</font>


# PROCESSING AND ANALYSIS: T1 ANATOMY #
<font color='LightGray'>
<h2>((gray/white/csf volumes (FSL's fast)))</h2>
<h2>((siena and sienax))</h2>
<h2>((manual volumetrics))</h2>
<h2>((automated anatomic segmentation))</h2>
<h3>((brainsuite))</h3>
<h3>((freesurfer: sub/cortical parcellation and cortical thickness))</h3>
<h3>((first))</h3>
<h3>((loni))</h3>
<h3>((brainvisa))</h3>
<h2>((VBSLM: Voxel-based Symptom Lesion Mapping))</h2>
</font>
## VBM: automated group comparisons ##
### SPM-VBM ###
TBD for Zvinka
### FSL-VBM ###
**TBD for Zvinka** [remember to demean regressors AND use -D option](https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind0803&L=FSL&P=R2573&1=FSL&9=A&I=-3&J=on&d=No+Match%3BMatch%3BMatches&z=4)
#### modeling high-level analyses ####
  * [FSL's brief overview of GLM analysis](http://www.fmrib.ox.ac.uk/fsl//feat5/glm.html)
  * [FSL's examples of common high-level analyses](http://www.fmrib.ox.ac.uk/fsl//feat5/detail.html#SingleGroupAverage)
  * FSL list: [modeling group interactions](https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind0912&L=FSL&P=R64348&1=FSL&9=A&I=-3&J=on&d=No+Match%3BMatch%3BMatches&z=4)
  * FSL list: [group x covariate interaction](https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind1006&L=FSL&D=0&1=FSL&9=A&I=-3&J=on&d=No+Match%3BMatch%3BMatches&z=4&P=261957)
  * [FSL course FEAT lecture 2](http://www.fmrib.ox.ac.uk/fslcourse/lectures/feat1_part2.pdf)
  * [MIT Contrats FAQ](http://mindhive.mit.edu/node/60)
    * [MIT contrast papers](http://mindhive.mit.edu/node/62)
  * [an SPM lecture from 2005](http://www.fil.ion.ucl.ac.uk/spm/course/slides05/ppt/contrast.ppt)
  * [Doug Greve lecture at MIT](http://ocw.mit.edu/courses/health-sciences-and-technology/hst-583-functional-magnetic-resonance-imaging-data-acquisition-and-analysis-fall-2008/lecture-notes/1112_dg_outline.pdf)

#### execution ####
  * FSL's [step-by-step instructions](http://www.fmrib.ox.ac.uk/fsl/fslvbm/index.html) for performing FSL-VBM




<font color='LightGray'>
<h1>((PROCESSING AND ANALYSIS: DIFFUSION IMAGES))</h1>
</font>


# IMAGE ACQUISITION: PRINCIPLES #
  * In a violation of some universal principal of talent distribution, one of the inventors of FMRI, Mark Cohen, is also an excellent lecturer. There's no reason for me to re-explain MRI physics when you can just listen to his Monday 9:30 lecture from Week 1 of UCLA's 2008 NITP Summer School [(iTunes U link)](http://deimos3.apple.com/WebObjects/Core.woa/Browse/ucla-public.1447345863), and download his annotated [slides](http://www.brainmapping.org/NITP/fMRIFellowship/MRIforNITP.pdf).
  * Joseph Hornak's [Basics of MRI](http://www.cis.rit.edu/htbooks/mri/), hosted at RIT, is seminal.


<font color='LightGray'>
<h2>((Physics))</h2>
<h2>((Sequences))</h2>
<h2>((Artifacts))</h2>
<h2>((Safety))</h2>
</font>


<font color='LightGray'>
<h1>((IMAGE ACQUISITION: NUTS AND BOLTS))</h1>
<h2>((UF MBI PHILIPS 3T))</h2>
<h2>((SHANDS VERIO 3T))</h2>
</font>


# REFERENCES #

(please excuse the [inconsistent formatting](brainImagingGuide#text_conventions.md)

Branco et al. Functional MRI of memory in the hippocampus: Laterality indices may be more meaningful if calculated from whole voxel distributions. NeuroImage (2006) vol. 32 (2) pp. 592-602

Junghöfer et al. Neuroimaging of emotion: empirical effects of proportional global signal scaling in fMRI data analysis. NeuroImage (2005) vol. 25 (2) pp. 520-6

Nagata et al. Method for quantitatively evaluating the lateralization of linguistic function using functional MR imaging. AJNR Am J Neuroradiol (2001) vol. 22 (5) pp. 985-91

Poldrack. Region of interest analysis for fMRI. Soc Cogn Affect Neurosci (2007) vol. 2 (1) pp. 67-70

Seghier. Laterality index in functional MRI: methodological issues. Magn Reson Imaging (2008) vol. 26 (5) pp. 594-601

Vul et al. Puzzlingly high correlations in fMRI studies of emotion, personality, and social cognition. … on Psychological Science (2009)

Vul et al. Reply to comments on “Puzzlingly high correlations in fMRI studies of emotion, personality, and. Info: Postprints (2009)

Wilke and Lidzba. LI-tool: a new toolbox to assess lateralization in functional MR-data. J Neurosci Methods (2007) vol. 163 (1) pp. 128-36

Wilke and Schmithorst. A combined bootstrap/histogram analysis approach for computing a lateralization index from neuroimaging data. NeuroImage (2006) vol. 33 (2) pp. 522-30

Woolrich et al. Temporal autocorrelation in univariate linear modeling of FMRI data. NeuroImage (2001) vol. 14 (6) pp. 1370-86

Worsley, K.J., Evans, A.C., Marrett, S., Neelin, P. (1992). A three-dimensional statistical analysis for CBF activation studies in human brain. Journal of Cerebral Blood Flow & Metabolism, 12, 900–18.

Zarahn et al. Empirical analyses of BOLD fMRI statistics. I. Spatially unsmoothed data collected under null-hypothesis conditions. NeuroImage (1997) vol. 5 (3) pp. 179-97