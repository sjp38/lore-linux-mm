Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CF8BB620038
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:23:58 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 81/96] c/r: support for controlling terminal and job control
Date: Wed, 17 Mar 2010 12:09:09 -0400
Message-Id: <1268842164-5590-82-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-81-git-send-email-orenl@cs.columbia.edu>
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
 <1268842164-5590-74-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-75-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-76-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-77-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-78-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-79-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-80-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-81-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add checkpoint/restart of controlling terminal: current->signal->tty.
This is only done for session leaders.

If the session leader belongs to the ancestor pid-ns, then checkpoint
skips this tty; On restart, it will not be restored, and whatever tty
is in place from parent pid-ns (at restart) will be inherited.

Chagnelog [v1]:
  - Don't restore tty_old_pgrp it pgid is CKPT_PID_NULL
  - Initialize pgrp to NULL in restore_signal

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/signal.c            |   79 +++++++++++++++++++++++++++++++++++++++-
 drivers/char/tty_io.c          |   33 +++++++++++++----
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    6 +++
 include/linux/tty.h            |    5 +++
 5 files changed, 115 insertions(+), 9 deletions(-)

diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index ecb94f8..9d0e9c3 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -316,12 +316,13 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct ckpt_hdr_signal *h;
 	struct signal_struct *signal;
 	struct sigpending shared_pending;
+	struct tty_struct *tty = NULL;
 	struct rlimit *rlim;
 	struct timeval tval;
 	struct cpu_itimer *it;
 	cputime_t cputime;
 	unsigned long flags;
-	int i, ret;
+	int i, ret = 0;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
 	if (!h)
@@ -403,9 +404,34 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	cputime_to_timeval(it->incr, &tval);
 	h->it_prof_incr = timeval_to_ns(&tval);
 
+	/* tty */
+	if (signal->leader) {
+		h->tty_old_pgrp = ckpt_pid_nr(ctx, signal->tty_old_pgrp);
+		tty = tty_kref_get(signal->tty);
+		if (tty) {
+			/* irq is already disabled */
+			spin_lock(&tty->ctrl_lock);
+			h->tty_pgrp = ckpt_pid_nr(ctx, tty->pgrp);
+			spin_unlock(&tty->ctrl_lock);
+			tty_kref_put(tty);
+		}
+	}
+
 	unlock_task_sighand(t, &flags);
 
-	ret = ckpt_write_obj(ctx, &h->h);
+	/*
+	 * If the session is in an ancestor namespace, skip this tty
+	 * and set tty_objref = 0. It will not be explicitly restored,
+	 * but rather inherited from parent pid-ns at restart time.
+	 */
+	if (tty && ckpt_pid_nr(ctx, tty->session) > 0) {
+		h->tty_objref = checkpoint_obj(ctx, tty, CKPT_OBJ_TTY);
+		if (h->tty_objref < 0)
+			ret = h->tty_objref;
+	}
+
+	if (!ret)
+		ret = ckpt_write_obj(ctx, &h->h);
 	if (!ret)
 		ret = checkpoint_sigpending(ctx, &shared_pending);
 
@@ -476,8 +502,10 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	struct ckpt_hdr_signal *h;
 	struct sigpending new_pending;
 	struct sigpending *pending;
+	struct tty_struct *tty = NULL;
 	struct itimerval itimer;
 	struct rlimit rlim;
+	struct pid *pgrp = NULL;
 	int i, ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
@@ -497,6 +525,40 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 
+	/* tty - session */
+	if (h->tty_objref) {
+		tty = ckpt_obj_fetch(ctx, h->tty_objref, CKPT_OBJ_TTY);
+		if (IS_ERR(tty)) {
+			ret = PTR_ERR(tty);
+			goto out;
+		}
+		/* this will fail unless we're the session leader */
+		ret = tiocsctty(tty, 0);
+		if (ret < 0)
+			goto out;
+		/* now restore the foreground group (job control) */
+		if (h->tty_pgrp) {
+			/*
+			 * If tty_pgrp == CKPT_PID_NULL, below will
+			 * fail, so no need for explicit test
+			 */
+			ret = do_tiocspgrp(tty, tty_pair_get_tty(tty),
+					   h->tty_pgrp);
+			if (ret < 0)
+				goto out;
+		}
+	} else {
+		/*
+		 * If tty_objref isn't set, we _keep_ whatever tty we
+		 * already have as a ctty. Why does this make sense ?
+		 * - If our session is "within" the restart context,
+		 * then that session has no controlling terminal.
+		 * - If out session is "outside" the restart context,
+		 * then we're like to keep whatever we inherit from
+		 * the parent pid-ns.
+		 */
+	}
+
 	/*
 	 * Reset real/virt/prof itimer (in case they were set), to
 	 * prevent unwanted signals after flushing current signals
@@ -508,7 +570,20 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
 	do_setitimer(ITIMER_PROF, &itimer, NULL);
 
+	/* tty - tty_old_pgrp */
+	if (current->signal->leader && h->tty_old_pgrp != CKPT_PID_NULL) {
+		rcu_read_lock();
+		pgrp = get_pid(_ckpt_find_pgrp(ctx, h->tty_old_pgrp));
+		rcu_read_unlock();
+		if (!pgrp)
+			goto out;
+	}
+
 	spin_lock_irq(&current->sighand->siglock);
