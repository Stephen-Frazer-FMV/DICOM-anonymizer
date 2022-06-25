# DICOM-anonymizer
Bash script to anonymize DICOM files, designed for blinding in research projects.

The initial application of this script was to allow the same person to apply treatments to animals in a veterinary research project as the person who interpreted the CT scans. The anonymization is necessary since most DICOM viewers display patient specific data such as patient name, date of CT, and patient age, resulting in de facto unblinding. This script effectively scrubs the EXIF data from the following metadata tags:

    (0008,0012)		InstanceCreationDate
    (0008,0013)		InstanceCreationTime
    (0008,0018)		SOPInstanceUID
    (0008,0020)		StudyDate
    (0008,0021)		SeriesDate
    (0008,0022)		AcquisitionDate
    (0008,0023)		ContentDate
    (0008,0030)		StudyTime
    (0008,0031)		SeriesTime
    (0008,0032)		AcquisitionTime
    (0008,0033)		ContentTime
    (0008,0090)		ReferringPhysicianName
    (0010,0020)		PatientID
    (0010,0030)		PatientBirthDate
    (0010,0040)		PatientSex
    (0010,1010)		PatientAge
    (0010,21b0)		AdditionalPatientHistory
    (0018,5100)		PatientPosition
    (0020,000d)		StudyInstanceUID
    (0020,0010)		SeriesInstanceUID	
    (0020,000e)		StudyID
    (0040,0244)		PerformedProcedureStepStartDate
    (0040,0245)		PerformedProcedureStepStartTime

Additionally, the value of tag (0010,0010) PatientName is replaced by an SHA256 checksum of the original zip file containing the DICOM series which becomes the unique identification of the patient while the evaluator interprets the CT scans. 

The concordance between the SHA256 and the original .zip filename is stored in a file called "BlindingKey.txt". This script should be run by a third party after they have collected all CT scans, and BlindingKey.txt conserved by that third party until all evaluations are completed. The anonymized CT scans can then be delivered to the evaluator for interpretation. Once interpretation is completed, the Blinding Key is recovered from the third party, and observations and measurements in the interpretation can be concorded with the original patients and consequently the treatment group.

## Compatibility and dependencies
As of this writing, this script has only been tested on Ubuntu 21.10. The only major dependency is dcmtk, which can be installed from the standard impish/universe repository using the following commands:

        sudo apt update
        sudo apt install dcmtk

My assumption is that the script would work on any Linux distribution with dcmtk and even on Mac (if dcmtk exists on Mac or can be installed through homebrew).

## Usage

STEP 1: Ensure Dicom file structure. This script assumes the following structure for the CT scan stored inside a zip file:

        PatientName.zip
        |   DICOMDIR
        └---DICOM
            |   FILE00001.dcm
            |   FILE00002.dcm
            |   ...

DICOMDIR is a file containing a list of the individual image files in the DICOM directory along with pertinent metadata for assembling a full CT. Both DICOMDIR and the individual .dcm files in DICOM contain metadata tags which will be read and displayed in the DICOM viewer.

For easiest un-blinding after the study, ensure that each zip file is entitled [PatientName].zip. For the moment the script does not support filenames including anything but alphanumerical characters (no spaces in the filename!!!).

STEP 2: Download the bash script and make it executable. Either do a git clone or download directly. In this README I assume that the script is stored in the .bin folder in my home directory.

STEP 3: Take all DICOM files to be anonymized (all of them must be done at the same time to ensure full blinding!), and place them in a previously empty folder. In this README I assume that the folder is entitled DCMAnon in my home directory. Open a terminal and go to that folder:

        cd ~/DCMAnon

STEP 4: Run the script. WARNING!!! THE SCRIPT WILL ERASE ALL .zip FILES!!! ENSURE THAT YOU HAVE THEM BACKED UP SOMEWHERE!!!

        ~/.bin/AnonymizeDicomsMultiple.sh

I personally ran into some permissions issues due to another project I was working on simultaneously (incorrect environment variables) and had to run it as root, but that shouldn't be necessary.

STEP 5: Send the anonymized DICOM files (in the directories with 64 character names) to the investigator responsible for the evaluation of the CT scans. Make sure to keep back the BlindingKey.txt and to store it in a safe place. If you ever lose it, you may have to restart! At the worst you could rerun the script and since it is generating the new names from SHA256 hashes, it should come up with the same names so long as they are the exact same files as before, but don't run the risk.  Save and backup the BlindingKey.txt file!
