Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 73441620026
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:20:54 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 73/96] c/r: correctly restore pgid
Date: Wed, 17 Mar 2010 12:09:01 -0400
Message-Id: <1268842164-5590-74-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-73-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-38-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-39-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-40-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-41-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-42-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-43-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-44-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-45-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-46-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-47-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-48-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-49-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-50-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-51-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-52-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-53-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-54-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-55-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-56-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-57-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-58-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-59-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-60-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-61-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-62-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-63-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-64-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-65-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-66-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-67-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-68-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-69-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-70-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-71-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-72-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-73-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

The main challenge with restoring the pgid of tasks is that the
original "owner" (the process with that pid) might have exited
already. I call these "ghost" pgids. 'mktree' does create these
processes, but they then exit without participating in the restart.

To solve this, this patch introduces a RESTART_GHOST flag, used for
"ghost" owners that are created only to pass their pgid to other
tasks. ('mktree' now makes them call restart(2) instead of exiting).

When a "ghost" task calls restart(2), it will be placed on a wait
queue until the restart completes and then exit. This guarantees that
the pgid that it owns remains available for all (regular) restarting
tasks for when they need it.

Regular tasks perform the restart as before, except that they also
now restore their old pgrp, which is guaranteed to exist.

Changelog [v19-rc1]:
  - Simplify logic of tracking restarting tasks
  - Debug final process-tree state on restart
  - [Matt Helsley] Add cpp definitions for enums
  - Self-restart to tolerate missing pgid
Changelog [v3]:
  - Fix leak of ckpt_ctx when restoring "ghost" tasks
Changelog [v2]:
  - Call change_pid() only if new pgrp differs from current one
Changelog [v1]:
  - Verify that pgid owner is a thread-group-leader.
  - Handle the case of pgid/sid == 0 using root's parent pid-ns

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/process.c             |  101 ++++++++++++++++++++++++++++++++++++++
 checkpoint/restart.c             |   59 +++++++++++++++++++---
 checkpoint/sys.c                 |    3 +-
 include/linux/checkpoint.h       |   11 +++-
 include/linux/checkpoint_hdr.h   |    3 +
 include/linux/checkpoint_types.h |    7 ++-
 6 files changed, 171 insertions(+), 13 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index c5e9357..e0ef795 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -24,6 +24,57 @@
 #include <linux/syscalls.h>
 
 
+pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid)
+{
+	return pid ? pid_nr_ns(pid, ctx->root_nsproxy->pid_ns) : CKPT_PID_NULL;
+}
+
+/* must be called with tasklist_lock or rcu_read_lock() held */
+struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid)
+{
+	struct task_struct *p;
+	struct pid *pgrp;
+
+	if (pgid == 0) {
+		/*
+		 * At checkpoint the pgid owner lived in an ancestor
+		 * pid-ns. The best we can do (sanely and safely) is
+		 * to examine the parent of this restart's root: if in
+		 * a distinct pid-ns, use its pgrp; otherwise fail.
+		 */
+		p = ctx->root_task->real_parent;
+		if (p->nsproxy->pid_ns == current->nsproxy->pid_ns)
+			return NULL;
+		pgrp = task_pgrp(p);
+	} else {
+		/*
+		 * Find the owner process of this pgid (it must exist
+		 * if pgrp exists). It must be a thread group leader.
+		 */
+		pgrp = find_vpid(pgid);
+		p = pid_task(pgrp, PIDTYPE_PID);
+		if (!p || !thread_group_leader(p))
+			return NULL;
+		/*
+		 * The pgrp must "belong" to our restart tree (compare
+		 * p->checkpoint_ctx to ours). This prevents malicious
+		 * input from (guessing and) using unrelated pgrps. If
+		 * the owner is dead, then it doesn't have a context,
+		 * so instead compare against its (real) parent's.
+		 */
+		if (p->exit_state == EXIT_ZOMBIE)
+			p = p->real_parent;
+		if (p->checkpoint_ctx != ctx)
+			return NULL;
+	}
+
+	if (task_session(current) != task_session(p))
+		return NULL;
+
+	return pgrp;
+}
+
+
 #ifdef CONFIG_FUTEX
 static void save_task_robust_futex_list(struct ckpt_hdr_task *h,
 					struct task_struct *t)
