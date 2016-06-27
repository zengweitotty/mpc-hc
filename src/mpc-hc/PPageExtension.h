#pragma once

#include <afxcmn.h>
#include "PPageBase.h"

// CPPageExtension dialog

class CPPageExtension : public CPPageBase
{
	DECLARE_DYNAMIC(CPPageExtension)

public:
	CPPageExtension();   // standard constructor
	virtual ~CPPageExtension();
	enum { IDD = IDD_PPAGEEXTENSION };
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()
};
