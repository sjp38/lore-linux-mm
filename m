Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4RGSSw5004758
	for <linux-mm@kvack.org>; Fri, 27 May 2005 12:28:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4RGSORS090434
	for <linux-mm@kvack.org>; Fri, 27 May 2005 12:28:27 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4RGSOui030830
	for <linux-mm@kvack.org>; Fri, 27 May 2005 12:28:24 -0400
Subject: [PATCH] i386 sparsemem: undefined early_pfn_to_nid when !NUMA
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 27 May 2005 09:28:22 -0700
Message-Id: <20050527162822.EBE1D09F@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On i386, early_pfn_to_nid() is only defined when discontig.c
is compiled in.  The current dependency doesn't reflect this,
probably because the default i386 config doesn't allow for
SPARSEMEM without NUMA.

But, we'll need SPARSEMEM && !NUMA for memory hotplug, and I
do this for testing anyway.

Andy, please forward on if you concur.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/Kconfig |    1 +
 1 files changed, 1 insertion(+)

diff -puN arch/i386/Kconfig~generify-early_pfn_to_nid-fix arch/i386/Kconfig
--- memhotplug/arch/i386/Kconfig~generify-early_pfn_to_nid-fix	2005-05-27 09:23:07.000000000 -0700
+++ memhotplug-dave/arch/i386/Kconfig	2005-05-27 09:23:07.000000000 -0700
@@ -837,6 +837,7 @@ source "mm/Kconfig"
 config HAVE_ARCH_EARLY_PFN_TO_NID
 	bool
 	default y
+	depends on NUMA
 
 config HIGHPTE
 	bool "Allocate 3rd-level pagetables from highmem"
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
