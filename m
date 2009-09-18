Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 97FE56B00B2
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:22:10 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8ICIENd013381
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 06:18:14 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8ICMBi4160954
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 06:22:11 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8ICMAhU003760
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 06:22:11 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 6/7] Add MAP_HUGETLB flag to parisc mman.h
Date: Fri, 18 Sep 2009 06:21:52 -0600
Message-Id: <309744fd80915ce157aa90dbb807101f61b1f334.1253272709.git.ebmunson@us.ibm.com>
In-Reply-To: <d8e315b04749f73765e61eb7e4cbbaed2b946dfd.1253272709.git.ebmunson@us.ibm.com>
References: <cover.1253272709.git.ebmunson@us.ibm.com>
 <653aa659fd7970f7428f4eb41fa10693064e4daf.1253272709.git.ebmunson@us.ibm.com>
 <08251014d2eb30e9016bab16404133f5c13beacf.1253272709.git.ebmunson@us.ibm.com>
 <462331ca14e2ed47b20b047342e73b92559e1c5b.1253272709.git.ebmunson@us.ibm.com>
 <be5687cbd44413416009466357c1ded6418cc163.1253272709.git.ebmunson@us.ibm.com>
 <d8e315b04749f73765e61eb7e4cbbaed2b946dfd.1253272709.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1253272709.git.ebmunson@us.ibm.com>
References: <cover.1253272709.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: rdunlap@xenotime.net, michael@ellerman.id.au, ralf@linux-mips.org, wli@holomorphy.com, mel@csn.ul.ie, dhowells@redhat.com, arnd@arndb.de, fengguang.wu@intel.com, shuber2@gmail.com, hugh.dickins@tiscali.co.uk, zohar@us.ibm.com, hugh@veritas.com, mtk.manpages@gmail.com, chris@zankel.net, linux-man@vger.kernel.org, linux-doc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Even though parisc does not support huge pages this flag needs to
be defined here to keep the compiler happy.  This is because
parisc does not make use of mman-common.h, so any flags defined
there and used in common code need to be added to parisc's mman.h
manually.

Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
 arch/parisc/include/asm/mman.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/arch/parisc/include/asm/mman.h b/arch/parisc/include/asm/mman.h
index defe752..7563d0c 100644
--- a/arch/parisc/include/asm/mman.h
+++ b/arch/parisc/include/asm/mman.h
@@ -58,4 +58,11 @@
 #define MAP_FILE	0
 #define MAP_VARIABLE	0
 
+/*
+ * This flag is included even though huge pages are not supported because
+ * the flag is defined in mman-common.h and used in common vm code but
+ * mman-common.h is not included here
+ */
+#define MAP_HUGETLB	0x080000
+
 #endif /* __PARISC_MMAN_H__ */
-- 
1.6.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
