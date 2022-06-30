#!/bin/bash

##### NOTE: Prior to running the script, all zip files should be copied to a single empty directory. NOTE THAT FILE NAMES MUST NOT CONTAIN SPECIAL CHARACTERS, INCLUDING SPACES!!! For best results, name the zip files by the patient name. To ensure blinding, files are not opened and unzipping will be done by the script. To simplify relative directory paths, script must be run in the directory with the zip files in it.

#Make script look nice:
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
echo -e "${BLUE}Running script to unzip and anonymize all DICOMs in the folder.${NC}"

##### STEP 1: Generate randomly ordered file list; otherwise time modified could inadvertently affect ordering in the file manager. If no files are found, exits with error.
FileList=$(ls | shuf)
if [ -z "$FileList" ]
then
  echo -e "${RED}Exiting script: No DICOM zip files found${NC}"
  exit 1
else
  echo -e "${GREEN}Randomly ordered file list generated.${NC}"
fi
NumFiles=$(ls | wc -l)
NumDone=0

##### STEP 2: Main part of script; runs within a for loop on the randomized file list.
for i in $FileList; do
  #### STEP 2.1: Generate SHA Checksum of each file. This will serve as the non-human readable patient ID that the principal investigator will use. Initial string recovered (ShaFull) contains both original file name and the SHA. This is stored in BlindingKey.txt, which the principal investigator (PI) will not have access to until measurements are completed, at which point they will be able to return to BlindingKey and associate their measurements with the correct patient.
  echo -e "${BLUE}Generating SHA256...${NC}"
  ShaFull=$(sha256sum $i)
  echo "$ShaFull" >> BlindingKey.txt
  ShaSum=${ShaFull:0:64}
  echo -e "${GREEN}$ShaSum${NC}"
  #### STEP 2.2: Extract the zip into a folder named by the SHA. This will allow the PI to know which CT scan they are accessing when they record measurements.
  echo -e "${BLUE}Extracting...${NC}"
  mkdir "$ShaSum"
  unzip -qq $i -d "./$ShaSum"
  chmod -R 775 "./$ShaSum"
  echo -e "${GREEN}Zip file extracted.${NC}"
  #### STEP 2.3: Anonymize the DICOMs in the folder. Full description of the tags that are erased will is included at the end of the script. Contrary to the other metadata EXIF tags, (0010,0010) is not earsed, rather it is replaced with the hash which will serve as the new CT identification.
  echo -e "${BLUE}Deleting tags...${NC}"
  dcmodify -imt -ea "(0008,0012)" -ea "(0008,0013)" -ea "(0008,0018)" -ea "(0008,0020)" -ea "(0008,0021)" -ea "(0008,0022)" -ea "(0008,0023)" -ea "(0008,0030)" -ea "(0008,0031)" -ea "(0008,0032)" -ea "(0008,0033)" -ea "(0008,0090)" -ea "(0010,0020)" -ea "(0010,0030)" -ea "(0010,0040)" -ea "(0010,1010)" -ma "(0010,0010)=$ShaSum" -ea "(0010,21b0)" -ea "(0018,5100)" -ea "(0020,000d)" -ea "(0020,0010)" -ea "(0020,000e)" -ea "(0040,0244)" -ea "(0040,0245)" ./$ShaSum/DICOM/*.dcm
  dcmodify -imt -ea "(0008,0012)" -ea "(0008,0013)" -ea "(0008,0018)" -ea "(0008,0020)" -ea "(0008,0021)" -ea "(0008,0022)" -ea "(0008,0023)" -ea "(0008,0030)" -ea "(0008,0031)" -ea "(0008,0032)" -ea "(0008,0033)" -ea "(0008,0090)" -ea "(0010,0020)" -ea "(0010,0030)" -ea "(0010,0040)" -ea "(0010,1010)" -ma "(0010,0010)=$ShaSum" -ea "(0010,21b0)" -ea "(0018,5100)" -ea "(0020,000d)" -ea "(0020,0010)" -ea "(0020,000e)" -ea "(0040,0244)" -ea "(0040,0245)" ./$ShaSum/DICOMDIR
  rm ./$ShaSum/DICOMDIR.bak
  rm ./$ShaSum/DICOM/*.bak
  NumDone=$((NumDone+1))
  echo -e "${GREEN}DICOM number $NumDone of $NumFiles ${NC}"
done

echo "Do you want to remove original zip files? (Y/N)"
while : ; do
read -n 1 k <&1
if [[ $k = Y ]] ; then
  rm *.zip
  echo ; echo "Zip files deleted, script finished."
  break
elif [[ $k = N ]] ; then
  echo ; echo "Zip files not deleted, script finished."
  break
fi
done


##############################################
##  Description of tags that we're removing ##
##############################################
# (0008,0012)		InstanceCreationDate
# (0008,0013)		InstanceCreationTime
# (0008,0018)		SOPInstanceUID
# (0008,0020)		StudyDate
# (0008,0021)		SeriesDate
# (0008,0022)		AcquisitionDate
# (0008,0023)		ContentDate
# (0008,0030)		StudyTime
# (0008,0031)		SeriesTime
# (0008,0032)		AcquisitionTime
# (0008,0033)		ContentTime
# (0008,0090)		ReferringPhysicianName
# (0010,0020)		PatientID
# (0010,0030)		PatientBirthDate
# (0010,0040)		PatientSex
# (0010,1010)		PatientAge
# (0010,0010)		PatientName				# Replaced, not erased!
# (0010,21b0)		AdditionalPatientHistory
# (0018,5100)		PatientPosition
# (0020,000d)		StudyInstanceUID
# (0020,0010)		SeriesInstanceUID	
# (0020,000e)		StudyID
# (0040,0244)		PerformedProcedureStepStartDate
# (0040,0245)		PerformedProcedureStepStartTime
