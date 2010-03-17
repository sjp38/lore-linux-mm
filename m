Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D0872620027
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:17:11 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 60/96] c/r: support semaphore sysv-ipc
Date: Wed, 17 Mar 2010 12:08:48 -0400
Message-Id: <1268842164-5590-61-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-60-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Checkpoint of sysvipc semaphores is performed by iterating through all
sem objects and dumping the contents of each one. The semaphore array
of each sem is dumped with that object.

The semaphore array (sem->sem_base) holds an array of 'struct sem',
which is a {int, int}. Because this translates into the same format
on 32- and 64-bit architectures, the checkpoint format is simply the
dump of this array as is.

TODO: this patch does not handle semaphore-undo -- this data should be
saved per-task while iterating through the tasks.

Changelog[v20]:
    Fix "scheduling in atomic" while restoring ipc sem
Changelog[v19-rc3]:
  - Don't free sma if it's an error on restore
Changelog[v18]:
  - Handle kmalloc failure in restore_sem_array()
Changelog[v17]:
  - Restore objects in the right namespace
  - Forward declare struct msg_msg (instead of include linux/msg.h)
  - Fix typo in comment
  - Don't unlock ipc before calling freeary in error path

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/checkpoint_hdr.h |    8 ++
 ipc/Makefile                   |    2 +-
 ipc/checkpoint.c               |    4 -
 ipc/checkpoint_sem.c           |  240 ++++++++++++++++++++++++++++++++++++++++
 ipc/sem.c                      |   11 +-
 ipc/util.h                     |    8 ++
 6 files changed, 261 insertions(+), 12 deletions(-)
 create mode 100644 ipc/checkpoint_sem.c

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 07e918e..64c3f8f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -494,6 +494,14 @@ struct ckpt_hdr_ipc_msg_msg {
 	__u32 m_ts;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_ipc_sem {
+	struct ckpt_hdr h;
+	struct ckpt_hdr_ipc_perms perms;
+	__u64 sem_otime;
+	__u64 sem_ctime;
+	__u32 sem_nsems;
+} __attribute__((aligned(8)));
+
 
 #define CKPT_TST_OVERFLOW_16(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
diff --git a/ipc/Makefile b/ipc/Makefile
index 71a257f..3ecba9e 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -10,4 +10,4 @@ obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
 obj-$(CONFIG_SYSVIPC_CHECKPOINT) += checkpoint.o \
-		checkpoint_shm.o checkpoint_msg.o
+		checkpoint_shm.o checkpoint_msg.o checkpoint_sem.o
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 6b1ec0b..4e7ac81 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -134,12 +134,10 @@ static int do_checkpoint_ipc_ns(struct ckpt_ctx *ctx,
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
 				 CKPT_HDR_IPC_MSG, checkpoint_ipc_msg);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SEM_IDS,
 				 CKPT_HDR_IPC_SEM, checkpoint_ipc_sem);
-#endif
 	return ret;
 }
 
@@ -332,7 +330,6 @@ static struct ipc_namespace *do_restore_ipc_ns(struct ckpt_ctx *ctx)
 
 	ret = restore_ipc_any(ctx, ipc_ns, IPC_SHM_IDS,
 			      CKPT_HDR_IPC_SHM, restore_ipc_shm);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		goto out;
 	ret = restore_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
