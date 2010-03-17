Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1744A620026
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:19:06 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 67/96] c/r: checkpoint and restore (shared) task's sighand_struct
Date: Wed, 17 Mar 2010 12:08:55 -0400
Message-Id: <1268842164-5590-68-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-67-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

This patch adds the checkpointing and restart of signal handling
state - 'struct sighand_struct'. Since the contents of this state
only affect userspace, no input validation is required.

Add _NSIG to kernel constants saved/tested with image header.

Number of signals (_NSIG) is arch-dependent, but is within __KERNEL__
and not visibile to userspace compile. Therefore, define per arch
CKPT_ARCH_NSIG in <asm/checkpoint_hdr.h>.

Changelog[v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
Changelog[v1]:
  - Rename headerless struct ckpt_hdr_* to struct ckpt_*

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 arch/s390/include/asm/checkpoint_hdr.h |    8 ++
 arch/x86/include/asm/checkpoint_hdr.h  |    8 ++
 checkpoint/Makefile                    |    3 +-
 checkpoint/checkpoint.c                |    2 +
 checkpoint/objhash.c                   |   26 +++++
 checkpoint/process.c                   |   19 ++++
 checkpoint/restart.c                   |    3 +
 checkpoint/signal.c                    |  163 ++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h             |    9 ++-
 include/linux/checkpoint_hdr.h         |   24 +++++
 10 files changed, 263 insertions(+), 2 deletions(-)
 create mode 100644 checkpoint/signal.c

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
index e3312c0..7d30317 100644
--- a/arch/s390/include/asm/checkpoint_hdr.h
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -91,6 +91,14 @@ struct ckpt_hdr_mm_context {
 	unsigned long asce_limit;
 };
 
+#define CKPT_ARCH_NSIG  64
+#ifdef __KERNEL__
+#include <asm/signal.h>
+#if CKPT_ARCH_NSIG != _SIGCONTEXT_NSIG
+#error CKPT_ARCH_NSIG size is wrong (asm/sigcontext.h and asm/checkpoint_hdr.h)
+#endif
+#endif
+
 struct ckpt_hdr_header_arch {
 	struct ckpt_hdr h;
 };
diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 292bf50..44737b8 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -52,6 +52,14 @@ enum {
 #define CKPT_HDR_MM_CONTEXT_LDT CKPT_HDR_MM_CONTEXT_LDT
 };
 
+#define CKPT_ARCH_NSIG  64
+#ifdef __KERNEL__
+#include <asm/signal.h>
+#if CKPT_ARCH_NSIG != _NSIG
+#error CKPT_ARCH_NSIG size is wrong per asm/signal.h and asm/checkpoint_hdr.h
+#endif
+#endif
+
 struct ckpt_hdr_header_arch {
 	struct ckpt_hdr h;
 	/* FIXME: add HAVE_HWFP */
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index bb2c0ca..f8a55df 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -10,4 +10,5 @@ obj-$(CONFIG_CHECKPOINT) += \
 	process.o \
 	namespace.o \
 	files.o \
-	memory.o
+	memory.o \
+	signal.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index f2d9016..445fef7 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -113,6 +113,8 @@ static void fill_kernel_const(struct ckpt_const *h)
 	h->task_comm_len = sizeof(tsk->comm);
 	/* mm->saved_auxv size */
 	h->at_vector_size = AT_VECTOR_SIZE;
+	/* signal */
+	h->signal_nsig = _NSIG;
 	/* uts */
 	h->uts_sysname_len = sizeof(uts->sysname);
 	h->uts_nodename_len = sizeof(uts->nodename);
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 56d450a..858613e 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -125,6 +125,22 @@ static int obj_mm_users(void *ptr)
 	return atomic_read(&((struct mm_struct *) ptr)->mm_users);
 }
 
+static int obj_sighand_grab(void *ptr)
+{
+	atomic_inc(&((struct sighand_struct *) ptr)->count);
+	return 0;
+}
+
+static void obj_sighand_drop(void *ptr, int lastref)
+{
+	__cleanup_sighand((struct sighand_struct *) ptr);
+}
+
+static int obj_sighand_users(void *ptr)
+{
+	return atomic_read(&((struct sighand_struct *) ptr)->count);
+}
+
 static int obj_ns_grab(void *ptr)
 {
 	get_nsproxy((struct nsproxy *) ptr);
@@ -263,6 +279,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_mm,
 		.restore = restore_mm,
 	},
+	/* sighand object */
+	{
+		.obj_name = "SIGHAND",
+		.obj_type = CKPT_OBJ_SIGHAND,
+		.ref_drop = obj_sighand_drop,
+		.ref_grab = obj_sighand_grab,
+		.ref_users = obj_sighand_users,
+		.checkpoint = checkpoint_sighand,
+		.restore = restore_sighand,
+	},
 	/* ns object */
 	{
 		.obj_name = "NSPROXY",
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 6741b43..71eb9a5 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -181,6 +181,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct ckpt_hdr_task_objs *h;
 	int files_objref;
 	int mm_objref;
+	int sighand_objref;
 	int ret;
 
 	/*
@@ -219,11 +220,19 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 		return mm_objref;
 	}
 
+	sighand_objref = checkpoint_obj_sighand(ctx, t);
+	ckpt_debug("sighand: objref %d\n", sighand_objref);
+	if (sighand_objref < 0) {
+		ckpt_err(ctx, sighand_objref, "%(T)sighand_struct\n");
+		return sighand_objref;
+	}
+
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (!h)
 		return -ENOMEM;
 	h->files_objref = files_objref;
 	h->mm_objref = mm_objref;
+	h->sighand_objref = sighand_objref;
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
 
@@ -386,6 +395,9 @@ int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (ret < 0)
 		return ret;
 	ret = ckpt_collect_mm(ctx, t);
+	if (ret < 0)
+		return ret;
+	ret = ckpt_collect_sighand(ctx, t);
 
 	return ret;
 }
@@ -545,10 +557,17 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 
 	ret = restore_obj_file_table(ctx, h->files_objref);
 	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
+	if (ret < 0)
+		goto out;
 
 	ret = restore_obj_mm(ctx, h->mm_objref);
 	ckpt_debug("mm: ret %d (%p)\n", ret, current->mm);
+	if (ret < 0)
+		goto out;
 
+	ret = restore_obj_sighand(ctx, h->sighand_objref);
+	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
+ out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 60a8bb4..34d3e64 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -567,6 +567,9 @@ static int check_kernel_const(struct ckpt_const *h)
 	/* mm->saved_auxv size */
 	if (h->at_vector_size != AT_VECTOR_SIZE)
 		return -EINVAL;
+	/* signal */
+	if (h->signal_nsig != _NSIG)
+		return -EINVAL;
 	/* uts */
 	if (h->uts_sysname_len != sizeof(uts->sysname))
 		return -EINVAL;
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
new file mode 100644
index 0000000..1aadadd
--- /dev/null
+++ b/checkpoint/signal.c
@@ -0,0 +1,163 @@
+/*
+ *  Checkpoint task signals
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <linux/sched.h>
+#include <linux/signal.h>
+#include <linux/errno.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+static inline void fill_sigset(struct ckpt_sigset *h, sigset_t *sigset)
+{
+	memcpy(&h->sigset, sigset, sizeof(*sigset));
+}
+
+static inline void load_sigset(sigset_t *sigset, struct ckpt_sigset *h)
+{
+	memcpy(sigset, &h->sigset, sizeof(*sigset));
+}
+
+/***********************************************************************
+ * sighand checkpoint/collect/restart
+ */
+
+static int do_checkpoint_sighand(struct ckpt_ctx *ctx,
+				 struct sighand_struct *sighand)
+{
+	struct ckpt_hdr_sighand *h;
+	struct ckpt_sigaction *hh;
+	struct sigaction *sa;
+	int i, ret;
+
+	h = ckpt_hdr_get_type(ctx, _NSIG * sizeof(*hh) + sizeof(*h),
+			      CKPT_HDR_SIGHAND);
+	if (!h)
+		return -ENOMEM;
+
+	hh = h->action;
+	spin_lock_irq(&sighand->siglock);
+	for (i = 0; i < _NSIG; i++) {
+		sa = &sighand->action[i].sa;
+		hh[i]._sa_handler = (unsigned long) sa->sa_handler;
+		hh[i].sa_flags = sa->sa_flags;
+		hh[i].sa_restorer = (unsigned long) sa->sa_restorer;
+		fill_sigset(&hh[i].sa_mask, &sa->sa_mask);
+	}
+	spin_unlock_irq(&sighand->siglock);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_sighand(ctx, (struct sighand_struct *) ptr);
+}
+
+int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct sighand_struct *sighand;
+	int objref;
+
+	read_lock(&tasklist_lock);
+	sighand = rcu_dereference(t->sighand);
+	atomic_inc(&sighand->count);
+	read_unlock(&tasklist_lock);
+
+	objref = checkpoint_obj(ctx, sighand, CKPT_OBJ_SIGHAND);
+	__cleanup_sighand(sighand);
+
+	return objref;
+}
+
+int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct sighand_struct *sighand;
+	int ret;
+
+	read_lock(&tasklist_lock);
+	sighand = rcu_dereference(t->sighand);
+	atomic_inc(&sighand->count);
+	read_unlock(&tasklist_lock);
+
+	ret = ckpt_obj_collect(ctx, sighand, CKPT_OBJ_SIGHAND);
+	__cleanup_sighand(sighand);
+
+	return ret;
+}
+
+static struct sighand_struct *do_restore_sighand(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_sighand *h;
+	struct ckpt_sigaction *hh;
+	struct sighand_struct *sighand;
+	struct sigaction *sa;
+	int i;
+
+	h = ckpt_read_obj_type(ctx, _NSIG * sizeof(*hh) + sizeof(*h),
+			       CKPT_HDR_SIGHAND);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	sighand = kmem_cache_alloc(sighand_cachep, GFP_KERNEL);
+	if (!sighand) {
+		sighand = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	atomic_set(&sighand->count, 1);
+
+	hh = h->action;
+	for (i = 0; i < _NSIG; i++) {
+		sa = &sighand->action[i].sa;
+		sa->sa_handler = (void *) (unsigned long) hh[i]._sa_handler;
+		sa->sa_flags = hh[i].sa_flags;
+		sa->sa_restorer = (void *) (unsigned long) hh[i].sa_restorer;
+		load_sigset(&sa->sa_mask, &hh[i].sa_mask);
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	return sighand;
+}
+
+void *restore_sighand(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_sighand(ctx);
+}
+
+int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
+{
+	struct sighand_struct *sighand;
+	struct sighand_struct *old_sighand;
+
+	sighand = ckpt_obj_fetch(ctx, sighand_objref, CKPT_OBJ_SIGHAND);
+	if (IS_ERR(sighand))
+		return PTR_ERR(sighand);
+
+	if (sighand == current->sighand)
+		return 0;
+
+	atomic_inc(&sighand->count);
+
+	/* manipulate tsk->sighand with tasklist lock write-held */
+	write_lock_irq(&tasklist_lock);
+	old_sighand = rcu_dereference(current->sighand);
+	spin_lock(&old_sighand->siglock);
+	rcu_assign_pointer(current->sighand, sighand);
+	spin_unlock(&old_sighand->siglock);
+	write_unlock_irq(&tasklist_lock);
+	__cleanup_sighand(old_sighand);
+
+	return 0;
+}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index f321860..5a26f8b 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -267,6 +267,14 @@ extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
 	 VM_RESERVED | VM_NORESERVE | VM_HUGETLB | VM_NONLINEAR |	\
 	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
 
+/* signals */
+extern int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref);
+
+extern int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_sighand(struct ckpt_ctx *ctx);
+
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
@@ -299,7 +307,6 @@ static inline int ckpt_validate_errno(int errno)
 			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
 	} while (0)
 
