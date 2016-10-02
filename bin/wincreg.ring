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



/* this function is used to avoid Type() functions conflicts from within RCRegEntry Class */
Func cTypeForRCRegEntry para
	Return Type(para)
	

Class RCRegistry		# Short for Ring CRegistry Class

	Key = 0		# This is the Key Handle
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

	Func KeyExists HKEY, SubKey
		Return CRegKeyExists(HKEY, SubKey)

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

	Func GetEntryAt index		# Return Entry Handle
		Return CRegGetAt(Key, index)

	Func GetEntryName entry		# Accepts Entry Handle
		Return CRegGetName(entry)

	Func GetEntries
		NamesList = []
		For i = 1 To EntryCount()
			Add(NamesList, GetEntryName(GetEntryAt(i)))
		Next
		Return NamesList
		
	Func CopyTo entryhandle,DestKey
		CRegCopy(entryhandle, DestKey)

	Func CopyAllTo DestKey
		For i = 1 to EntryCount()
			CRegCopy(GetEntryAt(i), DestKey)
		Next

	Func CloseKey
		CRegCloseKey(Key)

	Func DeleteKey
		CRegDeleteKey(Key)
		
	Func DeleteKey2 HKEY, SubKey
		TempKey = Key
		OpenKey([HKEY, SubKey])
		DeleteKey()
		Key = TempKey
		
	Func StringToBinary Str
		res = ""
		If Len(Str) > 0
			For i = 1 To Len(Str)
				tm = Hex(Ascii(Str[i]))
				If Len(tm) = 1
					res += "0" + tm
				Else
					res += tm
				Ok
				If i < Len(Str)
					res += ","
				Ok
			Next
		Ok
		Return res

	Func BinaryToString Bin
		res = ""
		If Len(Bin) > 1
			Bin = SubStr(Bin, ",", NL)
			Bin = Str2List(Bin)
			For hx in Bin
				res += Char(Dec(hx))
			Next
		Ok
		Return res
		
		
	
