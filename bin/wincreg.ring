/*--------------------------------------------------------------------------
/	Name         : Windows CRegistry Class Extension In Ring
/	Purpose      : Help access and edit windows registry entries and values
/						easily from within Ring Programming Language
/
/	Author Name  : Majdi Sobain
/	Author Email : MajdiSobain@Gmail.com
/
/					Copyright (c) 2016
/--------------------------------------------------------------------------*/



LoadLib("ring_wincreg.dll")
Load "wincreg.rh"


Func KeyExists HKEY, SubKey
	Return CRegKeyExists(HKEY, SubKey)

	
Class RCRegistry		# Short for Ring CRegistry Class

	Key = 0		# This is the Key Handler
	RegEntry = New RCRegEntry(0,"")

	Func operator cOperator,Para
		Switch cOperator
		On "[]"
			RegEntry.Init(Key, Para)
			Return RegEntry
		Off

	Func OpenKey ParaList
		If IsList(ParaList) = False 
			Raise("Error : This function expects parameters as a list 'OpenKey([para1,para2])' ") 
		Ok
		Switch Len(ParaList)
		On 2 
			Key = CRegOpenKey(ParaList[1], ParaList[2])
			Return Key
		On 3 
			Key = CRegOpenKey(ParaList[1], ParaList[2], ParaList[3])
			Return Key
		On 4 
			Key = CRegOpenKey(ParaList[1], ParaList[2], ParaList[3], ParaList[4])
			Return Key
		Other 
			Raise("Error : Incorrect Number of Parameters passed" + nl +
			 "          This function expects parameters as a list 'OpenKey([para1,para2])' ")
		Off 

	Func OpenKey2 HKEY, SubKey
		Key = CRegOpenKey(HKEY, SubKey)
		Return Key

	Func OpenKey3 HKEY, SubKey, Flags
		Key = CRegOpenKey(HKEY, SubKey, Flags)
		Return Key

	Func OpenKey4 HKEY, SubKey, Flags, Access64Tree
		Key = CRegOpenKey(HKEY, SubKey, Flags, Access64Tree)
		Return Key

	Func SetFlags Flags
		CRegSetFlags(Key, Flags)

	Func GetFlags 
		Return CRegGetFlags(Key)

	Func Access64Tree choice
		CRegAccess64Tree(Key, choice)
		
	Func IsVirtualized
		Return CRegIsVirtualized(Key)
		
	Func IsVirtualized2
		Return CRegIsVirtualized(Key, True)

	Func EntryCount
		Return CRegEntryCount(Key)

	Func SubKeyExists SubKey
		Return CRegSubKeyExists(Key, SubKey)

	Func SubKeysCount
		Return CRegSubKeysCount(Key)
		
	Func GetSubKeyAt index
		Return CRegGetSubKeyAt(Key, index)
	
	Func GetSubKeys
		SubKeys = []
		For i = 1 to SubKeysCount()
			Add(SubKeys, GetSubKeyAt(i))
		Next
		Return SubKeys
	
	Func Refresh
		CRegRefresh(Key)

	Func GetEntryAt index		# Return Entry Handler
		Return CRegGetAt(Key, index)

	Func GetEntryName entry		# Accepts Entry Handler
		Return CRegGetName(entry)

	Func GetEntries
		NamesList = []
		For i = 1 To EntryCount()
			Add(NamesList, GetEntryName(GetEntryAt(i)))
		Next
		Return NamesList

	Func CopyAllTo DestKey
		For i = 1 to EntryCount
			CRegCopy(GetEntryAt(i), DestKey)
		Next

	Func CloseKey
		CRegCloseKey(Key)

	Func DeleteKey
		CRegDeleteKey(Key)
		
		
	
Class RCRegEntry			# Short for Ring CRegistry Entry Class

	Key = 0
	EntryName = ""
	
	Func Init passedkey, passedentryName
		Key = passedkey
		EntryName = passedentryName

	Func Get
		Return CRegGetValue(Key, EntryName)

	Func Set value
		CRegSetValue(Key, EntryName, value)

	Func Exists
		Return CRegExists(Key, EntryName)

	Func Rename newName
		CRegRename(Key, EntryName, newName)

	Func CopyTo newKeyHandler
		CRegCopy(Key, EntryName, newKeyHandler)

	Func Delete
		CRegDelete(Key, EntryName)

	Func SetMulti value
		CRegSetMulti(Key, EntryName, value)

	Func MultiAdd newValue
		If Exists() = True And MultiCount() > 0
			CRegMultiAdd(Key, EntryName, newValue)
		Else
			SetMutli(newValue)
		Ok

	Func MultiSetAt index, newValue
		CRegMultiSetAt(Key, EntryName, index, newValue)

	Func MultiGetAt index
		Return CRegMultiGetAt(Key, EntryName, index)

	Func MultiRemoveAt index
		CRegMultiRemoveAt(Key, EntryName, index)

	Func MultiCount
		Return CRegMultiCount(Key, EntryName)

	Func MultiClear
		CRegMutliClear(Key, EntryName)

	Func SetMultiList valuesList
		If Len(valuesList) > 0 
			For i = 1 To Len(valuesList)
				If IsString(valueList[i]) = True
					MultiAdd(valueList[i]) 
				But IsNumber(valueList[i]) = True
					MultiAdd(String(valueList[i])) 
				Else 
					Raise ("Error : MultiString could just accept strings")
				Ok
			Next
		Ok

	Func GetMultiList
		MultiList = []
		If MultiCount() > 0
			For i = 1 to MultiCount()
				Add(MultiList, MultiGetAt(i))
			Next
		Ok
		Return MultiList

	Func IsString
		Return CRegIsString(Key, EntryName)

	Func IsDWORD
		Return CRegIsDword(Key, EntryName)

	Func IsMultiString
		Return CRegIsMultiString(Key, EntryName)

	Func IsBinary
		Return CRegIsBinary(Key, EntryName)



