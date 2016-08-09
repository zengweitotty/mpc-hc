#pragma once

#include "PPageBase.h"
#include "unknwn.h"
#include "vidcap.h"
#include <ksproxy.h>        // For IKsControl  
#include <Ks.h>
#include "ksmedia.h"
#include "atlbase.h "
#include <initguid.h>
#include "windows.h"
// CPPageExtension dialog

DEFINE_GUID(GUID_EXTENSION_UNIT_DESCRIPTOR, 0xC9D7FCD2, 0xAA56, 0x4764, 0xA2, 0xF4, 0xDE, 0x26, 0x7A, 0xC7, 0xCA, 0x88);
#define XU_ISP_LED_TORCH_MODE	(1)

class CPPageExtension : public CPPageBase
{
	DECLARE_DYNAMIC(CPPageExtension)

public:
	CPPageExtension();   // standard constructor
	virtual ~CPPageExtension();
	enum { IDD = IDD_PPAGEEXTENSION };
	DWORD	dwExtensionNode;
	IKsTopologyInfo *pKsTopologyInfo;
	GUID  pNodeType;	//获取到的NodeType结构体
	BYTE* pbPropertyValue;
	KSP_NODE ExtensionProp;
    IUnknown *pUnkOuter;
	int xuDevNode = 0;
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()
	afx_msg void OnLedFlash(CCmdUI* pCmdUI);
public:
	void CPPageExtension::OnBnClickedLangradio123(UINT nID);
private:
	bool ledFlashEnabled;
};
