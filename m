Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 52AD8620026
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:19:04 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 68/96] c/r: [signal 1/4] blocked and template for shared signals
Date: Wed, 17 Mar 2010 12:08:56 -0400
Message-Id: <1268842164-5590-69-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-68-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

This patch adds checkpoint/restart of blocked signals mask
(t->blocked) and a template for shared signals (t->signal).

Because t->signal sharing is tied to threads, we ensure proper sharing
of t->signal (struct signal_struct) for threads only.

Access to t->signal is protected by locking t->sighand->lock.
Therefore, the usual checkpoint_obj() invoking the callback
checkpoint_signal(ctx, signal) is insufficient because the task
pointer is unavailable.

Instead, handling of t->signal sharing is explicit using helpers
like ckpt_obj_lookup_add(), ckpt_obj_fetch() and ckpt_obj_insert().
The actual state is saved (if needed) _after_ the task_objs data.

To prevent tasks from handling restored signals during restart,
set their mask to block all signals and only restore the original
mask at the very end (before the last sync point).

Introduce per-task pointer 'ckpt_data' to temporary store data
for restore actions that are deferred to the end (like restoring
the signal block mask).

Changelog [ckpt-v19]:
  - Use task->saves_sigmask and drop task->checkpoint_data
  - [Serge Hallyn] Handle saved_sigmask at checkpoint

Changelog [ckpt-v19-rc1]:
  - Defer restore of blocked signals mask during restart
  - [Matt Helsley] Add cpp definitions for enums

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Louis Rilling <Louis.Rilling@kerlabs.com>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 arch/s390/kernel/checkpoint.c  |    2 -
 arch/s390/kernel/signal.c      |    5 ++
 arch/x86/kernel/signal.c       |    5 ++
 checkpoint/objhash.c           |    7 +++
 checkpoint/process.c           |   71 +++++++++++++++++++++++++-
 checkpoint/restart.c           |   13 +++++
 checkpoint/signal.c            |  111 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h     |    8 +++
 include/linux/checkpoint_hdr.h |   16 ++++++
 include/linux/signal.h         |    3 +
 kernel/fork.c                  |    3 +
 11 files changed, 241 insertions(+), 3 deletions(-)

diff --git a/arch/s390/kernel/checkpoint.c b/arch/s390/kernel/checkpoint.c
index 79f0a2f..894bca3 100644
--- a/arch/s390/kernel/checkpoint.c
+++ b/arch/s390/kernel/checkpoint.c
@@ -203,8 +203,6 @@ int restore_thread(struct ckpt_ctx *ctx)
 	if (h->thread_info_flags & _TIF_SIG_RESTARTBLOCK)
 		set_thread_flag(TIF_SIG_RESTARTBLOCK);
 
-	/* will have to handle TIF_RESTORE_SIGMASK as well */
-
 	ckpt_hdr_put(ctx, h);
 
 	return 0;
diff --git a/arch/s390/kernel/signal.c b/arch/s390/kernel/signal.c
index 83425b1..41e03d3 100644
--- a/arch/s390/kernel/signal.c
+++ b/arch/s390/kernel/signal.c
@@ -540,6 +540,11 @@ void do_signal(struct pt_regs *regs)
 	}
 }
 
+int task_has_saved_sigmask(struct task_struct *task)
+{
+	return !!(test_tsk_thread_flag(task, TIF_RESTORE_SIGMASK));
+}
+
 void do_notify_resume(struct pt_regs *regs)
 {
 	clear_thread_flag(TIF_NOTIFY_RESUME);
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 4fd173c..eb63d59 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -831,6 +831,11 @@ static void do_signal(struct pt_regs *regs)
 	}
 }
 
+int task_has_saved_sigmask(struct task_struct *task)
+{
+	return !!(task_thread_info(task)->status & TS_RESTORE_SIGMASK);
+}
+
 /*
  * notification of userspace execution resumption
  * - triggered by the TIF_WORK_MASK flags
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 858613e..ea2f063 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -289,6 +289,13 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_sighand,
 		.restore = restore_sighand,
 	},
+	/* signal object */
+	{
+		.obj_name = "SIGNAL",
+		.obj_type = CKPT_OBJ_SIGNAL,
+		.ref_drop = obj_no_drop,
+		.ref_grab = obj_no_grab,
+	},
 	/* ns object */
 	{
 		.obj_name = "NSPROXY",
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 71eb9a5..c5e9357 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -182,7 +182,8 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	int files_objref;
 	int mm_objref;
 	int sighand_objref;
-	int ret;
+	int signal_objref;
+	int first, ret;
 
 	/*
 	 * Shared objects may have dependencies among them: task->mm
@@ -227,14 +228,38 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 		return sighand_objref;
 	}
 
+	/*
+	 * Handle t->signal differently because the checkpoint method
+	 * for t->signal needs access to owning task_struct to access
+	 * t->sighand (to lock/unlock). First explicitly determine if
+	 * need to save, and only below invoke checkpoint_obj_signal()
+	 * if needed.
+	 */
+	signal_objref = ckpt_obj_lookup_add(ctx, t->signal,
+					    CKPT_OBJ_SIGNAL, &first);
+	ckpt_debug("signal: objref %d\n", signal_objref);
+	if (signal_objref < 0) {
+		ckpt_err(ctx, signal_objref, "%(T)process signals\n");
+		return signal_objref;
+	}
+
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (!h)
 		return -ENOMEM;
 	h->files_objref = files_objref;
 	h->mm_objref = mm_objref;
 	h->sighand_objref = sighand_objref;
+	h->signal_objref = signal_objref;
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	/* actually save t->signal, if need to */
+	if (first)
+		ret = checkpoint_obj_signal(ctx, t);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "%(T)signal_struct\n");
 
 	return ret;
 }
