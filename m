Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 859FA8E000B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id l9so13984252plt.7
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Message-Id: <20181226133352.133164898@intel.com>
Date: Wed, 26 Dec 2018 21:15:04 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 18/21] kvm-ept-idle: enable module
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0007-kvm-ept-idle-enable-module.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/kvm/Kconfig  |   11 +++++++++++
 arch/x86/kvm/Makefile |    4 ++++
 2 files changed, 15 insertions(+)

--- linux.orig/arch/x86/kvm/Kconfig	2018-12-23 20:09:04.628882396 +0800
+++ linux/arch/x86/kvm/Kconfig	2018-12-23 20:09:04.628882396 +0800
@@ -96,6 +96,17 @@ config KVM_MMU_AUDIT
 	 This option adds a R/W kVM module parameter 'mmu_audit', which allows
 	 auditing of KVM MMU events at runtime.
 
+config KVM_EPT_IDLE
+	tristate "KVM EPT idle page tracking"
+	depends on KVM_INTEL
+	depends on PROC_PAGE_MONITOR
+	---help---
+	  Provides support for walking EPT to get the A bits on Intel
+	  processors equipped with the VT extensions.
+
+	  To compile this as a module, choose M here: the module
+	  will be called kvm-ept-idle.
+
 # OK, it's a little counter-intuitive to do this, but it puts it neatly under
 # the virtualization menu.
 source drivers/vhost/Kconfig
--- linux.orig/arch/x86/kvm/Makefile	2018-12-23 20:09:04.628882396 +0800
+++ linux/arch/x86/kvm/Makefile	2018-12-23 20:09:04.628882396 +0800
@@ -19,6 +19,10 @@ kvm-y			+= x86.o mmu.o emulate.o i8259.o
 kvm-intel-y		+= vmx.o pmu_intel.o
 kvm-amd-y		+= svm.o pmu_amd.o
 
+kvm-ept-idle-y		+= ept_idle.o
+
 obj-$(CONFIG_KVM)	+= kvm.o
 obj-$(CONFIG_KVM_INTEL)	+= kvm-intel.o
 obj-$(CONFIG_KVM_AMD)	+= kvm-amd.o
+
+obj-$(CONFIG_KVM_EPT_IDLE)	+= kvm-ept-idle.o