Class RCRegEntry			# Short for Ring CRegistry Entry Class

	Key = 0
	EntryName = ""
	
	Func Init passedkey, passedentryName
		Key = passedkey
		EntryName = passedentryName
	
	Func Create type
		If Exists() = False
			Switch type
				On REG_SZ
					SetString("")
				On REG_DWORD
					SetDWORD(0)
				On REG_MULTI_SZ
					SetMulti("")
				On REG_QWORD
					SetQWORD(0)
				On REG_EXPAND_SZ
					SetExpandSZ("")
				On REG_BINARY
					SetBinary("")
				Other
					If EntryName = "" EntryName = "Default" Ok
					Raise("Error : Unknown type has been passed to create (" + EntryName + ")")
				Off
		Else
			If EntryName = "" EntryName = "Default" Ok
			Raise("Error : Cannot create (" + EntryName + ") because it is already existed")
		Ok
		
	Func Get
		value = 0
		Switch Type()
				On REG_SZ
					value = GetString()
				On REG_DWORD
					value = GetDWORD()
				On REG_MULTI_SZ
					value = GetMultiList()
				On REG_QWORD
					value = GetQWORD()
				On REG_EXPAND_SZ
					value = GetExpandSZ()
				On REG_BINARY
					value = GetBinary()
				Other
					If EntryName = "" EntryName = "Default" Ok
					Raise("Error : Unknown type of (" + EntryName + ") to be retrieved")
				Off
		Return value

	Func Set value
		If Exists() = True
			Switch Type()
				On REG_SZ
					SetString(value)
				On REG_DWORD
					SetDWORD(value)
				On REG_MULTI_SZ
					SetMultiList(value)
				On REG_QWORD
					SetQWORD(value)
				On REG_EXPAND_SZ
					SetExpandSZ(value)
				On REG_BINARY
					SetBinary(value)
				Other
					If EntryName = "" EntryName = "Default" Ok
					Raise("Error : Unknown type of (" + EntryName + ") to be set")
				Off
		Else
			Switch cTypeForRCRegEntry(value)
				On "STRING"
					CRegSetValue(Key, EntryName, value)
				On "NUMBER"
					CRegSetValue(Key, EntryName, value)
				Other
					Raise("Error : Set() function could just set String or Numbers to newly created entries")
				Off	
		Ok

	Func Set2 value, type
		Switch type
			On REG_SZ
				SetString(value)
			On REG_DWORD
				SetDWORD(value)
			On REG_MULTI_SZ
				SetMultiList(value)
			On REG_QWORD
				SetQWORD(value)
			On REG_EXPAND_SZ
				SetExpandSZ(value)
			On REG_BINARY
				SetBinary(value)
			Other
				If EntryName = "" EntryName = "Default" Ok
				Raise("Error : Unknown type of (" + EntryName + ") to be set")
			Off
		
	Func SetString value
		If cTypeForRCRegEntry(value) != "STRING"
			Raise ("Error : SetString() could just accept strings")
		Ok
		CRegSetValue(Key, EntryName, value)
	
	Func GetString
		value = ""
		If Type() = REG_SZ
			value = CRegGetValue(Key, EntryName)
		Else
			Raise ("Error : GetString() could just return strings (REG_SZ)")
		Ok
		Return value
		
	Func SetDWORD value
		If IsNumber(value) = False
			Raise ("Error : SetDWORD() could just accept numbers")
		Else
			If IsDigit(String(value)) = False
				Raise ("Error : SetDWORD() could just accept real numbers(not floated)")
			Else
				If value < 0 Or value > 4294967295
					Raise ("Error : SetDWORD() : the value is out of range (0 - 4294967295)")
				Ok
			Ok
		Ok
		CRegSetValue(Key, EntryName, value)
				
	Func GetDWORD
		value = 0
		If Type() = REG_DWORD
			value = floor(CRegGetValue(Key, EntryName))	# To retrieve integer number
		Else
			Raise ("Error : GetDWORD() could just return DWORD numbers")
		Ok
		Return value

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
		CRegMultiClear(Key, EntryName)

	Func SetMultiList valuesList
		If IsList(valuesList) = False 
			Raise("Error : SetMultiList() function accepts only lists")
		Ok
		If Len(valuesList) > 0 
			If Exists() And IsMultiString() MultiClear() Ok
			For v in valuesList
				Switch cTypeForRCRegEntry(v)
					On "STRING"
						MultiAdd(v) 
					ON "NUMBER"
						MultiAdd(String(v)) 
					Other
						Raise ("Error : MultiString could just accept strings or numerical strings")
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
		
	Func GetExpandedSZ
		Return CRegGetExpandedSZ(Key, EntryName)
		
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
		
	Func Exists
		Return CRegExists(Key, EntryName)

	Func Rename newName
		CRegRename(Key, EntryName, newName)

	Func CopyTo newKeyHandle
		CRegCopy(Key, EntryName, newKeyHandle)
		
	Func Clear
		If Exists() = True
			Switch Type()
				On REG_SZ
					Set("")
				On REG_DWORD
					Set(0)
				On REG_MULTI_SZ
					SetMulti("")
				On REG_QWORD
					SetQWORD(0)
				On REG_EXPAND_SZ
					SetExpandSZ("")
				On REG_BINARY
					SetBinary("")
				Other
					If EntryName = "" EntryName = "Default" Ok
					Raise("Error : Unknown type has been passed to create (" + EntryName + ")")
				Off
		Else
			If EntryName = "" EntryName = "Default" Ok
			Raise("Error : Cannot clear (" + EntryName + ") because it is not existed")
		Ok

	Func Delete
		CRegDelete(Key, EntryName)

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
		
	Func Type
		Return CRegType(Key, EntryName)

	Func TypeName
		aList = ["REG_NONE", "REG_SZ", "REG_EXPAND_SZ", "REG_BINARY", "REG_DWORD", "REG_DWORD_BIG_ENDIAN", "REG_LINK", "REG_MULTI_SZ",
				 "REG_RESOURCE_LIST", "REG_FULL_RESOURCE_DESCRIPTOR", "REG_RESOURCE_REQUIREMENTS_LIST", "REG_QWORD"]
		return aList[Type() + 1]   # increment by 1 is due to list index that starts with one

