Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35CD56B1B88
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:56:53 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id j125so4413591qke.12
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:56:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v40si4418652qtv.322.2018.11.19.10.56.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:56:52 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 01/17] locking/lockdep: Remove version from lock_class structure
Date: Mon, 19 Nov 2018 13:55:10 -0500
Message-Id: <1542653726-5655-2-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

It turns out the version field in the lock_class structure isn't used
anywhere. Just remove it.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/lockdep.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 1fd82ff..c5335df 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -97,8 +97,6 @@ struct lock_class {
 	 * Generation counter, when doing certain classes of graph walking,
 	 * to ensure that we check one node only once:
 	 */
-	unsigned int			version;
-
 	int				name_version;
 	const char			*name;
 
-- 
1.8.3.1
