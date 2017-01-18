Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA0A6B0261
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:17:53 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id t6so16155505pgt.6
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:17:53 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id d2si202379pln.274.2017.01.18.05.17.52
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 05:17:52 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 02/13] lockdep: Fix wrong condition to print bug msgs for MAX_LOCKDEP_CHAIN_HLOCKS
Date: Wed, 18 Jan 2017 22:17:28 +0900
Message-Id: <1484745459-2055-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

Bug messages and stack dump for MAX_LOCKDEP_CHAIN_HLOCKS should be
printed only at the first time.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index f37156f..a143eb4 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2166,7 +2166,7 @@ static inline int add_chain_cache(struct task_struct *curr,
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
