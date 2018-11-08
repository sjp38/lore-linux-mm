Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id F20DD6B0650
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:35:36 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 92so41308336qkx.19
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:35:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k65-v6si45035qkd.2.2018.11.08.12.35.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:35:36 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 04/12] printk: Make logbuf_lock a terminal lock
Date: Thu,  8 Nov 2018 15:34:20 -0500
Message-Id: <1541709268-3766-5-git-send-email-longman@redhat.com>
In-Reply-To: <1541709268-3766-1-git-send-email-longman@redhat.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

By making logbuf_lock a terminal lock, it reduces the performance
overhead when lockdep is enabled.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/printk/printk.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 1b2a029..6b63fda 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -367,7 +367,7 @@ __packed __aligned(4)
  * within the scheduler's rq lock. It must be released before calling
  * console_unlock() or anything else that might wake up a process.
  */
-DEFINE_RAW_SPINLOCK(logbuf_lock);
+DEFINE_RAW_TERMINAL_SPINLOCK(logbuf_lock);
 
 /*
  * Helper macros to lock/unlock logbuf_lock and switch between
-- 
1.8.3.1