@@ -738,6 +789,53 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_task_pgid(struct ckpt_ctx *ctx)
+{
+	struct task_struct *task = current;
+	struct pid *pgrp;
+	pid_t pgid;
+	int ret;
+
+	/*
+	 * We enforce the following restrictions on restoring pgrp:
+	 *  1) Only thread group leaders restore pgrp
+	 *  2) Session leader cannot change own pgrp
+	 *  3) Owner of pgrp must belong to same restart tree
+	 *  4) Must have same session as other tasks in same pgrp
+	 *  5) Change must pass setpgid security callback
+	 *
+	 * TODO - check if we need additional restrictions ?
+	 */
+
+	if (!thread_group_leader(task))  /* (1) */
+		return 0;
+
+	pgid = ctx->pids_arr[ctx->active_pid].vpgid;
+
+	if (pgid == task_pgrp_vnr(task))  /* nothing to do */
+		return 0;
+
+	if (task->signal->leader)  /* (2) */
+		return -EINVAL;
+
+	ret = -EINVAL;
+
+	write_lock_irq(&tasklist_lock);
+	pgrp = _ckpt_find_pgrp(ctx, pgid);  /* (3) and (4) */
+	if (pgrp && task_pgrp(task) != pgrp) {
+		ret = security_task_setpgid(task, pgid);  /* (5) */
+		if (!ret)
+			change_pid(task, PIDTYPE_PGID, pgrp);
+	}
+	write_unlock_irq(&tasklist_lock);
+
+	/* self-restart: be tolerant if old pgid isn't found */
+	if (ctx->uflags & RESTART_TASKSELF)
+		ret = 0;
+
+	return ret;
+}
+
 /* prepare the task for restore */
 int pre_restore_task(void)
 {
@@ -783,6 +881,9 @@ int restore_task(struct ckpt_ctx *ctx)
 	if (ret)
 		goto out;
 
+	ret = restore_task_pgid(ctx);
+	if (ret < 0)
+		goto out;
 	ret = restore_thread(ctx);
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 863ee87..42885be 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -735,6 +735,7 @@ void restore_notify_error(struct ckpt_ctx *ctx)
 {
 	complete(&ctx->complete);
 	wake_up_all(&ctx->waitq);
+	wake_up_all(&ctx->ghostq);
 }
 
 static inline struct ckpt_ctx *get_task_ctx(struct task_struct *task)
@@ -810,6 +811,9 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 			ckpt_err(ctx, -ESRCH, "task %d not found\n", pid);
 			return -ESRCH;
 		}
+	} else {
+		/* wake up ghosts tasks so that they can terminate */
+		wake_up_all(&ctx->ghostq);
 	}
 
 	return 0;
@@ -867,6 +871,38 @@ static struct ckpt_ctx *wait_checkpoint_ctx(void)
 	return ctx;
 }
 
+static int do_ghost_task(void)
+{
+	struct ckpt_ctx *ctx;
+	int ret;
+
+	ctx = wait_checkpoint_ctx();
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = restore_debug_task(ctx, RESTART_DBG_GHOST);
+	if (ret < 0)
+		goto out;
+
+	current->flags |= PF_RESTARTING;
+	restore_debug_running(ctx);
+
+	ret = wait_event_interruptible(ctx->ghostq,
+				       all_tasks_activated(ctx) ||
+				       ckpt_test_error(ctx));
+ out:
+	restore_debug_error(ctx, ret);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "ghost restart failed\n");
+
+	current->exit_signal = -1;
+	restore_debug_exit(ctx);
+	ckpt_ctx_put(ctx);
+	do_exit(0);
+
+	/* NOT REACHED */
+}
+
 /*
  * Ensure that all members of a thread group are in sys_restart before
  * restoring any of them. Otherwise, restore may modify shared state
@@ -946,10 +982,15 @@ static int do_restore_task(void)
 		goto out;
 	}
 
+	ret = restore_activate_next(ctx);
+	if (ret < 0)
+		goto out;
+
 	/*
 	 * zombie: we're done here; do_exit() will notice the @ctx on
-	 * our current->checkpoint_ctx (and our PF_RESTARTING) - it
-	 * will call restore_activate_next() and release the @ctx.
+	 * our current->checkpoint_ctx (and our PF_RESTARTING), will
+	 * call restore_task_done() and release the @ctx. This ensures
+	 * that we only report done after we really become zombie.
 	 */
 	if (zombie) {
 		restore_debug_exit(ctx);
@@ -1031,8 +1072,11 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 	if (nr_pids < 0)
 		return nr_pids;
 
-	/* fail unless number of processes matches */
-	if (nr_pids != ctx->nr_pids)
+	/*
+	 * Actual tasks count may exceed ctx->nr_pids due of 'dead'
+	 * tasks used as place-holders for PGIDs, but not fall short.
+	 */
+	if (nr_pids < ctx->nr_pids)
 		return -ESRCH;
 
 	atomic_set(&ctx->nr_total, nr_pids);
@@ -1278,12 +1322,14 @@ static long restore_retval(void)
 	return syscall_get_return_value(current, regs);
 }
 
