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

/* this function is used to avoid Type() functions conflicts from within RCRegEntry Class */
Func cTypeForRCRegEntry para
	Return Type(para)

	
Class RCRegistry		# Short for Ring CRegistry Class

	Key = 0		# This is the Key Handler
	RegEntry = New RCRegEntry(0,"")

	Func operator cOperator,Para
		Switch cOperator
		On "[]"
			If IsString(Para) = False
				Raise("Error : The name of the entry must be string")
			Ok
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
		value = CRegGetValue(Key, EntryName)
		If IsNumber(value)			# It must be a DWORD value so 
			value = floor(Value)	# it needs to be saved as int value
		Ok
		Return value

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
		If Exists() = True And IsMultiString() = True And MultiCount() > 0
			CRegMultiAdd(Key, EntryName, newValue)
		Else
			SetMulti(newValue)
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
			For v in valuesList
				switch cTypeForRCRegEntry(v)
				On "STRING"
					MultiAdd(v) 
				ON "NUMBER"
					MultiAdd(String(v)) 
				Other
					Raise ("Error : MultiString could just accept strings")
				Off
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
		
	Func GetExpandSZ
		Return CRegGetExpandSZ(Key, EntryName)
		
	Func SetExpandSZ value
		Return CRegSetExpandSZ(Key, EntryName, value)
		
	Func GetQWORD
		Return CRegGetQWORD(Key, EntryName)
		
	Func GetQWORDs
		v = CRegGetQWORD(Key, EntryName)
		If IsNumber(v)
			v = String(v)
		Ok
		Return v
		
	Func SetQWORD value
		Return CRegSetQWORD(Key, EntryName, value)
		
	Func GetBinary
		Return CRegGetBinary(Key, EntryName)
		
	Func SetBinary value
		Return CRegSetBinary(Key, EntryName, value)
		
	Func BinaryLength
		Return CRegBinaryLength(Key, EntryName)

	Func IsString
		Return CRegIsString(Key, EntryName)

	Func IsDWORD
		Return CRegIsDword(Key, EntryName)

	Func IsMultiString
		Return CRegIsMultiString(Key, EntryName)

	Func IsBinary
		Return CRegIsBinary(Key, EntryName)
		
	Func IsExpandSZ
		Return CRegIsExpandSZ(Key, EntryName)
		
	Func IsQWORD
		Return CRegIsQWORD(Key, EntryName)
		
	Func TypeIndex
		Return CRegType(Key, EntryName)

	Func Type
		aList = ["REG_NONE", "REG_SZ", "REG_EXPAND_SZ", "REG_BINARY", "REG_DWORD", "REG_DWORD_BIG_ENDIAN", "REG_LINK", "REG_MULTI_SZ",
				 "REG_RESOURCE_LIST", "REG_FULL_RESOURCE_DESCRIPTOR", "REG_RESOURCE_REQUIREMENTS_LIST", "REG_QWORD"]
		return aList[TypeIndex() + 1]   # increment by 1 is due to list index that starts with one

