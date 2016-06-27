// PPageExtension.cpp : implementation file
//
#include "stdafx.h"
#include "mplayerc.h"
#include "MainFrm.h"
#include "PPageOutput.h"
#include "moreuuids.h"
#include "PPageExtension.h"
#include <psapi.h>
#include "PPageSheet.h"


// CPPageExtension dialog
IMPLEMENT_DYNAMIC(CPPageExtension, CPPageBase)
CPPageExtension::CPPageExtension()
	: CPPageBase(CPPageExtension::IDD, CPPageExtension::IDD)
{

}

CPPageExtension::~CPPageExtension()
{
}


void CPPageExtension::DoDataExchange(CDataExchange* pDX)
{
	__super::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CPPageExtension, CPPageBase)
	//ON_WM_HSCROLL()
	//ON_BN_CLICKED(IDC_RESET, OnBnClickedReset)
	//ON_BN_CLICKED(IDC_RESET_SETTINGS, OnResetSettings)
	//ON_BN_CLICKED(IDC_EXPORT_SETTINGS, OnExportSettings)
	//ON_BN_CLICKED(IDC_EXPORT_KEYS, OnExportKeys)
	//ON_UPDATE_COMMAND_UI(IDC_EDIT1, OnUpdateDelayEditBox)
	//ON_UPDATE_COMMAND_UI(IDC_SPIN1, OnUpdateDelayEditBox)
	//ON_UPDATE_COMMAND_UI(IDC_STATIC5, OnUpdateDelayEditBox)
	//ON_UPDATE_COMMAND_UI(IDC_STATIC6, OnUpdateDelayEditBox)

END_MESSAGE_MAP()
