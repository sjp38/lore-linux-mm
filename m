Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 193846B5FDB
	for <linux-mm@kvack.org>; Sat,  1 Sep 2018 22:21:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id t23-v6so9165353pfe.20
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 19:21:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d32-v6si13682201pla.93.2018.09.01.19.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Sep 2018 19:21:10 -0700 (PDT)
Message-Id: <20180901124811.703808090@intel.com>
Date: Sat, 01 Sep 2018 19:28:23 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH 5/5] [PATCH 5/5] kvm-ept-idle: enable module
References: <20180901112818.126790961@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0005-kvm-ept-idle-enable-module.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fengguang Wu <fengguang.wu@intel.com>, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/kvm/Kconfig  | 11 +++++++++++
 arch/x86/kvm/Makefile |  4 ++++
 2 files changed, 15 insertions(+)

diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
index 1bbec387d289..4c6dec47fac6 100644
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
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
diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
index dc4f2fdf5e57..5cad0590205d 100644
--- a/arch/x86/kvm/Makefile
+++ b/arch/x86/kvm/Makefile
@@ -19,6 +19,10 @@ kvm-y			+= x86.o mmu.o emulate.o i8259.o irq.o lapic.o \
 kvm-intel-y		+= vmx.o pmu_intel.o
 kvm-amd-y		+= svm.o pmu_amd.o
 
+kvm-ept-idle-y		+= ept_idle.o
+
 obj-$(CONFIG_KVM)	+= kvm.o
 obj-$(CONFIG_KVM_INTEL)	+= kvm-intel.o
 obj-$(CONFIG_KVM_AMD)	+= kvm-amd.o
+
+obj-$(CONFIG_KVM_EPT_IDLE)	+= kvm-ept-idle.o
-- 
2.15.0
