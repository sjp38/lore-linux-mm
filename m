From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 15/15] HWPOISON: FOR TESTING: Enable memory failure code unconditionally
Date: Sat, 20 Jun 2009 11:16:23 +0800
Message-ID: <20090620031626.763180363@intel.com>
References: <20090620031608.624240019@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1FE916B0055
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 23:19:29 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-enable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "Wu, Fengguang" <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

From: Andi Kleen <ak@linux.intel.com>

Normally the memory-failure.c code is enabled by the architecture, but
for easier testing independent of architecture changes enable it unconditionally.

This should not be merged into mainline.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/Kconfig |    2 ++
 1 file changed, 2 insertions(+)

--- sound-2.6.orig/mm/Kconfig
+++ sound-2.6/mm/Kconfig
@@ -241,6 +241,8 @@ config KSM
 
 config MEMORY_FAILURE
 	bool
+	default y
+	depends on MMU
 
 config HWPOISON_INJECT
 	tristate "Hardware poison pages injector"

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