@@ -379,6 +404,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		goto out;
 	ret = checkpoint_task_objs(ctx, t);
 	ckpt_debug("objs %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_task_signal(ctx, t);
+	ckpt_debug("task-signal %d\n", ret);
  out:
 	ctx->tsk = NULL;
 	return ret;
@@ -567,6 +596,11 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 
 	ret = restore_obj_sighand(ctx, h->sighand_objref);
 	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_obj_signal(ctx, h->signal_objref);
+	ckpt_debug("signal: ret %d (%p)\n", ret, current->signal);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -704,6 +738,37 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* prepare the task for restore */
+int pre_restore_task(void)
+{
+	sigset_t sigset;
+
+	/*
+	 * Block task's signals to avoid interruptions due to signals,
+	 * say, from restored timers, file descriptors etc. Signals
+	 * will be unblocked when restore completes.
+	 *
+	 * NOTE: tasks with file descriptors set to send a SIGKILL as
+	 * i/o notification may fail the restart if a signal occurs
+	 * before that task completed its restore. FIX ?
+	 */
+	current->saved_sigmask = current->blocked;
+
+	sigfillset(&sigset);
+	sigdelset(&sigset, SIGKILL);
+	sigdelset(&sigset, SIGSTOP);
+	sigprocmask(SIG_SETMASK, &sigset, NULL);
+
+	return 0;
+}
+
+/* finish up task restore */
+void post_restore_task(void)
+{
+	/* only now is it safe to unblock the restored task's signals */
+	sigprocmask(SIG_SETMASK, &current->saved_sigmask, NULL);
+}
+
 /* read the entire state of the current task */
 int restore_task(struct ckpt_ctx *ctx)
 {
@@ -736,6 +801,10 @@ int restore_task(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_creds(ctx);
 	ckpt_debug("creds: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_task_signal(ctx);
+	ckpt_debug("signal: ret %d\n", ret);
  out:
 	return ret;
 }
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 34d3e64..026911e 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -933,6 +933,10 @@ static int do_restore_task(void)
 
 	restore_debug_running(ctx);
 
+	ret = pre_restore_task();
+	if (ret < 0)
+		goto out;
+
 	zombie = restore_task(ctx);
 	if (zombie < 0) {
 		ret = zombie;
@@ -946,6 +950,7 @@ static int do_restore_task(void)
 	 */
 	if (zombie) {
 		restore_debug_exit(ctx);
+		post_restore_task();
 		ckpt_ctx_put(ctx);
 		do_exit(current->exit_code);
 	}
@@ -957,6 +962,7 @@ static int do_restore_task(void)
 	if (ret < 0)
 		ckpt_err(ctx, ret, "task restart failed\n");
 
+	post_restore_task();
 	current->flags &= ~PF_RESTARTING;
 	clear_task_ctx(current);
 	ckpt_ctx_put(ctx);
@@ -1164,6 +1170,10 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	 */
 
 	if (ctx->uflags & RESTART_TASKSELF) {
+		ret = pre_restore_task();
+		ckpt_debug("pre restore task: %d\n", ret);
+		if (ret < 0)
+			goto out;
 		ret = restore_task(ctx);
 		ckpt_debug("restore task: %d\n", ret);
 		if (ret < 0)
@@ -1196,6 +1206,9 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 		ckpt_debug("freezing restart tasks ... %d\n", ret);
 	}
  out:
+	if (ctx->uflags & RESTART_TASKSELF)
+		post_restore_task();
+
 	restore_debug_error(ctx, ret);
 	if (ret < 0)
 		ckpt_err(ctx, ret, "restart failed (coordinator)\n");
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 1aadadd..fedb8f8 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -161,3 +161,114 @@ int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
 
 	return 0;
 }
+
+/***********************************************************************
+ * signal checkpoint/restart
+ */
+
+static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_signal *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
+	if (!h)
+		return -ENOMEM;
+
+	/* fill in later */
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	BUG_ON(t->flags & PF_EXITING);
+	return checkpoint_signal(ctx, t);
+}
+
+static int restore_signal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_signal *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/* fill in later */
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
+{
+	struct signal_struct *signal;
+	int ret = 0;
+
+	signal = ckpt_obj_fetch(ctx, signal_objref, CKPT_OBJ_SIGNAL);
+	if (!IS_ERR(signal)) {
+		/*
+		 * signal_struct is already shared properly as it is
+		 * tied to thread groups. Since thread relationships
+		 * are already restore now, t->signal must match.
+		 */
+		if (signal != current->signal)
+			ret = -EINVAL;
+	} else if (PTR_ERR(signal) == -EINVAL) {
+		/* first timer: add to hash and restore our t->signal */
+		ret = ckpt_obj_insert(ctx, current->signal,
+				      signal_objref, CKPT_OBJ_SIGNAL);
+		if (ret >= 0)
+			ret = restore_signal(ctx);
+	} else {
+		ret = PTR_ERR(signal);
+	}
+
+	return ret;
+}
+
+int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_signal_task *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
+	if (!h)
+		return -ENOMEM;
+
+	if (task_has_saved_sigmask(t))
+		fill_sigset(&h->blocked, &t->saved_sigmask);
+	else
+		fill_sigset(&h->blocked, &t->blocked);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int restore_task_signal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_signal_task *h;
+	sigset_t blocked;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	load_sigset(&blocked, &h->blocked);
+	/* silently remove SIGKILL, SIGSTOP */
+	sigdelset(&blocked, SIGKILL);
+	sigdelset(&blocked, SIGSTOP);
+
+	/*
+	 * Unblocking signals now may affect us in wait_task_sync().
+	 * Instead, save blocked mask in current->saved_sigmaks for
+	 * post_restore_task().
+	 */
+	current->saved_sigmask = blocked;
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 5a26f8b..2fe2a9d 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -152,6 +152,8 @@ extern int ckpt_activate_next(struct ckpt_ctx *ctx);
 extern int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
+extern int pre_restore_task(void);
+extern void post_restore_task(void);
 
 /* arch hooks */
 extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
@@ -275,6 +277,12 @@ extern int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr);
 extern void *restore_sighand(struct ckpt_ctx *ctx);
 
+extern int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref);
+
+extern int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_task_signal(struct ckpt_ctx *ctx);
+
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 225fd1f..535ea93 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -133,6 +133,10 @@ enum {
 
 	CKPT_HDR_SIGHAND = 601,
 #define CKPT_HDR_SIGHAND CKPT_HDR_SIGHAND
+	CKPT_HDR_SIGNAL,
+#define CKPT_HDR_SIGNAL CKPT_HDR_SIGNAL
+	CKPT_HDR_SIGNAL_TASK,
+#define CKPT_HDR_SIGNAL_TASK CKPT_HDR_SIGNAL_TASK
 
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
@@ -173,6 +177,8 @@ enum obj_type {
 #define CKPT_OBJ_MM CKPT_OBJ_MM
 	CKPT_OBJ_SIGHAND,
 #define CKPT_OBJ_SIGHAND CKPT_OBJ_SIGHAND
+	CKPT_OBJ_SIGNAL,
+#define CKPT_OBJ_SIGNAL CKPT_OBJ_SIGNAL
 	CKPT_OBJ_NS,
 #define CKPT_OBJ_NS CKPT_OBJ_NS
 	CKPT_OBJ_UTS_NS,
@@ -373,6 +379,7 @@ struct ckpt_hdr_task_objs {
 	__s32 files_objref;
 	__s32 mm_objref;
 	__s32 sighand_objref;
+	__s32 signal_objref;
 } __attribute__((aligned(8)));
 
 /* restart blocks */
@@ -531,6 +538,15 @@ struct ckpt_hdr_sighand {
 	struct ckpt_sigaction action[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_signal {
+	struct ckpt_hdr h;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_signal_task {
+	struct ckpt_hdr h;
+	struct ckpt_sigset blocked;
+} __attribute__((aligned(8)));
+
 /* ipc commons */
 struct ckpt_hdr_ipcns {
 	struct ckpt_hdr h;
diff --git a/include/linux/signal.h b/include/linux/signal.h
index ab9272c..af6cac3 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -376,6 +376,9 @@ int unhandled_signal(struct task_struct *tsk, int sig);
 
 void signals_init(void);
 
+/* [arch] checkpoint: should saved_sigmask be used in place of blocked */
+int task_has_saved_sigmask(struct task_struct *task);
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SIGNAL_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 4eb8e7e..24472ec 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -910,6 +910,9 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 
 	sig->oom_adj = current->signal->oom_adj;
 
+#ifdef CONFIG_CHECKPOINT
+	atomic_set(&sig->restart_count, 0);
+#endif
 	return 0;
 }
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
