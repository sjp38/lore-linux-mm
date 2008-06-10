Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5AM1QW2019250
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:26 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5AM1Jn9155636
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:19 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5AM1JYF015673
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:19 -0400
Date: Tue, 10 Jun 2008 18:01:18 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20080610220118.10257.31835.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
References: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 04/06] powerpc: Define CPU_FTR_SAO
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev list <Linuxppc-dev@ozlabs.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is just a placeholder to make the patchset compilable.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 include/asm-powerpc/cputable.h |    1 +
 1 file changed, 1 insertion(+)

diff -Nurp linux003/include/asm-powerpc/cputable.h linux004/include/asm-powerpc/cputable.h
--- linux003/include/asm-powerpc/cputable.h	2008-04-16 21:49:44.000000000 -0500
+++ linux004/include/asm-powerpc/cputable.h	2008-06-10 16:48:59.000000000 -0500
@@ -180,6 +180,7 @@ extern void do_feature_fixups(unsigned l
 #define CPU_FTR_DSCR			LONG_ASM_CONST(0x0002000000000000)
 #define CPU_FTR_1T_SEGMENT		LONG_ASM_CONST(0x0004000000000000)
 #define CPU_FTR_NO_SLBIE_B		LONG_ASM_CONST(0x0008000000000000)
+#define CPU_FTR_SAO			LONG_ASM_CONST(0x0010000000000000)
 
 #ifndef __ASSEMBLY__
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
