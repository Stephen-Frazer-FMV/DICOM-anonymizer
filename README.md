# DICOM-anonymizer
Bash script to anonymize DICOM files, designed for blinding in research projects.

The initial application of this script was allow the same person to apply treatments to animals in a veterinary research project as the person who interpreted the CT scans. The anonymization is necessary since most DICOM viewers display patient specific data such as patient name, date of CT, and patient age. This script effectively scrubs the EXIF data from the following metadata tags:

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

Additionally, the tag (0010,0010) PatientName is replaced by an SHA256 hash of the original zip file containing the DICOM series which becomes the unique identification of the patient while the evaluator interprets the CT scans. 

The concordance between the SHA256 and the original .zip filename is stored in a file called "BlindingKey.txt". This script should be run by a third party after they have collected all CT scans, and BlindingKey.txt conserved by that third party until all evaluations are completed. The anonymized CT scans can then be delivered to the evaluator for interpretation. Once interpretation is completed, the Blinding Key is recovered from the third party, and observations and measurements in the interpretation can be concorded with the original patients and consequently the treatment group.
