Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2079F6B0315
	for <linux-mm@kvack.org>; Wed, 24 May 2017 05:00:52 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u187so107771352pgb.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 02:00:52 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id b26si24126622pgn.219.2017.05.24.02.00.50
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 02:00:51 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v7 09/16] lockdep: Fix incorrect condition to print bug msgs for MAX_LOCKDEP_CHAIN_HLOCKS
Date: Wed, 24 May 2017 17:59:42 +0900
Message-Id: <1495616389-29772-10-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

Bug messages and stack dump for MAX_LOCKDEP_CHAIN_HLOCKS should be
printed only once.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index a14d2ca..8173c81 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2267,7 +2267,7 @@ static inline int add_chain_cache(struct task_struct *curr,
 	 * Important for check_no_collision().
 	 */
 	if (unlikely(nr_chain_hlocks > MAX_LOCKDEP_CHAIN_HLOCKS)) {
-		if (debug_locks_off_graph_unlock())
+		if (!debug_locks_off_graph_unlock())
 			return 0;
 
 		print_lockdep_off("BUG: MAX_LOCKDEP_CHAIN_HLOCKS too low!");
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
