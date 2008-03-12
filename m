Date: Wed, 12 Mar 2008 15:16:54 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] mm/oom_kill: fix kernel-doc
Message-Id: <20080312151654.858181f4.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Fix kernel-doc notation in oom_kill.c.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/oom_kill.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

--- lin2625-rc5-mmotm.orig/mm/oom_kill.c
+++ lin2625-rc5-mmotm/mm/oom_kill.c
@@ -37,6 +37,7 @@ static DEFINE_SPINLOCK(zone_scan_mutex);
  * badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
  * @uptime: current uptime in seconds
+ * @mem: target memory controller
  *
  * The formula used is relatively simple and documented inline in the
  * function. The main rationale is that we want to select a good task
@@ -266,6 +267,9 @@ static struct task_struct *select_bad_pr
 }
 
 /**
+ * dump_tasks - dump current memory state of all system tasks
+ * @mem: target memory controller
+ *
  * Dumps the current memory state of all system tasks, excluding kernel threads.
  * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
  * score, and name.
@@ -300,7 +304,7 @@ static void dump_tasks(const struct mem_
 	} while_each_thread(g, p);
 }
 
-/**
+/*
  * Send SIGKILL to the selected  process irrespective of  CAP_SYS_RAW_IO
  * flag though it's unlikely that  we select a process with CAP_SYS_RAW_IO
  * set.
@@ -505,6 +509,9 @@ void clear_zonelist_oom(struct zonelist 
 
 /**
  * out_of_memory - kill the "best" process when we run out of memory
+ * @zonelist: zonelist pointer
+ * @gfp_mask: memory allocation flags
+ * @order: amount of memory being requested as a power of 2
  *
  * If we run out of memory, we have the choice between either
  * killing a random task (bad), letting the system crash (worse)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
