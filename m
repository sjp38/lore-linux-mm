Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC9B6B1BF0
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:57:39 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n68so70140530qkn.8
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:57:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w8si27002418qvn.137.2018.11.19.10.57.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:57:38 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 10/17] lib/stackdepot: Make depot_lock a terminal spinlock
Date: Mon, 19 Nov 2018 13:55:19 -0500
Message-Id: <1542653726-5655-11-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

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
