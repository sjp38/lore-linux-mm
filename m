Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A10756B1BE9
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:57:01 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d196so71046734qkb.6
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:57:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g24si6557809qvb.43.2018.11.19.10.57.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:57:00 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 06/17] debugobjects: Mark pool_lock as a terminal lock
Date: Mon, 19 Nov 2018 13:55:15 -0500
Message-Id: <1542653726-5655-7-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

By marking the internal pool_lock as a terminal lock, lockdep will be
able to skip full validation to improve locking performance.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 lib/debugobjects.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/debugobjects.c b/lib/debugobjects.c
index 70935ed..403dd95 100644
--- a/lib/debugobjects.c
+++ b/lib/debugobjects.c
@@ -39,7 +39,7 @@ struct debug_bucket {
 
 static struct debug_obj		obj_static_pool[ODEBUG_POOL_SIZE] __initdata;
 
-static DEFINE_RAW_SPINLOCK(pool_lock);
+static DEFINE_RAW_TERMINAL_SPINLOCK(pool_lock);
 
 static HLIST_HEAD(obj_pool);
 static HLIST_HEAD(obj_to_free);
-- 
1.8.3.1