@@ -341,7 +338,6 @@ static struct ipc_namespace *do_restore_ipc_ns(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_ipc_any(ctx, ipc_ns, IPC_SEM_IDS,
 			      CKPT_HDR_IPC_SEM, restore_ipc_sem);
-#endif
 	if (ret < 0)
 		goto out;
 
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
new file mode 100644
index 0000000..a1a4356
--- /dev/null
+++ b/ipc/checkpoint_sem.c
@@ -0,0 +1,240 @@
+/*
+ *  Checkpoint/restart - dump state of sysvipc sem
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DIPC
+
+#include <linux/mm.h>
+#include <linux/sem.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/syscalls.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+
+struct msg_msg;
+#include "util.h"
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/************************************************************************
+ * ipc checkpoint
+ */
+
+/* called with the msgids->rw_mutex is read-held */
+static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
+			       struct ckpt_hdr_ipc_sem *h,
+			       struct sem_array *sem)
+{
+	int ret = 0;
+
+	ret = checkpoint_fill_ipc_perms(&h->perms, &sem->sem_perm);
+	if (ret < 0)
+		return ret;
+
+	ipc_lock_by_ptr(&sem->sem_perm);
+	h->sem_otime = sem->sem_otime;
+	h->sem_ctime = sem->sem_ctime;
+	h->sem_nsems = sem->sem_nsems;
+	ipc_unlock(&sem->sem_perm);
+
+	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
+
+	return 0;
+}
+
+/**
+ * ckpt_write_sem_array - dump the state of a semaphore array
+ * @ctx: checkpoint context
+ * @sem: semphore array
+ *
+ * The state of a sempahore is an array of 'struct sem'. This structure
+ * is {int, int}, which translates to the same format {32 bits, 32 bits}
+ * on both 32- and 64-bit architectures. So we simply dump the array.
+ *
+ * The sem-undo information is not saved per ipc_ns, but rather per task.
+ */
+static int checkpoint_sem_array(struct ckpt_ctx *ctx, struct sem_array *sem)
+{
+	/* this is a "best-effort" test, so lock not needed */
+	if (!list_empty(&sem->sem_pending))
+		return -EBUSY;
+
+	/* our caller holds the mutex, so this is safe */
+	return ckpt_write_buffer(ctx, sem->sem_base,
+			       sem->sem_nsems * sizeof(*sem->sem_base));
+}
+
+/* called with the msgids->rw_mutex is read-held */
+int checkpoint_ipc_sem(int id, void *p, void *data)
+{
+	struct ckpt_hdr_ipc_sem *h;
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+	struct kern_ipc_perm *perm = (struct kern_ipc_perm *) p;
+	struct sem_array *sem;
+	int ret;
+
+	sem = container_of(perm, struct sem_array, sem_perm);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_SEM);
+	if (!h)
+		return -ENOMEM;
+
+	ret = fill_ipc_sem_hdr(ctx, h, sem);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	if (h->sem_nsems)
+		ret = checkpoint_sem_array(ctx, sem);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/************************************************************************
+ * ipc restart
+ */
+
+/* called with the msgids->rw_mutex is write-held */
+static int load_ipc_sem_hdr(struct ckpt_ctx *ctx,
+			       struct ckpt_hdr_ipc_sem *h,
+			       struct sem_array *sem)
+{
+	int ret = 0;
+
+	ret = restore_load_ipc_perms(&h->perms, &sem->sem_perm);
+	if (ret < 0)
+		return ret;
+
+	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
+
+	sem->sem_otime = h->sem_otime;
+	sem->sem_ctime = h->sem_ctime;
+	sem->sem_nsems = h->sem_nsems;
+
+	return 0;
+}
+
+/**
+ * ckpt_read_sem_array - read the state of a semaphore array
+ * @ctx: checkpoint context
+ * @sem: semphore array
+ *
+ * Expect the data in an array of 'struct sem': {32 bit, 32 bit}.
+ * See comment in ckpt_write_sem_array().
+ *
+ * The sem-undo information is not restored per ipc_ns, but rather per task.
+ */
+static struct sem *restore_sem_array(struct ckpt_ctx *ctx, int nsems)
+{
+	struct sem *sma;
+	int i, ret;
+
+	sma = kmalloc(nsems * sizeof(*sma), GFP_KERNEL);
+	if (!sma)
+		return ERR_PTR(-ENOMEM);
+	ret = _ckpt_read_buffer(ctx, sma, nsems * sizeof(*sma));
+	if (ret < 0)
+		goto out;
+
+	/* validate sem array contents */
+	for (i = 0; i < nsems; i++) {
+		if (sma[i].semval < 0 || sma[i].sempid < 0) {
+			ret = -EINVAL;
+			break;
+		}
+	}
+ out:
+	if (ret < 0) {
+		kfree(sma);
+		sma = ERR_PTR(ret);
+	}
+	return sma;
+}
+
+int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
+{
+	struct ckpt_hdr_ipc_sem *h;
+	struct kern_ipc_perm *ipc;
+	struct sem_array *sem;
+	struct sem *sma = NULL;
+	struct ipc_ids *sem_ids = &ns->ids[IPC_SEM_IDS];
+	int semflag, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_SEM);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->perms.id < 0)
+		goto out;
+	if (h->sem_nsems < 0)
+		goto out;
+
+	/* read sempahore array state */
+	sma = restore_sem_array(ctx, h->sem_nsems);
+	if (IS_ERR(sma)) {
+		ret = PTR_ERR(sma);
+		sma = NULL;
+		goto out;
+	}
+
+	/* restore the message queue now */
+	semflag = h->perms.mode | IPC_CREAT | IPC_EXCL;
+	ckpt_debug("sem: do_semget key %d flag %#x id %d\n",
+		 h->perms.key, semflag, h->perms.id);
+	ret = do_semget(ns, h->perms.key, h->sem_nsems, semflag, h->perms.id);
+	ckpt_debug("sem: do_semget ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	down_write(&sem_ids->rw_mutex);
+
+	/*
+	 * We are the sole owners/users of this brand new ipc-ns, so:
+	 *
+	 * 1) The semid could not have been deleted between its creation
+	 *   and taking the rw_mutex above.
+	 * 2) No unauthorized task will attempt to gain access to it,
+	 *   so it is safe to do away with ipc_lock(). This is useful
+	 *   because we can call functions that sleep.
+	 * 3) Likewise, we only restore the security bits further below,
+	 *   so it is safe to ignore this (theoretical only!) race.
+	 *
+	 * If/when we allow to restore the ipc state within the parent's
+	 * ipc-ns, we will need to re-examine this.
+	 */
+	ipc = ipc_lock(sem_ids, h->perms.id);
+	BUG_ON(IS_ERR(ipc));
+
+	sem = container_of(ipc, struct sem_array, sem_perm);
+	memcpy(sem->sem_base, sma, sem->sem_nsems * sizeof(*sma));
+
+	/* this is safe because no unauthorized access is possible */
+	ipc_unlock(ipc);
+
+	ret = load_ipc_sem_hdr(ctx, h, sem);
+	if (ret < 0) {
+		ipc_lock_by_ptr(&sem->sem_perm);
+		ckpt_debug("sem: need to remove (%d)\n", ret);
+		freeary(ns, ipc);
+		ipc_unlock(ipc);
+	}
+	up_write(&sem_ids->rw_mutex);
+ out:
+	kfree(sma);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/sem.c b/ipc/sem.c
index faed3a3..37da85e 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -93,7 +93,6 @@
 #define sem_checkid(sma, semid)	ipc_checkid(&sma->sem_perm, semid)
 
 static int newary(struct ipc_namespace *, struct ipc_params *, int);
-static void freeary(struct ipc_namespace *, struct kern_ipc_perm *);
 #ifdef CONFIG_PROC_FS
 static int sysvipc_sem_proc_show(struct seq_file *s, void *it);
 #endif
@@ -317,14 +316,12 @@ static inline int sem_more_checks(struct kern_ipc_perm *ipcp,
 	return 0;
 }
 
-int do_semget(key_t key, int nsems, int semflg, int req_id)
+int do_semget(struct ipc_namespace *ns, key_t key, int nsems,
+	      int semflg, int req_id)
 {
-	struct ipc_namespace *ns;
 	struct ipc_ops sem_ops;
 	struct ipc_params sem_params;
 
-	ns = current->nsproxy->ipc_ns;
-
 	if (nsems < 0 || nsems > ns->sc_semmsl)
 		return -EINVAL;
 
@@ -341,7 +338,7 @@ int do_semget(key_t key, int nsems, int semflg, int req_id)
 
 SYSCALL_DEFINE3(semget, key_t, key, int, nsems, int, semflg)
 {
-	return do_semget(key, nsems, semflg, -1);
+	return do_semget(current->nsproxy->ipc_ns, key, nsems, semflg, -1);
 }
 
 /*
@@ -574,7 +571,7 @@ static void free_un(struct rcu_head *head)
  * as a writer and the spinlock for this semaphore set hold. sem_ids.rw_mutex
  * remains locked on exit.
  */
-static void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
+void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
 {
 	struct sem_undo *un, *tu;
 	struct sem_queue *q, *tq;
diff --git a/ipc/util.h b/ipc/util.h
index 8a223f0..ba080de 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -193,6 +193,11 @@ void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 int do_msgget(struct ipc_namespace *ns, key_t key, int msgflg, int req_id);
 void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
+int do_semget(struct ipc_namespace *ns, key_t key, int nsems, int semflg,
+	      int req_id);
+void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
+
+
 #ifdef CONFIG_CHECKPOINT
 extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 				     struct kern_ipc_perm *perm);
@@ -205,6 +210,9 @@ extern int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns);
 
 extern int checkpoint_ipc_msg(int id, void *p, void *data);
 extern int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns);
+
+extern int checkpoint_ipc_sem(int id, void *p, void *data);
+extern int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns);
 #endif
 
 #endif
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
