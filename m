Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A7AF06B026D
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y71so17217386pgd.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:36 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l4si32043043plb.98.2016.12.08.21.16.35
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:35 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 08/15] lockdep: Make crossrelease use save_stack_trace_fast()
Date: Fri,  9 Dec 2016 14:12:04 +0900
Message-Id: <1481260331-360-9-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

Currently crossrelease feature uses save_stack_trace() to save
backtrace. However, it has much overhead. So this patch makes it
use save_stack_trace_norm() instead, which has smaller overhead.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 2c8b2c1..fbd07ee 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4768,7 +4768,7 @@ static void add_plock(struct held_lock *hlock, unsigned int prev_gen_id,
 		plock->trace.max_entries = MAX_PLOCK_TRACE_ENTRIES;
 		plock->trace.entries = plock->trace_entries;
 		plock->trace.skip = 3;
-		save_stack_trace(&plock->trace);
+		save_stack_trace_fast(&plock->trace);
 	}
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
