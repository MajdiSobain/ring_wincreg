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

RCRegRetObj = NULL

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

	Func SetObject obj
		O4R = New Objects2Reg(Self)
		O4R.SetObject(obj)
			
	Func GetObject
		O4R = New Objects2Reg(Self)
		Return O4R.GetObject()

		
Class Objects2Reg
	EntryObj = NULL
	CollecterList = []

	Func init EntObj
		EntryObj = EntObj
	
	Func SetObject obj		# From Collector to Registry
		ConfObject(obj, EntryObj.EntryName /*ObjectName*/)		# From Input to Collector
		TempD = List2Str(CollecterList)
		oReg = New RCRegistry
		EntryObj.SetBinary(oReg.StringToBinary(TempD))
		
	Func ConfObject obj, objectName
		ResList = ["--RING--OBJECT--"]
		If IsObject(obj) = False 
			Raise("Error : ConfObject() can just accept objects, and their names")
		Ok
		Add(ResList, "-CName--" + ClassName(obj))
		Add(ResList, "........")
		oList = Attributes(obj)
		ObjNum = 1
		For o in oList
			v = 0
			eval("v = obj." + o)
			Switch cTypeForRCRegEntry(v)
				On "STRING"
					Add(ResList, "-S--" + o + " = '" + v + "'")
				On "NUMBER"
					Add(ResList, "-N--" + o + " = " + String(v))
				On "LIST"
					Add(ResList, "-L--" + o)
					AddToInputList(ResList, v, "-L--", obj, objectName)
				On "OBJECT"
					If ClassName(v) = ClassName(obj) 
						See "Warning : Theres ignored object recursion. Object Recursion will end in overflow problems"
					Ok
					nObjEntName = objectName + "-o" + ObjNum
					Add(ResList, "-O--" + o + " = '" + nObjEntName + "'" )
					ConfObject(v, nObjEntName)
					ObjNum += 1
				Other
				
				Off
			
			Add(ResList, "........")
		Next
		ToCollector(ResList, objectName)
		
	Func ToCollector srcList, objectName
		FinalRes = List2Str(srcList)
		FinalRes = SubStr(FinalRes, NL, "@!^")
		Add(CollecterList, objectName)
		Add(CollecterList, FinalRes)
	
	Func AddToInputList ResLst, currentlist, prefix, CurrObj, ObName
		ObjNum = 1
		For i = 1 To Len(currentlist)
			Switch cTypeForRCRegEntry(currentlist[i])
				On "STRING"
					Add(ResLst, prefix + "-S--" + currentlist[i] )
				On "NUMBER"
					Add(ResLst, prefix + "-N--" + currentlist[i])
				On "LIST"
					AddToInputList(ResLst, currentlist[i], prefix + "-L--", CurrObj, ObName) 
				On "OBJECT"
					If ClassName(currentlist[i]) = ClassName(CurrObj) 
						See "Warning : Theres ignored object recursion. Object Recursion will end in overflow problems" 
					Ok
					nObjEntName = ObName + "-l" + String(Len(prefix)/4) + "o" + ObjNum
					Add(ResLst, prefix + "-O--" + nObjEntName )
					ConfObject(currentlist[i], nObjEntName)
					ObjNum += 1
				Other
					
				Off
			Add(ResLst, prefix + "........")
		Next

	Func GetObject		# From Registry to Collector + Request Retrieving The Main Object
		If EntryObj.IsBinary() = False
			Raise("Error : Unknown Object saving type entry")
		Ok
		oReg = New RCRegistry
		RwaData = oReg.BinaryToString(EntryObj.GetBinary())
		CollecterList = Str2List(RwaData)
		
		Return RetObject(FromCollector(EntryObj.EntryName))	# The main object
			
	Func FromCollector Objname
		ObjIndex = Find(CollecterList, Objname)
		TempLst = SubStr(CollecterList[ObjIndex +1], "@!^", NL)
		TempLst = Str2List(TempLst)
		Return TempLst
	
	Func RetObject objList		# Return Objects from Collector
		resList = []
		LocRetObj = NULL
		If Len(objList) > 0 
			If objList[1] != "--RING--OBJECT--"
				Raise("Error : Unknown Ring Object saving format")
			Ok
			If Left(objList[2], 8) = "-CName--"
				If Find(Classes(), SubStr(objList[2], 9)) = 0
					Raise("Error : Cannot return Ring Object because it's class is not in the available classes list")
				Ok
				Eval("LocRetObj = New " + SubStr(objList[2], 9))
			Else
				Raise("Error : Unknown Ring Object saving format")
			Ok
			For o = 1 to Len(objList)
				attlst = []
				chvalue = Left(objList[o], 4)
				Switch chvalue
					On "...."
						Loop
					On "-S--"
						Eval("Add(attlst, :" + SubStr(objList[o], 5) + ")")
						If Find(Attributes(LocRetObj), attlst[1][1])
							Eval("LocRetObj." + attlst[1][1] + " = '" + attlst[1][2] + "'")
						Else
							AddAttribute(LocRetObj, attlst[1][1])
							Eval("LocRetObj." + attlst[1][1] + " = '" + attlst[1][2] + "'")
						Ok
					On "-N--"
						Eval("Add(attlst, :" + SubStr(objList[o], 5) + ")")
						If Find(Attributes(LocRetObj), attlst[1][1])
							Eval("LocRetObj." + attlst[1][1] + " = " + attlst[1][2])
						Else
							AddAttribute(LocRetObj, attlst[1][1])
							Eval("LocRetObj." + attlst[1][1] + " = " + attlst[1][2])
						Ok
					On "-L--"
						lstname = ""
						Eval("lstname = '" + SubStr(objList[o], 5) + "'")
						If Find(Attributes(LocRetObj), lstname)
							lst = AddToOutputList(objList, o + 1, "-L--") 
							Eval("LocRetObj." + lstname + " = lst")
						Else
							AddAttribute(LocRetObj, lstname)
							lst = AddToOutputList(objList, o + 1, "-L--") 
							Eval("LocRetObj." + lstname + " = lst")
						Ok
												
						For i = o to Len(objList)		# this loop to help jump already added list
							If objList[i] = "........"
								o = i
								Exit
							Ok
						Next
					On "-O--"
						Eval("Add(attlst, :" + SubStr(objList[o], 5) + ")")
						If Find(Attributes(LocRetObj), attlst[1][1])
							TempLst = FromCollector(attlst[1][2])
							ob = RetObject(TempLst)
							Eval("LocRetObj." + attlst[1][1] + " = ob")
						Else
							AddAttribute(LocRetObj, attlst[1][1])
							TempLst = FromCollector(attlst[1][2])
							ob = RetObject(TempLst)
							Eval("LocRetObj." + attlst[1][1] + " = ob")
						Ok
					Other
					
					Off
				attlst = []
			Next
		Ok
		RCRegRetObj = LocRetObj
		Return RCRegRetObj

		
	Func AddToOutputList srcObjList, currentIndex, prefix
		opList = []
		lastindex = 0
		For j = currentIndex To Len(srcObjList)
			If srcObjList[j] = SubStr(prefix, 5) + "........"
				lastindex = j
				Exit
			Ok
		Next
		For k = currentIndex To lastindex
			chkvalue = SubStr(srcObjList[k], Len(prefix) +1 , 4)
			Switch chkvalue
				On "...."
					Loop
				On "-S--"
					Add(opList, SubStr(srcObjList[k], Len(prefix) + 5))
				On "-N--"
					Add(opList, Number(SubStr(srcObjList[k], Len(prefix) + 5)))
				On "-L--"
					nlist = AddToOutputList(srcObjList, k, prefix + "-L--")
					Add(opList, nlist)
					For i = k to Len(srcObjList)	# this loop to help jump already added list
						If srcObjList[i] = prefix + "........"
							k = i 
							Exit
						Ok
					Next
				On "-O--"
					TempLst = FromCollector(SubStr(srcObjList[k], Len(prefix) + 5))
					ob = RetObject(TempLst)
					Add(opList, ob)
				Other
				
				Off
		Next
		
		Return opList
		