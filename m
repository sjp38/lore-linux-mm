Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 140E76B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 14:44:22 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c8-v6so3637648edt.23
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 11:44:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c17si2017017edn.441.2018.11.11.11.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Nov 2018 11:44:20 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wABJi99E168543
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 14:44:18 -0500
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2npdfdhh9p-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 14:44:18 -0500
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 11 Nov 2018 19:44:18 -0000
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
Subject: [PATCH tip/core/rcu 19/41] main: Replace rcu_barrier_sched() with rcu_barrier()
Date: Sun, 11 Nov 2018 11:43:48 -0800
In-Reply-To: <20181111194104.GA4787@linux.ibm.com>
References: <20181111194104.GA4787@linux.ibm.com>
Message-Id: <20181111194410.6368-19-paulmck@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, joel@joelfernandes.org, "Paul E. McKenney" <paulmck@linux.ibm.com>, linux-mm@kvack.org

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
-- 
2.17.1
