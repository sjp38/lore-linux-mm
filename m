Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 98FD182F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 07:03:24 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so4171665igb.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 04:03:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z10si20713846igl.19.2015.10.28.04.03.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 Oct 2015 04:03:23 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm: Remove refresh_cpu_vm_stats() definition for !SMP kernel.
Date: Wed, 28 Oct 2015 20:01:59 +0900
Message-Id: <1446030119-9651-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

refresh_cpu_vm_stats(int cpu) is no longer referenced by !SMP kernel
since Linux 3.12.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 82e7db7..95d2130 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -269,7 +269,6 @@ static inline void __dec_zone_page_state(struct page *page,
 
 #define set_pgdat_percpu_threshold(pgdat, callback) { }
 
-static inline void refresh_cpu_vm_stats(int cpu) { }
 static inline void refresh_zone_stat_thresholds(void) { }
 static inline void cpu_vm_stats_fold(int cpu) { }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
