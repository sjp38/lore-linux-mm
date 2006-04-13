From: Dave Peterson <dsp@llnl.gov>
Subject: [PATCH 1/2] mm: fix typos in comments in mm/oom_kill.c
Date: Thu, 13 Apr 2006 14:52:06 -0700
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604131452.06722.dsp@llnl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, riel@surriel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

This fixes a few typos in the comments in mm/oom_kill.c.

Signed-Off-By: David S. Peterson <dsp@llnl.gov>
---

Index: linux-2.6.17-rc1-oom/mm/oom_kill.c
===================================================================
--- linux-2.6.17-rc1-oom.orig/mm/oom_kill.c	2006-03-19 21:53:29.000000000 -0800
+++ linux-2.6.17-rc1-oom/mm/oom_kill.c	2006-04-13 14:25:16.000000000 -0700
@@ -25,7 +25,7 @@
 /* #define DEBUG */
 
 /**
- * oom_badness - calculate a numeric value for how bad this task has been
+ * badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
  * @uptime: current uptime in seconds
  *
@@ -190,7 +190,7 @@ static struct task_struct *select_bad_pr
 			continue;
 
 		/*
-		 * This is in the process of releasing memory so for wait it
+		 * This is in the process of releasing memory so wait for it
 		 * to finish before killing some other task by mistake.
 		 */
 		releasing = test_tsk_thread_flag(p, TIF_MEMDIE) ||
@@ -291,7 +291,7 @@ static struct mm_struct *oom_kill_proces
 }
 
 /**
- * oom_kill - kill the "best" process when we run out of memory
+ * out_of_memory - kill the "best" process when we run out of memory
  *
  * If we run out of memory, we have the choice between either
  * killing a random task (bad), letting the system crash (worse)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
