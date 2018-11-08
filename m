Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id CDE116B065A
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:35:56 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id v70so40416497qka.17
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:35:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n14si4021085qvo.171.2018.11.08.12.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:35:56 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 09/12] lib/stackdepot: Make depot_lock a terminal spinlock
Date: Thu,  8 Nov 2018 15:34:25 -0500
Message-Id: <1541709268-3766-10-git-send-email-longman@redhat.com>
In-Reply-To: <1541709268-3766-1-git-send-email-longman@redhat.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

By defining depot_lock as a terminal spinlock, it reduces the
lockdep overhead when this lock is being used.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 lib/stackdepot.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index e513459..fb17888 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -78,7 +78,7 @@ struct stack_record {
 static int depot_index;
 static int next_slab_inited;
 static size_t depot_offset;
-static DEFINE_SPINLOCK(depot_lock);
+static DEFINE_TERMINAL_SPINLOCK(depot_lock);
 
 static bool init_stack_slab(void **prealloc)
 {
-- 
1.8.3.1
