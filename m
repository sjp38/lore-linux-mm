Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5IMXUmZ011288
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 18:33:30 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5IMXU8I128426
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 16:33:30 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5IMXU73031316
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 16:33:30 -0600
Message-Id: <20080618223329.335415658@linux.vnet.ibm.com>
References: <20080618223254.966080905@linux.vnet.ibm.com>
Date: Wed, 18 Jun 2008 17:32:58 -0500
From: shaggy@linux.vnet.ibm.com
Subject: [patch 4/6] powerpc: Add SAO Feature bit to the cputable
Content-Disposition: inline; filename=SAO_feature_bit.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mackerras <paulus@au1.ibm.com>, linux-mm@kvack.org, Linuxppc-dev@ozlabs.org, Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch applies on top of the patches posted today to linuxppc-dev by
Michael Neuling and Joel Schopp.

Signed-off-by: Joel Schopp <jschopp@austin.ibm.com>
Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>

Index: linux-2.6.26-rc5/include/asm-powerpc/cputable.h
===================================================================
--- linux-2.6.26-rc5.orig/include/asm-powerpc/cputable.h
+++ linux-2.6.26-rc5/include/asm-powerpc/cputable.h
@@ -183,6 +183,7 @@ extern void do_feature_fixups(unsigned l
 #define CPU_FTR_1T_SEGMENT		LONG_ASM_CONST(0x0004000000000000)
 #define CPU_FTR_NO_SLBIE_B		LONG_ASM_CONST(0x0008000000000000)
 #define CPU_FTR_VSX			LONG_ASM_CONST(0x0010000000000000)
+#define CPU_FTR_SAO			LONG_ASM_CONST(0x0020000000000000)
 
 #ifndef __ASSEMBLY__
 
@@ -395,7 +396,7 @@ extern void do_feature_fixups(unsigned l
 	    CPU_FTR_MMCRA | CPU_FTR_SMT | \
 	    CPU_FTR_COHERENT_ICACHE | CPU_FTR_LOCKLESS_TLBIE | \
 	    CPU_FTR_PURR | CPU_FTR_SPURR | CPU_FTR_REAL_LE | \
-	    CPU_FTR_DSCR)
+	    CPU_FTR_DSCR | CPU_FTR_SAO)
 #define CPU_FTRS_CELL	(CPU_FTR_USE_TB | \
 	    CPU_FTR_HPTE_TABLE | CPU_FTR_PPCAS_ARCH_V2 | CPU_FTR_CTRL | \
 	    CPU_FTR_ALTIVEC_COMP | CPU_FTR_MMCRA | CPU_FTR_SMT | \

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
