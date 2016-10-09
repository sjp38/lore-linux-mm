Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 188216B0069
	for <linux-mm@kvack.org>; Sun,  9 Oct 2016 11:18:29 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k64so104791516itb.5
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 08:18:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 68si31174275iol.11.2016.10.09.08.18.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 09 Oct 2016 08:18:28 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm: remove extra newline from allocation stall warning
Date: Mon, 10 Oct 2016 00:16:59 +0900
Message-Id: <1476026219-7974-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
too long") by error embedded "\n" in the format string, resulting in
strange output.

[  722.876655] kworker/0:1: page alloction stalls for 160001ms, order:0
[  722.876656] , mode:0x2400000(GFP_NOIO)
[  722.876657] CPU: 0 PID: 6966 Comm: kworker/0:1 Not tainted 4.8.0+ #69

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ca423cc..828ee76 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3653,7 +3653,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
 		warn_alloc(gfp_mask,
-			"page alloction stalls for %ums, order:%u\n",
+			"page alloction stalls for %ums, order:%u",
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
