Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 375AB6B1BF5
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:57:47 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 67so70126732qkj.18
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:57:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i5si1227992qtd.227.2018.11.19.10.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:57:46 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 15/17] kernfs: Mark kernfs_open_node_lock as terminal lock
Date: Mon, 19 Nov 2018 13:55:24 -0500
Message-Id: <1542653726-5655-16-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

By making kernfs_open_node_lock a terminal spinlock, it reduces the
lockdep overhead when this lock is used.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 fs/kernfs/file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/kernfs/file.c b/fs/kernfs/file.c
index dbf5bc2..a86fe22 100644
--- a/fs/kernfs/file.c
+++ b/fs/kernfs/file.c
@@ -29,7 +29,7 @@
  * kernfs_open_file.  kernfs_open_files are chained at
  * kernfs_open_node->files, which is protected by kernfs_open_file_mutex.
  */
-static DEFINE_SPINLOCK(kernfs_open_node_lock);
+static DEFINE_TERMINAL_SPINLOCK(kernfs_open_node_lock);
 static DEFINE_MUTEX(kernfs_open_file_mutex);
 
 struct kernfs_open_node {
-- 
1.8.3.1