-
 /* debugging flags */
 #define CKPT_DBASE	0x1		/* anything */
 #define CKPT_DSYS	0x2		/* generic (system) */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 729be96..225fd1f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -131,6 +131,9 @@ enum {
 	CKPT_HDR_IPC_SEM,
 #define CKPT_HDR_IPC_SEM CKPT_HDR_IPC_SEM
 
+	CKPT_HDR_SIGHAND = 601,
+#define CKPT_HDR_SIGHAND CKPT_HDR_SIGHAND
+
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
 
@@ -168,6 +171,8 @@ enum obj_type {
 #define CKPT_OBJ_FILE CKPT_OBJ_FILE
 	CKPT_OBJ_MM,
 #define CKPT_OBJ_MM CKPT_OBJ_MM
+	CKPT_OBJ_SIGHAND,
+#define CKPT_OBJ_SIGHAND CKPT_OBJ_SIGHAND
 	CKPT_OBJ_NS,
 #define CKPT_OBJ_NS CKPT_OBJ_NS
 	CKPT_OBJ_UTS_NS,
@@ -192,6 +197,8 @@ struct ckpt_const {
 	__u16 task_comm_len;
 	/* mm */
 	__u16 at_vector_size;
+	/* signal */
+	__u16 signal_nsig;
 	/* uts */
 	__u16 uts_sysname_len;
 	__u16 uts_nodename_len;
@@ -365,6 +372,7 @@ struct ckpt_hdr_task_objs {
 
 	__s32 files_objref;
 	__s32 mm_objref;
+	__s32 sighand_objref;
 } __attribute__((aligned(8)));
 
 /* restart blocks */
@@ -506,6 +514,22 @@ struct ckpt_hdr_pgarr {
 	__u64 nr_pages;		/* number of pages to saved */
 } __attribute__((aligned(8)));
 
+/* signals */
+struct ckpt_sigset {
+	__u8 sigset[CKPT_ARCH_NSIG / 8];
+} __attribute__((aligned(8)));
+
+struct ckpt_sigaction {
+	__u64 _sa_handler;
+	__u64 sa_flags;
+	__u64 sa_restorer;
+	struct ckpt_sigset sa_mask;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_sighand {
+	struct ckpt_hdr h;
+	struct ckpt_sigaction action[0];
+} __attribute__((aligned(8)));
 
 /* ipc commons */
 struct ckpt_hdr_ipcns {
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