-long do_restart(struct ckpt_ctx *ctx, pid_t pid)
+long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
 {
 	long ret;
 
 	if (ctx)
 		ret = do_restore_coord(ctx, pid);
+	else if (flags & RESTART_GHOST)
+		ret = do_ghost_task();
 	else
 		ret = do_restore_task();
 
@@ -1331,8 +1377,7 @@ void exit_checkpoint(struct task_struct *tsk)
 	/* restarting zombies will activate next task in restart */
 	if (tsk->flags & PF_RESTARTING) {
 		BUG_ON(ctx->active_pid == -1);
-		if (restore_activate_next(ctx) < 0)
-			pr_warning("c/r: [%d] failed zombie exit\n", tsk->pid);
+		restore_task_done(ctx);
 	}
 
 	ckpt_ctx_put(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index b7cb59e..02b12a3 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -257,6 +257,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
 	init_waitqueue_head(&ctx->waitq);
+	init_waitqueue_head(&ctx->ghostq);
 	init_completion(&ctx->complete);
 
 	init_completion(&ctx->errno_sync);
@@ -664,7 +665,7 @@ long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd)
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
-	ret = do_restart(ctx, pid);
+	ret = do_restart(ctx, pid, flags);
 
 	ckpt_ctx_put(ctx);
 	return ret;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 2fe2a9d..220388d 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -18,6 +18,7 @@
 /* restart user flags */
 #define RESTART_TASKSELF	0x1
 #define RESTART_FROZEN		0x2
+#define RESTART_GHOST		0x4
 
 /* misc user visible */
 #define CHECKPOINT_FD_NONE	-1
@@ -52,7 +53,10 @@ extern long do_sys_restart(pid_t pid, int fd,
 
 /* ckpt_ctx: uflags */
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
-#define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN)
+#define RESTART_USER_FLAGS  \
+	(RESTART_TASKSELF | \
+	 RESTART_FROZEN | \
+	 RESTART_GHOST)
 
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
@@ -90,6 +94,9 @@ extern char *ckpt_fill_fname(struct path *path, struct path *root,
 extern int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page);
 extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
 
+/* pids */
+extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
+
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
@@ -145,7 +152,7 @@ extern struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
 
 extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
-extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
+extern long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags);
 
 /* task */
 extern int ckpt_activate_next(struct ckpt_ctx *ctx);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index a09b5e5..f0a41ec 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -268,6 +268,9 @@ struct ckpt_pids {
 	__s32 vsid;
 } __attribute__((aligned(8)));
 
+/* pids */
+#define CKPT_PID_NULL  -1
+
 /* task data */
 struct ckpt_hdr_task {
 	struct ckpt_hdr h;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index e03f147..6edcaea 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -73,10 +73,11 @@ struct ckpt_ctx {
 	/* [multi-process restart] */
 	struct ckpt_pids *pids_arr;	/* array of all pids [restart] */
 	int nr_pids;			/* size of pids array */
-	atomic_t nr_total;		/* total tasks count */
+	atomic_t nr_total;		/* total tasks count (with ghosts) */
 	int active_pid;			/* (next) position in pids array */
-	struct completion complete;	/* container root and other tasks on */
-	wait_queue_head_t waitq;	/* start, end, and restart ordering */
+	struct completion complete;	/* completion for container root */
+	wait_queue_head_t waitq;	/* waitqueue for restarting tasks */
+	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 
 	struct ckpt_stats stats;	/* statistics */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
