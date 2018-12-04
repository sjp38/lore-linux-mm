Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 423876B7112
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 17:42:33 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id c14so13526388pls.21
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 14:42:33 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id 205si18271426pfa.199.2018.12.04.14.42.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 14:42:32 -0800 (PST)
Date: Tue, 4 Dec 2018 14:42:27 -0800
From: "tip-bot for Paul E. McKenney" <tipbot@zytor.com>
Message-ID: <tip-ba180314253947f2a6057e21a0f92b5c314454b1@git.kernel.org>
Reply-To: linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@kernel.org,
        linux-mm@kvack.org, paulmck@linux.ibm.com, hpa@zytor.com,
        akpm@linux-foundation.org, rostedt@goodmis.org
Subject: [tip:core/rcu] main: Replace rcu_barrier_sched() with rcu_barrier()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: tglx@linutronix.de, akpm@linux-foundation.org, hpa@zytor.com, paulmck@linux.ibm.com, linux-mm@kvack.org, mingo@kernel.org, rostedt@goodmis.org

Commit-ID:  ba180314253947f2a6057e21a0f92b5c314454b1
Gitweb:     https://git.kernel.org/tip/ba180314253947f2a6057e21a0f92b5c314454b1
Author:     Paul E. McKenney <paulmck@linux.ibm.com>
AuthorDate: Tue, 6 Nov 2018 18:58:01 -0800
Committer:  Paul E. McKenney <paulmck@linux.ibm.com>
CommitDate: Tue, 27 Nov 2018 09:21:41 -0800

main: Replace rcu_barrier_sched() with rcu_barrier()

Now that all RCU flavors have been consolidated, rcu_barrier_sched()
is but a synonym for rcu_barrier().  This commit therefore replaces
the former with the latter.

Signed-off-by: Paul E. McKenney <paulmck@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Steven Rostedt (VMware)" <rostedt@goodmis.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: <linux-mm@kvack.org>
---
 init/main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/init/main.c b/init/main.c
index ee147103ba1b..a45486330243 100644
--- a/init/main.c
+++ b/init/main.c
@@ -1046,12 +1046,12 @@ static void mark_readonly(void)
 {
 	if (rodata_enabled) {
 		/*
-		 * load_module() results in W+X mappings, which are cleaned up
-		 * with call_rcu_sched().  Let's make sure that queued work is
+		 * load_module() results in W+X mappings, which are cleaned
+		 * up with call_rcu().  Let's make sure that queued work is
 		 * flushed so that we don't hit false positives looking for
 		 * insecure pages which are W+X.
 		 */
-		rcu_barrier_sched();
+		rcu_barrier();
 		mark_rodata_ro();
 		rodata_test();
 	} else
