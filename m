Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m88Luj8K007236
	for <linux-mm@kvack.org>; Mon, 8 Sep 2008 17:56:45 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m88LuinX199346
	for <linux-mm@kvack.org>; Mon, 8 Sep 2008 17:56:44 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m88Lui4h013721
	for <linux-mm@kvack.org>; Mon, 8 Sep 2008 17:56:44 -0400
Subject: [PATCH] x86: add memory hotremove config option
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20080905181754.GA14258@elte.hu>
References: <20080905172132.GA11692@us.ibm.com>
	 <20080905174449.GC27395@elte.hu> <1220638478.25932.20.camel@badari-desktop>
	 <20080905181754.GA14258@elte.hu>
Content-Type: text/plain
Date: Mon, 08 Sep 2008 14:56:58 -0700
Message-Id: <1220911018.25932.61.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

Cleaned up patch with out remove_memory(). 
Depends on make remove_memory() arch neutral patch.

Thanks,
Badari

Add memory hotremove config option to x86

Memory hotremove functionality can currently be configured into
the ia64, powerpc, and s390 kernels.  This patch makes it possible
to configure the memory hotremove functionality into the x86
kernel as well. 

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
Signed-off-by: Gary Hade <garyhade@us.ibm.com>
---
 arch/x86/Kconfig |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-2.6.27-rc5/arch/x86/Kconfig
===================================================================
--- linux-2.6.27-rc5.orig/arch/x86/Kconfig	2008-09-08 12:36:06.000000000 -0700
+++ linux-2.6.27-rc5/arch/x86/Kconfig	2008-09-08 12:45:30.000000000 -0700
@@ -1384,6 +1384,10 @@ config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 	depends on X86_64 || (X86_32 && HIGHMEM)
 
+config ARCH_ENABLE_MEMORY_HOTREMOVE
+	def_bool y
+	depends on MEMORY_HOTPLUG
+
 config HAVE_ARCH_EARLY_PFN_TO_NID
 	def_bool X86_64
 	depends on NUMA


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
