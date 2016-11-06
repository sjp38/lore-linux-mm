Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A6C5F6B025E
	for <linux-mm@kvack.org>; Sun,  6 Nov 2016 00:51:04 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u15so216538072oie.6
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 21:51:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 37si3115179otr.255.2016.11.05.21.51.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 05 Nov 2016 21:51:03 -0700 (PDT)
Subject: Re: [PATCH] mm: remove extra newline from allocation stall warning
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1476026219-7974-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20161010072123.GA20420@dhcp22.suse.cz>
	<20161012145230.GO17128@dhcp22.suse.cz>
In-Reply-To: <20161012145230.GO17128@dhcp22.suse.cz>
Message-Id: <201611061350.FBF21879.OMFQOLtJFOVHSF@I-love.SAKURA.ne.jp>
Date: Sun, 6 Nov 2016 13:50:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, linux-mm@kvack.org

I noticed a typo and folded into this patch.
Andrew, please replace mm-remove-extra-newline-from-allocation-stall-warning.patch .
----------
>From 1f6caf79022c20f47e4cee0a4d2d5114907e2714 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 6 Nov 2016 13:41:51 +0900
Subject: [PATCH v2] mm: remove extra newline from allocation stall warning

63f53dea0c9866e9 ("mm: warn about allocations which stall for too long")
by error embedded "\n" in the format string, resulting in strange output.

[  722.876655] kworker/0:1: page alloction stalls for 160001ms, order:0
[  722.876656] , mode:0x2400000(GFP_NOIO)
[  722.876657] CPU: 0 PID: 6966 Comm: kworker/0:1 Not tainted 4.8.0+ #69

Link: http://lkml.kernel.org/r/1476026219-7974-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 072d791..6de9440 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3658,7 +3658,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
 		warn_alloc(gfp_mask,
-			"page alloction stalls for %ums, order:%u\n",
+			"page allocation stalls for %ums, order:%u",
 			jiffies_to_msecs(jiffies-alloc_start), order);
 		stall_timeout += 10 * HZ;
 	}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
