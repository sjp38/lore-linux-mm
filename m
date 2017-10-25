Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A053D6B025E
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 04:56:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a8so20472954pfc.6
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 01:56:32 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p5si1549676pgf.113.2017.10.25.01.56.30
        for <linux-mm@kvack.org>;
        Wed, 25 Oct 2017 01:56:31 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 3/9] completion: Change the prefix of lock name for completion variable
Date: Wed, 25 Oct 2017 17:55:59 +0900
Message-Id: <1508921765-15396-4-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
References: <1508921765-15396-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

CONFIG_LOCKDEP_COMPLETIONS uses "(complete)" as a prefix of lock name
for completion variable.

However, "complete" is a verb or adjective and lock symbol names
should be nouns. Use "(completion)" instead, for normal completions.

Suggested-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/completion.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/completion.h b/include/linux/completion.h
index cae5400..9121803 100644
--- a/include/linux/completion.h
+++ b/include/linux/completion.h
@@ -53,7 +53,7 @@ static inline void complete_release_commit(struct completion *x)
 do {									\
 	static struct lock_class_key __key;				\
 	lockdep_init_map_crosslock((struct lockdep_map *)&(x)->map,	\
-			"(complete)" #x,				\
+			"(completion)" #x,				\
 			&__key, 0);					\
 	__init_completion(x);						\
 } while (0)
@@ -67,7 +67,7 @@ static inline void complete_release_commit(struct completion *x) {}
 #ifdef CONFIG_LOCKDEP_COMPLETIONS
 #define COMPLETION_INITIALIZER(work) \
 	{ 0, __WAIT_QUEUE_HEAD_INITIALIZER((work).wait), \
-	STATIC_CROSS_LOCKDEP_MAP_INIT("(complete)" #work, &(work)) }
+	STATIC_CROSS_LOCKDEP_MAP_INIT("(completion)" #work, &(work)) }
 #else
 #define COMPLETION_INITIALIZER(work) \
 	{ 0, __WAIT_QUEUE_HEAD_INITIALIZER((work).wait) }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