+	/* tty - tty_old_pgrp */
+	put_pid(current->signal->tty_old_pgrp);
+	current->signal->tty_old_pgrp = pgrp;
+	/* pending signals */
 	pending = &current->signal->shared_pending;
 	flush_sigqueue(pending);
 	pending->signal = new_pending.signal;
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 0dbf3f0..86946af 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2173,7 +2173,7 @@ static int fionbio(struct file *file, int __user *p)
  *		Takes ->siglock() when updating signal->tty
  */
 
-static int tiocsctty(struct tty_struct *tty, int arg)
+int tiocsctty(struct tty_struct *tty, int arg)
 {
 	int ret = 0;
 	if (current->signal->leader && (task_session(current) == tty->session))
@@ -2262,10 +2262,10 @@ static int tiocgpgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
 }
 
 /**
- *	tiocspgrp		-	attempt to set process group
+ *	do_tiocspgrp		-	attempt to set process group
  *	@tty: tty passed by user
  *	@real_tty: tty side device matching tty passed by user
- *	@p: pid pointer
+ *	@pid: pgrp_nr
  *
  *	Set the process group of the tty to the session passed. Only
  *	permitted where the tty session is our session.
@@ -2273,10 +2273,10 @@ static int tiocgpgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
  *	Locking: RCU, ctrl lock
  */
 
-static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t __user *p)
+int do_tiocspgrp(struct tty_struct *tty,
+		 struct tty_struct *real_tty, pid_t pgrp_nr)
 {
 	struct pid *pgrp;
-	pid_t pgrp_nr;
 	int retval = tty_check_change(real_tty);
 	unsigned long flags;
 
@@ -2288,8 +2288,6 @@ static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
 	    (current->signal->tty != real_tty) ||
 	    (real_tty->session != task_session(current)))
 		return -ENOTTY;
-	if (get_user(pgrp_nr, p))
-		return -EFAULT;
 	if (pgrp_nr < 0)
 		return -EINVAL;
 	rcu_read_lock();
@@ -2311,6 +2309,27 @@ out_unlock:
 }
 
 /**
+ *	tiocspgrp		-	attempt to set process group
+ *	@tty: tty passed by user
+ *	@real_tty: tty side device matching tty passed by user
+ *	@p: pid pointer
+ *
+ *	Set the process group of the tty to the session passed. Only
+ *	permitted where the tty session is our session.
+ *
+ *	Locking: RCU, ctrl lock
+ */
+
+static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t __user *p)
+{
+	pid_t pgrp_nr;
+
+	if (get_user(pgrp_nr, p))
+		return -EFAULT;
+	return do_tiocspgrp(tty, real_tty, pgrp_nr);
+}
+
+/**
  *	tiocgsid		-	get session id
  *	@tty: tty passed by user
  *	@real_tty: tty side of the tty pased by the user if a pty else the tty
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c7bd9d4..ca91405 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -99,6 +99,7 @@ extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
 
 /* pids */
 extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
+extern struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid);
 
 /* socket functions */
 extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 549093c..4fe63b1 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -808,13 +808,19 @@ struct ckpt_rlimit {
 
 struct ckpt_hdr_signal {
 	struct ckpt_hdr h;
+	/* rlimit */
 	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
+	/* itimer */
 	__u64 it_real_value;
 	__u64 it_real_incr;
 	__u64 it_virt_value;
 	__u64 it_virt_incr;
 	__u64 it_prof_value;
 	__u64 it_prof_incr;
+	/* tty */
+	__s32 tty_objref;
+	__s32 tty_pgrp;
+	__s32 tty_old_pgrp;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_signal_task {
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 887afd1..e2edb2d 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -504,6 +504,11 @@ extern void tty_ldisc_enable(struct tty_struct *tty);
 /* This one is for ptmx_close() */
 extern int tty_release(struct inode *inode, struct file *filp);
 
+/* These are for checkpoint/restart */
+extern int tiocsctty(struct tty_struct *tty, int arg);
+extern int do_tiocspgrp(struct tty_struct *tty,
+			struct tty_struct *real_tty, pid_t pgrp_nr);
+
 #ifdef CONFIG_CHECKPOINT
 struct ckpt_ctx;
 struct ckpt_hdr_file;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
