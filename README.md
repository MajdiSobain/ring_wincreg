# Ring_WinCReg
This Ring Extension helps access and edit windows registry entries and values easily from within Ring Programming Language

	Note: RCRegistry Class in Ring_WinCReg Extension is now compatible with Ring 1.1 only. 
	
	It will show errors if used with Ring 1.0.

## How to use in Ring

1- Download this repo project as zip file from the green button on the upper right corner "Clone or download"

2- Extract all the files that present in the "bin" folder and copy them into "bin" folder of the binary ring

3- Load the "wincreg.ring" file as it loads all of the extension and its associated library features

4- For more information on how to use the extension and the associated library functions use the documentations attached(Documentation)

## Example

This is a simple ring code that use this extension:

    Load "wincreg.ring"
  
    Reg = new RCRegistry
  
    Reg.OpenKey([HKEY_CURRENT_USER, "Software\MyApplication"]) 
    # This will create the Key "MyApplication" if its not present then it will be Opened
  
    Reg["AppVersion"].SetValue("2.3")
	
	See Reg["AppVersion"].GetValue()
  
    Reg.CloseKey()
  

## Other resources

1- [The article of this extension in the ring forum](https://groups.google.com/forum/#!topic/ring-lang/YwHmR79_Fsc)
  
2- [The article of the original C++ Class (CRegistry Wrapper)](http://www.codeproject.com/Articles/8953/Registry-Wrapper-Class-CRegistry)
	

## How to Compile

1- Open [Git bash](http://opensourcerer.diy.org/challenge/3) then Navigate to the folder that you want to bring Ring source into it. For example:

	cd c:
	
2- Clone the ring source from GitHub into the opened location (c:)
  
	git clone https://github.com/ring-lang/ring.git
	
3- Optionally, You can create another branch in local repo of ring to use it for extensions development. This will prevent any changes in the master branch of ring if you plan to make some changes in ring away from newly added extensions. This can be done by:
  
	cd ring
	git checkout -b extensions

*This will create a new branch called extensions and will switch to it.

4- Navigate to the extensions folder 

	cd extensions
	
5- Clone the ring_wincreg extension source from GitHub into extensions folder

	git clone https://github.com/MajdiSobain/ring_wincreg.git
	
6- Now Open Command line (cmd) in the extension folder (c:\ring\extensions\ring_wincreg) and compile the extension by run buildvc.bat batch file

	buildvc.bat
	
.

Enjoy ^_^
