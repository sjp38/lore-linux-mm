Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 73BA06B0268
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:32:21 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g4so38900330ith.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:32:21 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id m67si2590399ioo.203.2016.07.07.02.32.16
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:32:17 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 12/13] lockdep: Make crossrelease use save_stack_trace_norm() instead
Date: Thu,  7 Jul 2016 18:30:02 +0900
Message-Id: <1467883803-29132-13-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently crossrelease feature uses save_stack_trace() to save
backtrace. However it has much overhead. So this patch makes it
use save_stack_trace_norm() instead, which has smaller overhead.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index ea19108..fd7865b 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4690,7 +4690,7 @@ static void add_plock(struct held_lock *hlock, unsigned int prev_gen_id,
 		plock->trace.max_entries = MAX_PLOCK_TRACE_ENTRIES;
 		plock->trace.entries = plock->trace_entries;
 		plock->trace.skip = 3;
-		save_stack_trace(&plock->trace);
+		save_stack_trace_norm(&plock->trace);
 	}
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
