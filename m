Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1683C6B026B
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:48:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v67so415939194pfv.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:48:32 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id s2si26767244pfj.297.2016.09.13.02.48.11
        for <linux-mm@kvack.org>;
        Tue, 13 Sep 2016 02:48:12 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 08/15] lockdep: Make crossrelease use save_stack_trace_fast()
Date: Tue, 13 Sep 2016 18:45:07 +0900
Message-Id: <1473759914-17003-9-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
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
