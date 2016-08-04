# README #

### What is this? ###
An alternative way to interact with AOS through Powershell. It uses business connector to interact with the AOS.
This module provide a function to basically let you run X++ select statements and get results back.

The module is written under the assumption that the businessConnector dll and a valid .axc to be available with the script module.
The module will copy those 2 files to C:\Temp if they are not already available. Feel free to change the code to suits your need.

Once the connection to AX is taken care of. Play around with the New-AXSelectStmt function. 

### What's in this module ###

* Contain Basic Functions to work with AX 2012 through business connector.
* Key functions: Get-AXObject, New-AXSelectStmt

### Pre-requisite ###
* Put the Microsoft.Dynamics.BusinessConnectorNet.dll in the same folder where you store the module
* Put a valid .axc file (AX2012.axc) in the same folder where you store the module
* C:\Temp folder is available
* Must run with 32bit version of Powershell

### Questions or comments? ###

* Please feel free to contact me.

