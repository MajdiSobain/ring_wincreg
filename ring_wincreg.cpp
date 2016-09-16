/* Copyright (c) 2016 Majdi Sobain <MajdiSobain@Gmail.com> */

extern "C" {
#include "ring.h"
}

#include "creg_registry.h"
#include "ring_wincreg.h"

extern "C" {

RING_API void ringlib_init ( RingState *pRingState )
{
	ring_vm_funcregister("cregopenkey",ring_vm_creg_cregopenkey);
	ring_vm_funcregister("cregclosekey",ring_vm_creg_cregclosekey);
	ring_vm_funcregister("cregdeletekey",ring_vm_creg_cregdeletekey);
	ring_vm_funcregister("cregkeyexists",ring_vm_creg_cregkeyexists);
	ring_vm_funcregister("cregsubkeyexists",ring_vm_creg_cregsubkeyexists);
	ring_vm_funcregister("cregsetflags",ring_vm_creg_cregsetflags);
	ring_vm_funcregister("cregentrycount",ring_vm_creg_cregentrycount);
	ring_vm_funcregister("creggetflags",ring_vm_creg_creggetflags);
	ring_vm_funcregister("cregaccess64tree",ring_vm_creg_cregaccess64tree);
	ring_vm_funcregister("cregisvirtualized",ring_vm_creg_cregisvirtualized);
	ring_vm_funcregister("cregsubkeyscount",ring_vm_creg_cregsubkeyscount);
	ring_vm_funcregister("creggetsubkeyat",ring_vm_creg_creggetsubkeyat);
	ring_vm_funcregister("cregrefresh",ring_vm_creg_cregrefresh);
	ring_vm_funcregister("creggetat",ring_vm_creg_creggetat);
	ring_vm_funcregister("creggetname",ring_vm_creg_creggetname);
	ring_vm_funcregister("cregcopy",ring_vm_creg_cregcopy);
	ring_vm_funcregister("cregrename",ring_vm_creg_cregrename);
	ring_vm_funcregister("cregsetvalue",ring_vm_creg_cregsetvalue);
	ring_vm_funcregister("creggetvalue",ring_vm_creg_creggetvalue);
	ring_vm_funcregister("cregdelete",ring_vm_creg_cregdelete);
	ring_vm_funcregister("cregsetmulti",ring_vm_creg_cregsetmulti);
	ring_vm_funcregister("cregmultiremoveat",ring_vm_creg_cregmultiremoveat);
	ring_vm_funcregister("cregmultisetat",ring_vm_creg_cregmultisetat);
	ring_vm_funcregister("cregmultiadd",ring_vm_creg_cregmultiadd);
	ring_vm_funcregister("cregmultigetat",ring_vm_creg_cregmultigetat);
	ring_vm_funcregister("cregmulticount",ring_vm_creg_cregmulticount);
	ring_vm_funcregister("cregmulticlear",ring_vm_creg_cregmulticlear);
	ring_vm_funcregister("creggetexpandsz",ring_vm_creg_creggetexpandsz);
	ring_vm_funcregister("cregsetexpandsz",ring_vm_creg_cregsetexpandsz);
	ring_vm_funcregister("cregisstring",ring_vm_creg_cregisstring);
	ring_vm_funcregister("cregisdword",ring_vm_creg_cregisdword);
	ring_vm_funcregister("cregismultistring",ring_vm_creg_cregismultistring);
	ring_vm_funcregister("cregisbinary",ring_vm_creg_cregisbinary);
	ring_vm_funcregister("cregisexpandsz",ring_vm_creg_cregisexpandsz);
	ring_vm_funcregister("cregexists",ring_vm_creg_cregexists);
	ring_vm_funcregister("cregtype",ring_vm_creg_cregtype);
	
}

// CRegistry cregopenkey ( RootHkey index /*like HKEY_CURRENT_USER*/ , string keyname , \optional int flags, \optional boolean access64tree )
void ring_vm_creg_cregopenkey(void *pPointer){
	CRegistry *pCR = new CRegistry;
	HKEY hkey;
	LONG lResult;
	if (RING_API_PARACOUNT > 1 ) {
		if ( RING_API_ISNUMBER(1) ) {
		switch ((int) RING_API_GETNUMBER(1)){
			case 1:
				hkey = HKEY_CLASSES_ROOT;
				break;
			case 2:
				hkey = HKEY_CURRENT_USER;
				break;
			case 3:
				hkey = HKEY_LOCAL_MACHINE;
				break;
			case 4:
				hkey = HKEY_USERS;
				break;
			case 5:
				hkey = HKEY_CURRENT_CONFIG;
				break;
			default:
				RING_API_ERROR("Incorrect HKEY index");
				return;
			}
		} else {
			RING_API_ERROR(RING_API_BADPARATYPE);
		return;
		}
	} else {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	switch RING_API_PARACOUNT {
	case 2:
		if ( !RING_API_ISSTRING(2) ) {
			RING_API_ERROR(RING_API_BADPARATYPE);
			return ;
		}
		break;
	case 3:
		if ( RING_API_ISSTRING(2) && RING_API_ISNUMBER(3) ) {
			pCR->SetFlags((int) RING_API_GETNUMBER(3));
		} else {
			RING_API_ERROR(RING_API_BADPARATYPE);
			return ;
		}
		break;
	case 4:
		if ( RING_API_ISSTRING(2) && RING_API_ISNUMBER(3)  && RING_API_ISNUMBER(4) ) {
			pCR->SetFlags((int) RING_API_GETNUMBER(3));
			pCR->Access64Tree((int) RING_API_GETNUMBER(4));
		} else {
			RING_API_ERROR(RING_API_BADPARATYPE);
			return ;
		}
		break;
	default:
		RING_API_ERROR("This function expects two, three, or four parameters");
		return ;
	}
	lResult = pCR->Open(RING_API_GETSTRING(2), hkey);
	if ( lResult == ERROR_SUCCESS ) {
		RING_API_RETCPOINTER(pCR, "CRegistry");
		return;
	} else {
		TCHAR msgBuf[200];
		RING_API_ERROR(GetErrorMsg(lResult, msgBuf, 200));
		return;
	}
}

// void cregclosekey ( CRegistry keyhandler )
void ring_vm_creg_cregclosekey(void *pPointer) {
	if ( RING_API_PARACOUNT != 1 ) {
		RING_API_ERROR(RING_API_MISS1PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry");
		if ( (p) && (p->hKey) ) { p->Close();} else {RING_API_ERROR("Error : invalid CRegistry key handler");}
	} else {
		RING_API_ERROR("Error : invalid CRegistry key handler");
	}
}

// void cregdeletekey ( CRegistry keyhandler )
void ring_vm_creg_cregdeletekey(void *pPointer) {
	if ( RING_API_PARACOUNT != 1 ) {
		RING_API_ERROR(RING_API_MISS1PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry");
		if (p) {
			if ( (p->GetHRoot()) && strlen(p->GetSubKey()) ) {
				p->DeleteKey();
			} else RING_API_ERROR("Error : Connot delete. Invalid HKEY or Subkey path");
		} else {RING_API_ERROR("Error : invalid CRegistry key handler");}
	} else {
		RING_API_ERROR("Error : invalid CRegistry key handler");
	}
}

// boolean cregkeyexist ( RootHkey /*like HKEY_CURRENT_USER*/ , string keyname ) 
void ring_vm_creg_cregkeyexists( void *pPointer) {
	CRegistry creg;
	HKEY hkey;
	LONG lResult;
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISNUMBER(1) && RING_API_ISSTRING(2) ) {
		switch ( (int) RING_API_GETNUMBER(1) ) {
			case 1:
				hkey = HKEY_CLASSES_ROOT;
				break;
			case 2:
				hkey = HKEY_CURRENT_USER;
				break;
			case 3:
				hkey = HKEY_LOCAL_MACHINE;
				break;
			case 4:
				hkey = HKEY_USERS;
				break;
			case 5:
				hkey = HKEY_CURRENT_CONFIG;
				break;
			default:
				RING_API_ERROR("Incorrect HKEY index");
				return;
			}
		lResult = creg.KeyExists(RING_API_GETSTRING(2), hkey);
		if (lResult == ERROR_SUCCESS) {
			RING_API_RETNUMBER(1);
			return;
		} else if (lResult == 2) {
			RING_API_RETNUMBER(0);
		} else {
			TCHAR msgBuf[200];
			RING_API_RETNUMBER(0);
			RING_API_ERROR(GetErrorMsg(lResult, msgBuf, 200));
		}
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// boolean cregsubkeyexist ( CRegistry keyhandler , string subkeyname )
void ring_vm_creg_cregsubkeyexists(void *pPointer) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		LONG lResult;
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			lResult = p->SubKeyExists(RING_API_GETSTRING(2));
			if (lResult == ERROR_SUCCESS) {
				RING_API_RETNUMBER(1);
				return;
			} else if (lResult == 2) {
				RING_API_RETNUMBER(0);
			} else {
				TCHAR msgBuf[200];
				RING_API_RETNUMBER(0);
				RING_API_ERROR(GetErrorMsg(lResult, msgBuf, 200));
			}
		} else { RING_API_ERROR("Error : invalid CRegistry key handler"); }
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// void cregsetflags ( CRegistry keyhandler , int flags )
void ring_vm_creg_cregsetflags( void *pPointer) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISNUMBER(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			p->SetFlags((int) RING_API_GETNUMBER(2));
		} else RING_API_ERROR("Error : invalid CRegistry key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// int cregentrycount ( CRegistry keyhandler )
void ring_vm_creg_cregentrycount( void *pPointer) {
	if ( RING_API_PARACOUNT != 1 ) {
		RING_API_ERROR(RING_API_MISS1PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			RING_API_RETNUMBER(p->Count());
		} else RING_API_ERROR("Error : invalid CRegistry key handler");
	} else {
		RING_API_ERROR("Error : invalid CRegistry key handler");
	}
}

// int creggetflags ( CRegistry keyhandler )
void ring_vm_creg_creggetflags( void *pPointer) {
	if ( RING_API_PARACOUNT != 1 ) {
		RING_API_ERROR(RING_API_MISS1PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			RING_API_RETNUMBER(p->GetFlags());
		} else RING_API_ERROR("Error : invalid CRegistry key handler");
	} else {
		RING_API_ERROR("Error : invalid CRegistry key handler");
	}
}

// void cregaccess64tree ( CRegistry keyhandler , boolean access)
void ring_vm_creg_cregaccess64tree( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISNUMBER(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			p->Access64Tree((int) RING_API_GETNUMBER(2));
		} else RING_API_ERROR("Error : invalid CRegistry key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// boolean cregisvirtualized (CRegistry key)
// int cregisvirtualized (CRegistry key, bool detailed)
void ring_vm_creg_cregisvirtualized( void *pPointer ) {
	if ( RING_API_PARACOUNT == 0 || RING_API_PARACOUNT > 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_PARACOUNT == 2 ){
		if ( RING_API_ISPOINTER(1) &&  RING_API_ISNUMBER(2)) {
			CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
			if ( (p) && (p->hKey) ) {
				RING_API_RETNUMBER((int) p[0].IsVirtualized()); 
			} else RING_API_ERROR("Error : Bad CRegistry Key handler");
		} else {
			RING_API_ERROR(RING_API_BADPARATYPE);
		}
	} else {
		if ( RING_API_ISPOINTER(1) ) {
			CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
			if ( (p) && (p->hKey) ) {
				if ((int) p[0].IsVirtualized() == 1) {
					RING_API_RETNUMBER((int) p[0].IsVirtualized());
				} else {
					RING_API_RETNUMBER(((int) p[0].IsVirtualized()) * 0);
				} 
			} else RING_API_ERROR("Error : Bad CRegistry Key handler");
		} else RING_API_ERROR(RING_API_BADPARATYPE);
	}	
}

// int cregsubkeyscount ( CRegistry keyhandler , int valueindex )
void ring_vm_creg_cregsubkeyscount( void *pPointer ) {
	if ( RING_API_PARACOUNT != 1 ) {
		RING_API_ERROR(RING_API_MISS1PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			RING_API_RETNUMBER(p->SubKeysCount());
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// String creggetsubkeyat ( CRegistry keyhandler , int valueindex )
void ring_vm_creg_creggetsubkeyat( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISNUMBER(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (int) RING_API_GETNUMBER(2) > 0 && (int) RING_API_GETNUMBER(2) < p->SubKeysCount() +1 ) {
			if ( (p) && (p->hKey) ) {
				char subkey[MAX_REG_KEY];
				RING_API_RETSTRING(p->GetSubKeyAt((int) RING_API_GETNUMBER(2) -1, subkey, MAX_REG_KEY));
			} else RING_API_ERROR("Error : Bad CRegistry Key handler");
		} else { RING_API_ERROR("Invalid subkey index"); }
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// boolean cregrefresh ( CRegistry keyhandler )
void ring_vm_creg_cregrefresh( void *pPointer ) {
	if ( RING_API_PARACOUNT != 1 ) {
		RING_API_ERROR(RING_API_MISS1PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			RING_API_RETNUMBER(p->Refresh());
		} else RING_API_ERROR("Error : invalid CRegistry key handler");
	} else {
		RING_API_ERROR("Error : invalid CRegistry key handler");
	}
}

// CRegEntry* creggetat ( CRegistry keyhandler , int valueindex )
void ring_vm_creg_creggetat( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISNUMBER(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (int) RING_API_GETNUMBER(2) > 0 && (int) RING_API_GETNUMBER(2) < p->Count() +1 ) {
			if ( (p) && (p->hKey) ) {
				RING_API_RETCPOINTER(p->GetAt((int) RING_API_GETNUMBER(2) -1), "CRegEntry");
			} else RING_API_ERROR("Error : Bad CRegistry Key handler");
		} else { RING_API_ERROR("Invalid registry entry index"); }
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// string creggetname ( CRegEntry entry )
void ring_vm_creg_creggetname( void *pPointer ) {
	if ( RING_API_PARACOUNT != 1 ) {
		RING_API_ERROR(RING_API_MISS1PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) ) {
		CRegEntry *p = (CRegEntry *) RING_API_GETCPOINTER(1, "CRegEntry") ;
		if ( (p) && p->HasOwner() ) { RING_API_RETSTRING(p->lpszName); }
		else { RING_API_ERROR("Error : Bad entry handler"); }
	} else {
		RING_API_ERROR("Error : Bad entry handler");
	}
}

// void cregcopy ( CRegEntry Entry , CRegistry Dest )\
// void cregcopy ( CRegistry Source , String valuename, CRegistry Dist )
void ring_vm_creg_cregcopy( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 && RING_API_PARACOUNT != 3 ) {
		RING_API_ERROR("Error: Bad parameter count, this function expects two\\three parameters");
		return ;
	}
	if ( RING_API_PARACOUNT == 2 ) {
		if ( RING_API_ISPOINTER(1) && RING_API_ISPOINTER(2) ) {
			CRegEntry *pe = (CRegEntry *) RING_API_GETCPOINTER(1, "CRegEntry") ;
			CRegistry *po = (CRegistry *) RING_API_GETCPOINTER(2, "CRegistry") ;
			if ( ( (pe) && pe->HasOwner() ) &&  ( (po) && (po->hKey) ) ) { pe->SetOwner(po); }
			else { RING_API_ERROR("Error : Bad entry handler or OwnerKey handler"); }
		} else {
			RING_API_ERROR("Error : Bad handlers, this function expects good entry handler and OwnerKey handler");
		}
	} else {
		if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) && RING_API_ISPOINTER(3) ) {
			CRegistry *ps = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
			CRegistry *pd = (CRegistry *) RING_API_GETCPOINTER(3, "CRegistry") ;
			if ( ( (ps) && (ps->hKey) ) &&  ( (pd) && (pd->hKey) ) ) { 
				ps[0][RING_API_GETSTRING(2)].SetOwner(pd); 
			} else { RING_API_ERROR("Error : Bad CRegistry source or destination Key handler"); }
		} else {
			RING_API_ERROR(RING_API_BADPARATYPE);
		}
	}
}

// void cregrename ( CRegistry keyhandler , string valuename , string newname)
void ring_vm_creg_cregrename( void *pPointer ) {
	if ( RING_API_PARACOUNT != 3 ) {
		RING_API_ERROR(RING_API_MISS3PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) && RING_API_ISSTRING(3) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) { 
			if (RING_API_GETSTRINGSIZE(2) > 0 && RING_API_GETSTRINGSIZE(3) > 0 ) { 
				if ( EntryExists(p, RING_API_GETSTRING(2)) ) {
					p[0][RING_API_GETSTRING(2)].SetName(RING_API_GETSTRING(3));
				} else { RING_API_ERROR("Error : Couldn't find the entry"); }
			} else { RING_API_ERROR("Error : Entry name could not be empty. Empty names reserved for default keys"); }
		} else { RING_API_ERROR("Error : Bad CRegistry Key handler"); }
	} else {
		RING_API_ERROR("Bad parameters entered this function expects ( OwnerKey , oldEntryName, newEntryName )");
	}
}

// void cregsetvalue ( CRegistry keyhandler , string valuename , string\int value )
void ring_vm_creg_cregsetvalue( void *pPointer ) {
	if ( RING_API_PARACOUNT != 3 ) {
		RING_API_ERROR(RING_API_MISS3PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) && ( RING_API_ISNUMBER(3) || RING_API_ISSTRING(3) )) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( RING_API_ISNUMBER(3) ) {
				if ( floor(RING_API_GETNUMBER(3)) == RING_API_GETNUMBER(3) ) {
					if ( RING_API_GETNUMBER(3) >= 0 && RING_API_GETNUMBER(3) <= 4294967295 ) {
						p[0][RING_API_GETSTRING(2)] = (DWORD) RING_API_GETNUMBER(3);
					} else {
						p[0][RING_API_GETSTRING(2)] = RING_API_GETNUMBER(3);
					}
				} else {
					p[0][RING_API_GETSTRING(2)] = RING_API_GETNUMBER(3);
				}
			} else p[0][RING_API_GETSTRING(2)] = RING_API_GETSTRING(3);
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// string creggetvalue ( CRegistry keyhandler , string valuename )
void ring_vm_creg_creggetvalue( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( p[0][RING_API_GETSTRING(2)].IsDWORD() ) {
				RING_API_RETNUMBER(p[0][RING_API_GETSTRING(2)]);
			} else if ( p[0][RING_API_GETSTRING(2)].IsString() ) {
				RING_API_RETSTRING(p[0][RING_API_GETSTRING(2)]);
			} else if ( p[0][RING_API_GETSTRING(2)].IsExpandSZ() ) {
				RING_API_RETSTRING((LPTSTR) p[0][RING_API_GETSTRING(2)]);
			} else {
				RING_API_ERROR("Error : This function can return DWORD and REG_SZ values only");
			}
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");
	} else {
		RING_API_ERROR("Error : this function expects key handler and entry name");
	}
}

// void cregdelete ( CRegistry keyhandler , string valuename )
void ring_vm_creg_cregdelete( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			p[0][RING_API_GETSTRING(2)].Delete();
		} else { RING_API_ERROR("Error : Bad CRegistry Key handler"); }
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// void cregsetmulti ( cpointer , string valuename , string value )
void ring_vm_creg_cregsetmulti( void *pPointer ) {
	if ( RING_API_PARACOUNT != 3 ) {
		RING_API_ERROR(RING_API_MISS3PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) && RING_API_ISSTRING(3) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && ( p->hKey ) ) {
			p[0][RING_API_GETSTRING(2)].SetMulti(RING_API_GETSTRING(3), RING_API_GETSTRINGSIZE(3) + 2 ); 
		} else RING_API_ERROR("Error : Bad CRegistry Key handler"); 
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// void cregmultiremoveat ( CRegistry keyhandler , string valuename , int index )
void ring_vm_creg_cregmultiremoveat( void *pPointer ) {
	if ( RING_API_PARACOUNT != 3 ) {
		RING_API_ERROR(RING_API_MISS3PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) && RING_API_ISNUMBER(3) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( EntryExists(p, RING_API_GETSTRING(2)) && p[0][RING_API_GETSTRING(2)].IsMultiString() ) {
				if ( RING_API_GETNUMBER(3) > 0 && RING_API_GETNUMBER(3) < p[0][RING_API_GETSTRING(2)].MultiCount() +1 ) {
					p[0][RING_API_GETSTRING(2)].MultiRemoveAt((int) RING_API_GETNUMBER(3) -1); 
				} else RING_API_ERROR("Error : invalid index of this MultiString"); 
			} else RING_API_ERROR("Error : Not found any MultiString entry with this name!!"); 
		} else RING_API_ERROR("Error : Bad CRegistry Key handler"); 
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// void cregmultisetat ( CRegistry keyhandler , string valuename , int index , string value)
void ring_vm_creg_cregmultisetat( void *pPointer ) {
	if ( RING_API_PARACOUNT != 4 ) {
		RING_API_ERROR(RING_API_MISS4PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) && RING_API_ISNUMBER(3) && RING_API_ISSTRING(4) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( EntryExists(p, RING_API_GETSTRING(2)) && p[0][RING_API_GETSTRING(2)].IsMultiString() ) {
				if ( RING_API_GETNUMBER(3) > 0 && RING_API_GETNUMBER(3) < p[0][RING_API_GETSTRING(2)].MultiCount() +2 ) {
					p[0][RING_API_GETSTRING(2)].MultiSetAt((int) RING_API_GETNUMBER(3) -1 , RING_API_GETSTRING(4));
				} else RING_API_ERROR("Error : invalid index of this MultiString"); 
			} else RING_API_ERROR("Error : Not found any MultiString entry with this name!!"); 
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");  
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// void cregmultiadd ( CRegistry keyhandler , string valuename , string value)
void ring_vm_creg_cregmultiadd( void *pPointer ) {
	if ( RING_API_PARACOUNT != 3 ) {
		RING_API_ERROR(RING_API_MISS3PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) && RING_API_ISSTRING(3) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( EntryExists(p, RING_API_GETSTRING(2)) && p[0][RING_API_GETSTRING(2)].IsMultiString() ) {
				p[0][RING_API_GETSTRING(2)].MultiAdd(RING_API_GETSTRING(3)); 
			} else RING_API_ERROR("Error : Not found any MultiString entry with this name!!"); 
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");  
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// string cregmultigetat ( CRegistry keyhandler , string valuename , int index )
void ring_vm_creg_cregmultigetat( void *pPointer ) {
	if ( RING_API_PARACOUNT != 3 ) {
		RING_API_ERROR(RING_API_MISS3PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) && RING_API_ISNUMBER(3) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( EntryExists(p, RING_API_GETSTRING(2)) && p[0][RING_API_GETSTRING(2)].IsMultiString() ) {
				if ( RING_API_GETNUMBER(3) > 0 && RING_API_GETNUMBER(3) < p[0][RING_API_GETSTRING(2)].MultiCount() +1 ) {
					RING_API_RETSTRING(p[0][RING_API_GETSTRING(2)].MultiGetAt((int) RING_API_GETNUMBER(3) -1)); 
				} else RING_API_ERROR("Error : invalid index of this MultiString"); 
			} else RING_API_ERROR("Error : Not found any MultiString entry with this name!!"); 
		} else RING_API_ERROR("Error : Bad CRegistry Key handler"); 
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// int cregmulticount ( CRegistry keyhandler , string valuename )
void ring_vm_creg_cregmulticount( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( EntryExists(p, RING_API_GETSTRING(2)) && p[0][RING_API_GETSTRING(2)].IsMultiString() ) {
				RING_API_RETNUMBER(p[0][RING_API_GETSTRING(2)].MultiCount());
			} else RING_API_ERROR("Error : Not found any MultiString entry with this name!!"); 
		} else RING_API_ERROR("Error : Bad CRegistry Key handler"); 
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// void cregmulticlear ( cpointer , string valuename )
void ring_vm_creg_cregmulticlear( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( EntryExists(p, RING_API_GETSTRING(2)) && p[0][RING_API_GETSTRING(2)].IsMultiString() ) {
				p[0][RING_API_GETSTRING(2)].MultiClear();
			} else RING_API_ERROR("Error : Not found any MultiString entry with this name!!"); 
		} else RING_API_ERROR("Error : Bad CRegistry Key handler"); 
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// string creggetexpandsz( CRegistry keyhandler , string valuename )
void ring_vm_creg_creggetexpandsz( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( EntryExists(p, RING_API_GETSTRING(2)) && p[0][RING_API_GETSTRING(2)].IsExpandSZ() ) {
				RING_API_RETSTRING(p[0][RING_API_GETSTRING(2)].GetExpandSZ());
			} else RING_API_ERROR("Error : Not found any REG_EXPAND_SZ entry with this name!!"); 
		} else RING_API_ERROR("Error : Bad CRegistry Key handler"); 
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// void cregsetexpandsz( CRegistry keyhandler , string valuename , string value )
void ring_vm_creg_cregsetexpandsz( void *pPointer ) {
	if ( RING_API_PARACOUNT != 3 ) {
		RING_API_ERROR(RING_API_MISS3PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) && RING_API_ISSTRING(3) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			DWORD lResult = p[0][RING_API_GETSTRING(2)].SetExpandSZ(RING_API_GETSTRING(3));
			if ( lResult != ERROR_SUCCESS ) {
				TCHAR msgBuf[200];
				RING_API_ERROR(GetErrorMsg(lResult, msgBuf, 200));
			}
		} else RING_API_ERROR("Error : Bad CRegistry Key handler"); 
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// boolean cregisstring ( CRegistry keyhandler , string valuename )
void ring_vm_creg_cregisstring( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			RING_API_RETNUMBER(p[0][RING_API_GETSTRING(2)].IsString());
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// boolean cregisdword ( CRegistry keyhandler , string valuename )
void ring_vm_creg_cregisdword( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			RING_API_RETNUMBER(p[0][RING_API_GETSTRING(2)].IsDWORD());
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// boolean cregismultistring ( CRegistry keyhandler , string valuename )
void ring_vm_creg_cregismultistring( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			RING_API_RETNUMBER(p[0][RING_API_GETSTRING(2)].IsMultiString());
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// boolean cregisbinary ( CRegistry keyhandler , string valuename )
void ring_vm_creg_cregisbinary( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			RING_API_RETNUMBER(p[0][RING_API_GETSTRING(2)].IsBinary());
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// boolean cregisexpandsz ( CRegistry keyhandler , string valuename )
void ring_vm_creg_cregisexpandsz( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			RING_API_RETNUMBER(p[0][RING_API_GETSTRING(2)].IsExpandSZ());
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// boolean cregexists ( CRegistry keyhandler , string valuename )
void ring_vm_creg_cregexists( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			DWORD lResult= p[0][RING_API_GETSTRING(2)].Exists();
			switch (lResult) {
				case ERROR_SUCCESS:
					RING_API_RETNUMBER(1);
					break;
				case ERROR_FILE_NOT_FOUND:
					RING_API_RETNUMBER(0);
					break;
				default:
					TCHAR msgBuf[200];
					RING_API_ERROR(GetErrorMsg(lResult, msgBuf, 200));
			}
			return ;
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}

// int cregtype ( CRegistry keyhandler , string valuename )
void ring_vm_creg_cregtype( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			DWORD lResult= p[0][RING_API_GETSTRING(2)].Type();
			if ( lResult < 12 ) {
				RING_API_RETNUMBER(lResult);
			} else {
				TCHAR msgBuf[200];
				RING_API_ERROR(GetErrorMsg(lResult - 12, msgBuf, 200));
			}
			return ;
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}



BOOL EntryExists(CRegistry* key, LPTSTR entry) {
	DWORD lResult= key[0][entry].Exists();
			switch (lResult) {
				case ERROR_SUCCESS:
					return true;
					break;
				case ERROR_FILE_NOT_FOUND:
					return false;
					break;
				default:
					TCHAR msgBuf[200];
					printf("%s\n", GetErrorMsg(lResult, msgBuf, 200));
					return false;
			}
}

LPTSTR GetFormattedMessage(LONG ErrId){
    LPTSTR pBuffer = NULL;
    FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                  NULL, 
                  ErrId,
				  // if next para set to zero the msg will be according to system language
                  MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US),
                  (LPTSTR)&pBuffer, 
                  0, 
                  NULL);
    return pBuffer;
}

LPTSTR GetErrorMsg(LONG ErrorId , LPTSTR pMsg, size_t pMsgsize){
    LPTSTR pBuffer = NULL;
	pBuffer = GetFormattedMessage(ErrorId);
    if (pBuffer)
    {
		sprintf_s(pMsg, pMsgsize, "Error ID (%d) : %s", ErrorId, pBuffer);
		LocalFree(pBuffer);
     }
    else
    {
		sprintf_s(pMsg, pMsgsize, "Format message failed with : %d", GetLastError());
    } 
	return pMsg;
}




/* 

============================================================================================

					THIS IS THE GARBAGE PART OF THIS EXTENSION ^_^

============================================================================================



------------------------------------------------------------------------
Functions Names : CRegGetMulti, CRegMultiLength

There job : Get value, and the whole length of MultiString values

Cause of deactivation : There're some problems arose when trying to deal with them remotely from RING
						Because we can not deal with all string length including null terminates so that
						they become useless. 
						Insteed we have some other fucntions that deal with each member of MultiString 
						entries perfectly. 

Idea for reactivation : should replce null termination into another character so that we can port them
						to RING easly then when returned put them in their places
						


-------------------------------------------------------------------------
-------------------------------- THE CODE -------------------------------
-------------------------------------------------------------------------



// string creggetmulti ( cpointer , string valuename )
void ring_vm_creg_creggetmulti( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( RING_API_GETSTRINGSIZE(2) > 0 ) {
				RING_API_RETSTRING(p[0][RING_API_GETSTRING(2)].GetMulti());
			} else RING_API_ERROR("Error : The default entry is not a MultiString"); 
		} else RING_API_ERROR("Error : Bad CRegistry Key handler");  
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}


// int cregmultilength ( cpointer , string valuename )
void ring_vm_creg_cregmultilength( void *pPointer ) {
	if ( RING_API_PARACOUNT != 2 ) {
		RING_API_ERROR(RING_API_MISS2PARA);
		return ;
	}
	if ( RING_API_ISPOINTER(1) && RING_API_ISSTRING(2) ) {
		CRegistry *p = (CRegistry *) RING_API_GETCPOINTER(1, "CRegistry") ;
		if ( (p) && (p->hKey) ) {
			if ( RING_API_GETSTRINGSIZE(2) > 0 ) {
				RING_API_RETNUMBER(p[0][RING_API_GETSTRING(2)].MultiLength());
			} else RING_API_ERROR("Error : The default entry is not a MultiString"); 
		} else RING_API_ERROR("Error : Bad CRegistry Key handler"); 
	} else {
		RING_API_ERROR(RING_API_BADPARATYPE);
	}
}
-------------------------------------------------------------------------
-------------------------------------------------------------------------



-------------------------------------------------------------------------
Functions Name : isnum         #  locally used function  #

There job : Check whether the passed string is a number or not

Cause of deactivation : Not need for it after updating CRegistry Class to deal well with double values 

Idea for reactivation : ---
						

-------------------------------------------------------------------------
-------------------------------- THE CODE -------------------------------
-------------------------------------------------------------------------


unsigned char isnum(LPCSTR str) {
	bool n = true;
	for (int i=0;i< strlen(str);i++) {
		if ( (isdigit(str[i])) || (str[i] == '.' &&  n == true)) {
			if (str[i] == '.') n = false;
		} else return 0;
	}
	return 1;
}

*/


}
