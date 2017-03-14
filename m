Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 575196B038B
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:26:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j190so337586pgc.4
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 01:26:21 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n12si14058977pfa.269.2017.03.14.01.26.18
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 01:26:19 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v6 08/15] lockdep: Fix incorrect condition to print bug msgs for MAX_LOCKDEP_CHAIN_HLOCKS
Date: Tue, 14 Mar 2017 17:18:55 +0900
Message-ID: <1489479542-27030-9-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

Bug messages and stack dump for MAX_LOCKDEP_CHAIN_HLOCKS should be
printed only once.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index c78dd9d..ef26725 100644
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
