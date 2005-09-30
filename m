Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8UFPZTI023359
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:25:35 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8UFPZon089734
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:25:35 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8UFPYLY020110
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:25:34 -0400
Subject: [PATCH 2/2] memhotplug testing: enable sparsemem on flat systems
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 30 Sep 2005 08:25:32 -0700
References: <20050930152531.3FDB46D3@kernel.beaverton.ibm.com>
In-Reply-To: <20050930152531.3FDB46D3@kernel.beaverton.ibm.com>
Message-Id: <20050930152532.9FDF34BD@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: magnus@valinux.co.jp
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

---

 memhotplug-dave/arch/i386/Kconfig |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletion(-)

diff -puN arch/i386/Kconfig~C2-enable-i386-sparsemem-debug arch/i386/Kconfig
--- memhotplug/arch/i386/Kconfig~C2-enable-i386-sparsemem-debug	2005-09-29 12:40:42.000000000 -0700
+++ memhotplug-dave/arch/i386/Kconfig	2005-09-29 12:41:22.000000000 -0700
@@ -799,9 +799,23 @@ config ARCH_DISCONTIGMEM_DEFAULT
 	def_bool y
 	depends on NUMA
 
+config X86_SPARSEMEM_DEBUG_NONUMA
+	bool "Enable SPARSEMEM on flat systems (debugging only)"
+	depends on !NUMA && EXPERIMENTAL
+	select SPARSEMEM_STATIC
+	select SPARSEMEM_MANUAL
+
+config ARCH_MEMORY_PROBE
+	def_bool y
+	depends on X86_SPARSEMEM_DEBUG_NONUMA
+
+config ARCH_SPARSEMEM_DEFAULT
+	def_bool y
+	depends on X86_SPARSEMEM_DEBUG_NONUMA
+
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
-	depends on NUMA
+	depends on NUMA || X86_SPARSEMEM_DEBUG_NONUMA
 
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
