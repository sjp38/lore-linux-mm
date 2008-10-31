Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9VHpRHQ011904
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:51:27 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9VHqBPK141916
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:52:11 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9VHqBMm025300
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:52:11 -0600
Date: Fri, 31 Oct 2008 10:52:03 -0700
From: Gary Hade <garyhade@us.ibm.com>
Subject: [PATCH] [RESEND] x86: add memory hotremove config option
Message-ID: <20081031175203.GA7483@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

I am resending this patch (originally posted by Badari Pulavarty)
since the "mm: cleanup to make remove_memory() arch-neutral" patch
on which it depends is now in Linus' 2.6.git tree (commit
71088785c6bc68fddb450063d57b1bd1c78e0ea1) and 2.6.28-rc2.

Thanks,
Gary

---
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

Index: linux-2.6.28-rc2/arch/x86/Kconfig
===================================================================
--- linux-2.6.28-rc2.orig/arch/x86/Kconfig	2008-10-31 10:34:14.000000000 -0700
+++ linux-2.6.28-rc2/arch/x86/Kconfig	2008-10-31 10:34:27.000000000 -0700
@@ -1486,6 +1486,10 @@
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
