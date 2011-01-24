Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A3A026B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 07:27:05 -0500 (EST)
Received: by pzk27 with SMTP id 27so875229pzk.14
        for <linux-mm@kvack.org>; Mon, 24 Jan 2011 04:27:03 -0800 (PST)
Date: Mon, 24 Jan 2011 21:08:13 +0900
From: Yoichi Yuasa <yuasa@linux-mips.org>
Subject: [PATCH] fix build error when CONFIG_SWAP is not set
Message-Id: <20110124210813.ba743fc5.yuasa@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: yuasa@linux-mips.org, linux-mips <linux-mips@linux-mips.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In file included from
linux-2.6/arch/mips/include/asm/tlb.h:21,
                 from mm/pgtable-generic.c:9:
include/asm-generic/tlb.h: In function 'tlb_flush_mmu':
include/asm-generic/tlb.h:76: error: implicit declaration of function
'release_pages'
include/asm-generic/tlb.h: In function 'tlb_remove_page':
include/asm-generic/tlb.h:105: error: implicit declaration of function
'page_cache_release'
make[1]: *** [mm/pgtable-generic.o] Error 1

Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>
---
 include/linux/swap.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4d55932..92c1be6 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -8,6 +8,7 @@
 #include <linux/memcontrol.h>
 #include <linux/sched.h>
 #include <linux/node.h>
+#include <linux/pagemap.h>
 
 #include <asm/atomic.h>
 #include <asm/page.h>
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
