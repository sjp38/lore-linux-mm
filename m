Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DAD356B0062
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:22:07 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8ICExFQ012774
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:14:59 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8ICMBpg255534
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:22:11 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8ICIxec000502
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:19:00 -0400
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 7/7] Add MAP_HUGETLB flag to mips mman.h
Date: Fri, 18 Sep 2009 06:21:53 -0600
Message-Id: <2cf4dc5ff484753493263c5aa3fdd21ca62aa9bf.1253272709.git.ebmunson@us.ibm.com>
In-Reply-To: <309744fd80915ce157aa90dbb807101f61b1f334.1253272709.git.ebmunson@us.ibm.com>
References: <cover.1253272709.git.ebmunson@us.ibm.com>
 <653aa659fd7970f7428f4eb41fa10693064e4daf.1253272709.git.ebmunson@us.ibm.com>
 <08251014d2eb30e9016bab16404133f5c13beacf.1253272709.git.ebmunson@us.ibm.com>
 <462331ca14e2ed47b20b047342e73b92559e1c5b.1253272709.git.ebmunson@us.ibm.com>
 <be5687cbd44413416009466357c1ded6418cc163.1253272709.git.ebmunson@us.ibm.com>
 <d8e315b04749f73765e61eb7e4cbbaed2b946dfd.1253272709.git.ebmunson@us.ibm.com>
 <309744fd80915ce157aa90dbb807101f61b1f334.1253272709.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1253272709.git.ebmunson@us.ibm.com>
References: <cover.1253272709.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: rdunlap@xenotime.net, michael@ellerman.id.au, ralf@linux-mips.org, wli@holomorphy.com, mel@csn.ul.ie, dhowells@redhat.com, arnd@arndb.de, fengguang.wu@intel.com, shuber2@gmail.com, hugh.dickins@tiscali.co.uk, zohar@us.ibm.com, hugh@veritas.com, mtk.manpages@gmail.com, chris@zankel.net, linux-man@vger.kernel.org, linux-doc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Even though mips does not support huge pages this flag needs to
be defined here to keep the compiler happy.  This is because
mips does not make use of mman-common.h, so any flags defined
there and used in common code need to be added to mips's mman.h
manually.

Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
 arch/mips/include/asm/mman.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/arch/mips/include/asm/mman.h b/arch/mips/include/asm/mman.h
index e4d6f1f..c4f29da 100644
--- a/arch/mips/include/asm/mman.h
+++ b/arch/mips/include/asm/mman.h
@@ -46,6 +46,12 @@
 #define MAP_LOCKED	0x8000		/* pages are locked */
 #define MAP_POPULATE	0x10000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x20000		/* do not block on IO */
+/*
+ * This flag is included even though huge pages are not supported because
+ * the flag is defined in mman-common.h and used in common vm code but
+ * mman-common.h is not included here
+ */
+#define MAP_HUGETLB	0x080000
 
 /*
  * Flags for msync
-- 
1.6.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
