Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 65319620026
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:19:19 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 69/96] c/r: [signal 2/4] checkpoint/restart of rlimit
Date: Wed, 17 Mar 2010 12:08:57 -0400
Message-Id: <1268842164-5590-70-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-69-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

This patch adds checkpoint and restart of rlimit information
that is part of shared signal_struct.

Changelog[v19-rc3]:
  - Rebase to kernel 2.6.33

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Louis Rilling <Louis.Rilling@kerlabs.com>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/checkpoint.c        |    2 ++
 checkpoint/restart.c           |    3 +++
 checkpoint/signal.c            |   27 +++++++++++++++++++++++----
 include/linux/checkpoint_hdr.h |   17 +++++++++++++++++
 include/linux/resource.h       |    1 +
 kernel/sys.c                   |   36 +++++++++++++++++++++++-------------
 6 files changed, 69 insertions(+), 17 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 445fef7..71a4bec 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -122,6 +122,8 @@ static void fill_kernel_const(struct ckpt_const *h)
 	h->uts_version_len = sizeof(uts->version);
 	h->uts_machine_len = sizeof(uts->machine);
 	h->uts_domainname_len = sizeof(uts->domainname);
+	/* rlimit */
+	h->rlimit_nlimits = RLIM_NLIMITS;
 }
 
 /* write the checkpoint header */
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 026911e..863ee87 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -583,6 +583,9 @@ static int check_kernel_const(struct ckpt_const *h)
 		return -EINVAL;
 	if (h->uts_domainname_len != sizeof(uts->domainname))
 		return -EINVAL;
+	/* rlimit */
+	if (h->rlimit_nlimits != RLIM_NLIMITS)
+		return -EINVAL;
 
 	return 0;
 }
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index fedb8f8..5884462 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -14,6 +14,7 @@
 #include <linux/sched.h>
 #include <linux/signal.h>
 #include <linux/errno.h>
+#include <linux/resource.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -169,13 +170,22 @@ int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
 static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_signal *h;
+	struct signal_struct *signal;
+	struct rlimit *rlim;
 	int ret;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
 	if (!h)
 		return -ENOMEM;
 
-	/* fill in later */
+	signal = t->signal;
+	rlim = signal->rlim;
+
+	/* rlimit */
+	for (i = 0; i < RLIM_NLIMITS; i++) {
+		h->rlim[i].rlim_cur = rlim[i].rlim_cur;
+		h->rlim[i].rlim_max = rlim[i].rlim_max;
+	}
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -191,15 +201,24 @@ int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 static int restore_signal(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_signal *h;
+	struct rlimit rlim;
+	int i, ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	/* fill in later */
-
+	/* rlimit */
+	for (i = 0; i < RLIM_NLIMITS; i++) {
+		rlim.rlim_cur = h->rlim[i].rlim_cur;
+		rlim.rlim_max = h->rlim[i].rlim_max;
+		ret = do_setrlimit(i, &rlim);
+		if (ret < 0)
+			break;
+	}
+ out:
 	ckpt_hdr_put(ctx, h);
-	return 0;
+	return ret;
 }
 
 int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 535ea93..39302a6 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -212,6 +212,8 @@ struct ckpt_const {
 	__u16 uts_version_len;
 	__u16 uts_machine_len;
 	__u16 uts_domainname_len;
+	/* rlimit */
+	__u16 rlimit_nlimits;
 } __attribute__((aligned(8)));
 
 /* checkpoint image header */
