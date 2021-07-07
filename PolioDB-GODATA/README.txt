EASY SETUP:
1) Download 1-3 administrative levels from the Polio geoDB and save them inside "polio-inputs" folder as
   ADM0.json, ADM1.json, ADM2.json 
   (Currently, for testing, the files stored refer to Italy!)
  
2) run the conversion script by double-clicking "run-godata.bat"
   You should see in the command prompt the summary of the execution and the org units created at all three levels.
   Press ENTER to finalize the conversion.

3) Your org units are saved inside "output-godata" folder, with the name
   "newOrgUnits_COUNTRYNAME.json"

ADVANCED SETUP:
1) If you want to change the name of the input files, you must modify the "run-godata.bat" file.
  1.1) Open "run-godata.bat" inside the Notepad for editing (do not double-click it, right click -> Edit).
  1.2) You will see: java -jar godata-convert.jar 3 ADM0.json ADM1.json ADM2.json -o
    1.2.1) 3 - number of admin levels to convert
    1.2.2) ADM0.json ADM1.json ADM2.json  - file names of the files for the admin levels (should match the number)
    1.2.3) -o - if present this parameter, you will see the summary in the command prompt. 
           Otherwise, it will be written to the summary.txt file inside the "output-godata" folder.

2) After changing the above parameters, you can again run the conversion by double clicking the "run-godata.bat" file. 