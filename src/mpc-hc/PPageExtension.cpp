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
	, ledFlashEnabled(0)
{
}

CPPageExtension::~CPPageExtension()
{
}
 


void CPPageExtension::DoDataExchange(CDataExchange* pDX)
{
	__super::DoDataExchange(pDX);
}

BOOL CPPageExtension::OnInitDialog()
{
	__super::OnInitDialog();
	HRESULT hr = 0;

	const CAppSettings& s = AfxGetAppSettings();

	CMainFrame* pFrame = ((CMainFrame*)GetParentFrame());
	if (!pFrame || !pFrame->m_pVidCap) {
		this->EnableWindow(0);
		return FALSE;
	}
	uint16_t i = 0;
	//query the interface IKsTopologyInfo
	hr = pFrame->m_pVidCap->QueryInterface(__uuidof(IKsTopologyInfo),
		(void **)&pKsTopologyInfo);
	if (!SUCCEEDED(hr))
	{
		//Error handle, this indicate that CX3-UVC board is not conenct to the host
		printf("Unable to obtain Get video input filter %x\n", hr);
		ledFlashEnabled = FALSE;
	}
	//poll the device nodes that regard to the interface pKsTopologyInfo
	pKsTopologyInfo->get_NumNodes(&dwExtensionNode);
	for (i = 0; i < dwExtensionNode; i++) {
		pKsTopologyInfo->get_NodeType(i, &pNodeType);
		//find the relevant CT unit device node
		//if (pNodeType == KSNODETYPE_VIDEO_CAMERA_TERMINAL){
		//find the relevant Extension unit in device node
		if (pNodeType == KSNODETYPE_DEV_SPECIFIC) {
			xuDevNode = i;	//record the device node number
			break;
		}
	}

	// pUnkOuter is the unknown associated with the base filter
	hr = pKsTopologyInfo->CreateNodeInstance(i,
		__uuidof(IUnknown), (VOID**)&pUnkOuter);
	if (hr != S_OK)
	{
		fprintf(stderr, "ERROR: Unable to Create pUnkOuter instance.\n");
		ledFlashEnabled = FALSE;
	}
	else {
		ledFlashEnabled = TRUE;
	}


	return TRUE;  // return TRUE unless you set the focus to a control
				  // EXCEPTION: OCX Property Pages should return FALSE
}

BEGIN_MESSAGE_MAP(CPPageExtension, CPPageBase)
	ON_CONTROL_RANGE(BN_CLICKED, IDC_RADIO8001, IDC_RADIO8003, OnBnClickedLangradio123)
	ON_UPDATE_COMMAND_UI(IDC_RADIO8001, OnLedFlash)
	ON_UPDATE_COMMAND_UI(IDC_RADIO8002, OnLedFlash)
	ON_UPDATE_COMMAND_UI(IDC_RADIO8003, OnLedFlash)
	ON_UPDATE_COMMAND_UI(IDC_STATIC8001, OnLedFlash)
	ON_UPDATE_COMMAND_UI(IDC_STATIC8002, OnLedFlash)
	ON_UPDATE_COMMAND_UI(IDC_SLIDER8001, OnLedFlash)
	
END_MESSAGE_MAP()
void CPPageExtension::OnBnClickedLangradio123(UINT nID)
{
	HRESULT hr = 0;

	//Set current Led torch mode
	ExtensionProp.Property.Set = GUID_EXTENSION_UNIT_DESCRIPTOR;
	ExtensionProp.Property.Id = XU_ISP_LED_TORCH_MODE;
	ExtensionProp.Property.Flags = KSPROPERTY_TYPE_SET | KSPROPERTY_TYPE_TOPOLOGY;
	ExtensionProp.NodeId = xuDevNode;
	ULONG ulBytesReturned = 0;
	BYTE pValue[1];


	switch (nID) {
	case IDC_RADIO8001:
		//handle the OFF radio click event
		printf("Click the OFF radio button");
		pValue[0] = 0x0;
		break;
	case IDC_RADIO8002:
		//handle the AUTO radio click event
		printf("Click the AUTO radio button");
		pValue[0] = 0x1;
		break;
	case IDC_RADIO8003:
		//handle the MANUAL radio click event
		printf("Click the MANUAL radio button");
		pValue[0] = 0x2;
		break;
	default:
		//could not reach here
		return;
		break;
	}
	IKsControl *pKsControl;
	hr = pUnkOuter->QueryInterface(__uuidof(IKsControl), (void **)&pKsControl);
	if (!SUCCEEDED(hr))
	{
		printf("Unable to obtain IKsControl %x\n", hr);
	}
	hr = pKsControl->KsProperty(
		(PKSPROPERTY)&ExtensionProp,
		sizeof(ExtensionProp),
		(PVOID)pValue,
		1,
		&ulBytesReturned);
	
	if (!SUCCEEDED(hr))
	{
		printf("Unable to obtain extension unit %x\n", hr);
	}
	UpdateData(FALSE);
}

void CPPageExtension::OnLedFlash(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(this->ledFlashEnabled);
}