@@ -538,8 +540,23 @@ struct ckpt_hdr_sighand {
 	struct ckpt_sigaction action[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_rlimit {
+	__u64 rlim_cur;
+	__u64 rlim_max;
+} __attribute__((aligned(8)));
+
+/* cannot include <linux/resource.h> from userspace, so define: */
+#define CKPT_RLIM_NLIMITS  16
+#ifdef __KERNEL__
+#include <linux/resource.h>
+#if CKPT_RLIM_NLIMITS != RLIM_NLIMITS
+#error CKPT_RLIM_NLIMIT size is wrong per asm-generic/resource.h
+#endif
+#endif
+
 struct ckpt_hdr_signal {
 	struct ckpt_hdr h;
+	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_signal_task {
diff --git a/include/linux/resource.h b/include/linux/resource.h
index f1e914e..35f6163 100644
--- a/include/linux/resource.h
+++ b/include/linux/resource.h
@@ -73,6 +73,7 @@ struct rlimit {
 struct task_struct;
 
 int getrusage(struct task_struct *p, int who, struct rusage __user *ru);
+int do_setrlimit(unsigned int resource, struct rlimit *rlim);
 
 #endif /* __KERNEL__ */
 
diff --git a/kernel/sys.c b/kernel/sys.c
index 0df737a..033c650 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1149,40 +1149,39 @@ SYSCALL_DEFINE2(old_getrlimit, unsigned int, resource,
 
 #endif
 
-SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
+int do_setrlimit(unsigned int resource, struct rlimit *new_rlim)
 {
-	struct rlimit new_rlim, *old_rlim;
+	struct rlimit *old_rlim;
 	int retval;
 
 	if (resource >= RLIM_NLIMITS)
 		return -EINVAL;
-	if (copy_from_user(&new_rlim, rlim, sizeof(*rlim)))
-		return -EFAULT;
-	if (new_rlim.rlim_cur > new_rlim.rlim_max)
+	if (new_rlim->rlim_cur > new_rlim->rlim_max)
 		return -EINVAL;
+
 	old_rlim = current->signal->rlim + resource;
-	if ((new_rlim.rlim_max > old_rlim->rlim_max) &&
+	if ((new_rlim->rlim_max > old_rlim->rlim_max) &&
 	    !capable(CAP_SYS_RESOURCE))
 		return -EPERM;
-	if (resource == RLIMIT_NOFILE && new_rlim.rlim_max > sysctl_nr_open)
+	if (resource == RLIMIT_NOFILE && new_rlim->rlim_max > sysctl_nr_open)
 		return -EPERM;
 
-	retval = security_task_setrlimit(resource, &new_rlim);
+	retval = security_task_setrlimit(resource, new_rlim);
 	if (retval)
 		return retval;
 
-	if (resource == RLIMIT_CPU && new_rlim.rlim_cur == 0) {
+	if (resource == RLIMIT_CPU && new_rlim->rlim_cur == 0) {
 		/*
 		 * The caller is asking for an immediate RLIMIT_CPU
 		 * expiry.  But we use the zero value to mean "it was
 		 * never set".  So let's cheat and make it one second
 		 * instead
 		 */
-		new_rlim.rlim_cur = 1;
+		new_rlim->rlim_cur = 1;
 	}
 
 	task_lock(current->group_leader);
-	*old_rlim = new_rlim;
+	*old_rlim = *new_rlim;
 	task_unlock(current->group_leader);
 
 	if (resource != RLIMIT_CPU)
@@ -1194,14 +1193,25 @@ SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
 	 * very long-standing error, and fixing it now risks breakage of
 	 * applications, so we live with it
 	 */
-	if (new_rlim.rlim_cur == RLIM_INFINITY)
+	if (new_rlim->rlim_cur == RLIM_INFINITY)
 		goto out;
 
-	update_rlimit_cpu(new_rlim.rlim_cur);
+	update_rlimit_cpu(new_rlim->rlim_cur);
 out:
 	return 0;
 }
 
+SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
+{
+	struct rlimit new_rlim;
+
+	if (resource >= RLIM_NLIMITS)
+		return -EINVAL;
+	if (copy_from_user(&new_rlim, rlim, sizeof(*rlim)))
+		return -EFAULT;
+	return do_setrlimit(resource, &new_rlim);
+}
+
 /*
  * It would make sense to put struct rusage in the task_struct,
  * except that would make the task_struct be *really big*.  After
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
