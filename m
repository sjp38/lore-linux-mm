Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7568C6B1BF4
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:57:45 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so70181133qka.7
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:57:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 34si3350844qvq.116.2018.11.19.10.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:57:44 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 14/17] dma-debug: Mark free_entries_lock as terminal
Date: Mon, 19 Nov 2018 13:55:23 -0500
Message-Id: <1542653726-5655-15-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

By making free_entries_lock a terminal spinlock, it reduces the lockdep
overhead when this lock is used.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/dma/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/dma/debug.c b/kernel/dma/debug.c
index 231ca46..f891688 100644
--- a/kernel/dma/debug.c
+++ b/kernel/dma/debug.c
@@ -106,7 +106,7 @@ struct hash_bucket {
 /* List of pre-allocated dma_debug_entry's */
 static LIST_HEAD(free_entries);
 /* Lock for the list above */
-static DEFINE_SPINLOCK(free_entries_lock);
+static DEFINE_TERMINAL_SPINLOCK(free_entries_lock);
 
 /* Global disable flag - will be set in case of an error */
 static bool global_disable __read_mostly;
-- 
1.8.3.1
