Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E759A620023
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:17:07 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 57/96] c/r: save and restore sysvipc namespace basics
Date: Wed, 17 Mar 2010 12:08:45 -0400
Message-Id: <1268842164-5590-58-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-57-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add the helpers to checkpoint and restore the contents of 'struct
kern_ipc_perm'. Add header structures for ipc state. Put place-holders
to save and restore ipc state.

Save and restores the common state (parameters) of ipc namespace.

Generic code to iterate through the objects of sysvipc shared memory,
message queues and semaphores. The logic to save and restore the state
of these objects will be added in the next few patches.

Right now, we return -EPERM if the user calling sys_restart() isn't
allowed to create an object with the checkpointed uid.  We may prefer
to simply use the caller's uid in that case - but that could lead to
subtle userspace bugs?  Unsure, so going for the stricter behavior.

TODO: restore kern_ipc_perms->security.

Changelog[v20]:
  - Fix "scheduling while atomic" in ipc c/r
  - Cleanup: no need to restore perm->{id,key,seq}
  - Fix sysvipc=n compile
Changelog[v19]:
  - Restart to handle checkpoint images lacking {uts,ipc}-ns
Changelog[v19-rc3]:
  - ipc_objref should be s32 like all objrefs
Changelog[v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
  - [Serge Hallyn] Fix compile with !CONFIG_CHECKPOINT_DEBUG
Changelog[v17]:
  - Fix include: use checkpoint.h not checkpoint_hdr.h
  - Collect nsproxy->ipc_ns
  - Restore objects in the right namespace
  - If !CONFIG_IPC_NS only restore objects, not global settings
  - Don't overwrite global ipc-ns if !CONFIG_IPC_NS
  - Reset the checkpointed uid and gid info on ipc objects
  - Fix compilation with CONFIG_SYSVIPC=n
Changelog [Dan Smith <danms@us.ibm.com>]
  - Fix compilation with CONFIG_SYSVIPC=n
  - Update to match UTS changes

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/checkpoint.c          |    2 -
 checkpoint/objhash.c             |   28 +++
 include/linux/checkpoint.h       |   13 ++
 include/linux/checkpoint_hdr.h   |   60 +++++++
 include/linux/checkpoint_types.h |    1 +
 init/Kconfig                     |    6 +
 ipc/Makefile                     |    2 +-
 ipc/checkpoint.c                 |  340 ++++++++++++++++++++++++++++++++++++++
 ipc/namespace.c                  |    2 +-
 ipc/util.h                       |   10 +
 kernel/nsproxy.c                 |   16 ++-
 11 files changed, 475 insertions(+), 5 deletions(-)
 create mode 100644 ipc/checkpoint.c

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 2707978..4682889 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -264,8 +264,6 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	rcu_read_lock();
 	nsproxy = task_nsproxy(t);
-	if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns)
-		ret = -EPERM;
 	/* no support for >1 private mntns */
 	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns) {
 		_ckpt_err(ctx, -EPERM, "%(T)Nested mnt_ns unsupported\n");
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index a2cf082..abb2a5b 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -15,6 +15,8 @@
 #include <linux/hash.h>
 #include <linux/file.h>
 #include <linux/fdtable.h>
+#include <linux/sched.h>
+#include <linux/ipc_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -154,6 +156,22 @@ static int obj_uts_ns_users(void *ptr)
 	return atomic_read(&((struct uts_namespace *) ptr)->kref.refcount);
 }
 
+static int obj_ipc_ns_grab(void *ptr)
+{
+	get_ipc_ns((struct ipc_namespace *) ptr);
+	return 0;
+}
+
+static void obj_ipc_ns_drop(void *ptr, int lastref)
+{
+	put_ipc_ns((struct ipc_namespace *) ptr);
+}
+
+static int obj_ipc_ns_users(void *ptr)
+{
+	return atomic_read(&((struct ipc_namespace *) ptr)->count);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -219,6 +237,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_uts_ns,
 		.restore = restore_uts_ns,
 	},
+	/* ipc_ns object */
+	{
+		.obj_name = "IPC_NS",
+		.obj_type = CKPT_OBJ_IPC_NS,
+		.ref_drop = obj_ipc_ns_drop,
+		.ref_grab = obj_ipc_ns_grab,
+		.ref_users = obj_ipc_ns_users,
+		.checkpoint = checkpoint_ipc_ns,
+		.restore = restore_ipc_ns,
+	},
 };
 
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 9f2a7ba..ec0e13f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -25,6 +25,9 @@
 #ifdef __KERNEL__
 #ifdef CONFIG_CHECKPOINT
 
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/err.h>
@@ -173,6 +176,15 @@ extern void *restore_ns(struct ckpt_ctx *ctx);
 extern int checkpoint_uts_ns(struct ckpt_ctx *ctx, void *ptr);
 extern void *restore_uts_ns(struct ckpt_ctx *ctx);
 
+/* ipc-ns */
+#ifdef CONFIG_SYSVIPC
+extern int checkpoint_ipc_ns(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_ipc_ns(struct ckpt_ctx *ctx);
+#else
+#define checkpoint_ipc_ns  NULL
+#define restore_ipc_ns  NULL
+#endif /* CONFIG_SYSVIPC */
+
 /* file table */
 extern int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
@@ -246,6 +258,7 @@ static inline int ckpt_validate_errno(int errno)
 #define CKPT_DFILE	0x10		/* files and filesystem */
 #define CKPT_DMEM	0x20		/* memory state */
 #define CKPT_DPAGE	0x40		/* memory pages */
+#define CKPT_DIPC	0x80		/* sysvipc */
 
 #define CKPT_DDEFAULT	0xffff		/* default debug level */
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index dc2cadb..663c538 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -83,6 +83,8 @@ enum {
 #define CKPT_HDR_NS CKPT_HDR_NS
 	CKPT_HDR_UTS_NS,
 #define CKPT_HDR_UTS_NS CKPT_HDR_UTS_NS
+	CKPT_HDR_IPC_NS,
+#define CKPT_HDR_IPC_NS CKPT_HDR_IPC_NS
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -106,6 +108,15 @@ enum {
 	CKPT_HDR_MM_CONTEXT,
 #define CKPT_HDR_MM_CONTEXT CKPT_HDR_MM_CONTEXT
 
+	CKPT_HDR_IPC = 501,
+#define CKPT_HDR_IPC CKPT_HDR_IPC
+	CKPT_HDR_IPC_SHM,
+#define CKPT_HDR_IPC_SHM CKPT_HDR_IPC_SHM
+	CKPT_HDR_IPC_MSG,
+#define CKPT_HDR_IPC_MSG CKPT_HDR_IPC_MSG
+	CKPT_HDR_IPC_SEM,
+#define CKPT_HDR_IPC_SEM CKPT_HDR_IPC_SEM
+
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
 
@@ -144,6 +155,8 @@ enum obj_type {
 #define CKPT_OBJ_NS CKPT_OBJ_NS
 	CKPT_OBJ_UTS_NS,
 #define CKPT_OBJ_UTS_NS CKPT_OBJ_UTS_NS
+	CKPT_OBJ_IPC_NS,
+#define CKPT_OBJ_IPC_NS CKPT_OBJ_IPC_NS
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -240,6 +253,7 @@ struct ckpt_hdr_task_ns {
 struct ckpt_hdr_ns {
 	struct ckpt_hdr h;
 	__s32 uts_objref;
+	__s32 ipc_objref;
 } __attribute__((aligned(8)));
 
 /* cannot include <linux/tty.h> from userspace, so define: */
@@ -405,4 +419,50 @@ struct ckpt_hdr_pgarr {
 } __attribute__((aligned(8)));
 
 
+/* ipc commons */
+struct ckpt_hdr_ipcns {
+	struct ckpt_hdr h;
+	__u64 shm_ctlmax;
+	__u64 shm_ctlall;
+	__s32 shm_ctlmni;
+
+	__s32 msg_ctlmax;
+	__s32 msg_ctlmnb;
+	__s32 msg_ctlmni;
+
+	__s32 sem_ctl_msl;
+	__s32 sem_ctl_mns;
+	__s32 sem_ctl_opm;
+	__s32 sem_ctl_mni;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_ipc {
+	struct ckpt_hdr h;
+	__u32 ipc_type;
+	__u32 ipc_count;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_ipc_perms {
+	__s32 id;
+	__u32 key;
+	__u32 uid;
+	__u32 gid;
+	__u32 cuid;
+	__u32 cgid;
+	__u32 mode;
+	__u32 _padding;
+	__u64 seq;
+} __attribute__((aligned(8)));
+
+
+#define CKPT_TST_OVERFLOW_16(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
+
+#define CKPT_TST_OVERFLOW_32(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > INT_MAX))
+
+#define CKPT_TST_OVERFLOW_64(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
+
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index ee35488..49d5c09 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -24,6 +24,7 @@
 
 struct ckpt_stats {
 	int uts_ns;
+	int ipc_ns;
 };
 
 struct ckpt_ctx {
diff --git a/init/Kconfig b/init/Kconfig
index 4640375..fb43090 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -201,6 +201,12 @@ config SYSVIPC
 	  section 6.4 of the Linux Programmer's Guide, available from
 	  <http://www.tldp.org/guides.html>.
 
+config SYSVIPC_CHECKPOINT
+	bool
+	depends on SYSVIPC
+	depends on CHECKPOINT
+	default y
+
 config SYSVIPC_SYSCTL
 	bool
 	depends on SYSVIPC
diff --git a/ipc/Makefile b/ipc/Makefile
index 4e1955e..b747127 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,4 +9,4 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
-
+obj-$(CONFIG_SYSVIPC_CHECKPOINT) += checkpoint.o
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
new file mode 100644
index 0000000..4e6dd79
--- /dev/null
+++ b/ipc/checkpoint.c
@@ -0,0 +1,340 @@
+/*
+ *  Checkpoint logic and helpers
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
+#include <linux/ipc.h>
+#include <linux/msg.h>
+#include <linux/sched.h>
+#include <linux/ipc_namespace.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#include "util.h"
+
+/* for ckpt_debug */
+#ifdef CONFIG_CHECKPOINT_DEBUG
+static char *ipc_ind_to_str[] = { "sem", "msg", "shm" };
+#endif
+
+#define shm_ids(ns)	((ns)->ids[IPC_SHM_IDS])
+#define msg_ids(ns)	((ns)->ids[IPC_MSG_IDS])
+#define sem_ids(ns)	((ns)->ids[IPC_SEM_IDS])
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/*
+ * Requires that ids->rw_mutex be held; this is sufficient because:
+ *
+ * (a) The data accessed either may not change at all (e.g. id, key,
+ * sqe), or may only change by ipc_update_perm() (e.g. uid, cuid, gid,
+ * cgid, mode), which is only called with the mutex write-held.
+ *
+ * (b) The function ipcperms() relies solely on the latter (uid, vuid,
+ * gid, cgid, mode)
+ *
+ * (c) The security context perm->security also may only change when the
+ * mutex is taken.
+ */
+int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+			      struct kern_ipc_perm *perm)
+{
+	if (ipcperms(perm, S_IROTH))
+		return -EACCES;
+
+	h->id = perm->id;
+	h->key = perm->key;
+	h->uid = perm->uid;
+	h->gid = perm->gid;
+	h->cuid = perm->cuid;
+	h->cgid = perm->cgid;
+	h->mode = perm->mode & S_IRWXUGO;
+	h->seq = perm->seq;
+
+	return 0;
+}
+
+static int checkpoint_ipc_any(struct ckpt_ctx *ctx,
+			      struct ipc_namespace *ipc_ns,
+			      int ipc_ind, int ipc_type,
+			      int (*func)(int id, void *p, void *data))
+{
+	struct ckpt_hdr_ipc *h;
+	struct ipc_ids *ipc_ids = &ipc_ns->ids[ipc_ind];
+	int ret = -ENOMEM;
+
+	down_read(&ipc_ids->rw_mutex);
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC);
+	if (!h)
+		goto out;
+
+	h->ipc_type = ipc_type;
+	h->ipc_count = ipc_ids->in_use;
+	ckpt_debug("ipc-%s count %d\n", ipc_ind_to_str[ipc_ind], h->ipc_count);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		goto out;
+
+	ret = idr_for_each(&ipc_ids->ipcs_idr, func, ctx);
+	ckpt_debug("ipc-%s ret %d\n", ipc_ind_to_str[ipc_ind], ret);
+ out:
+	up_read(&ipc_ids->rw_mutex);
+	return ret;
+}
+
+static int do_checkpoint_ipc_ns(struct ckpt_ctx *ctx,
+				struct ipc_namespace *ipc_ns)
+{
+	struct ckpt_hdr_ipcns *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_NS);
+	if (!h)
+		return -ENOMEM;
+
+	down_read(&shm_ids(ipc_ns).rw_mutex);
+	h->shm_ctlmax = ipc_ns->shm_ctlmax;
+	h->shm_ctlall = ipc_ns->shm_ctlall;
+	h->shm_ctlmni = ipc_ns->shm_ctlmni;
+	up_read(&shm_ids(ipc_ns).rw_mutex);
+
+	down_read(&msg_ids(ipc_ns).rw_mutex);
+	h->msg_ctlmax = ipc_ns->msg_ctlmax;
+	h->msg_ctlmnb = ipc_ns->msg_ctlmnb;
+	h->msg_ctlmni = ipc_ns->msg_ctlmni;
+	up_read(&msg_ids(ipc_ns).rw_mutex);
+
+	down_read(&sem_ids(ipc_ns).rw_mutex);
+	h->sem_ctl_msl = ipc_ns->sem_ctls[0];
+	h->sem_ctl_mns = ipc_ns->sem_ctls[1];
+	h->sem_ctl_opm = ipc_ns->sem_ctls[2];
+	h->sem_ctl_mni = ipc_ns->sem_ctls[3];
+	up_read(&sem_ids(ipc_ns).rw_mutex);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+#if 0 /* NEXT FEW PATCHES */
+	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SHM_IDS,
+				 CKPT_HDR_IPC_SHM, checkpoint_ipc_shm);
+	if (ret < 0)
+		return ret;
+	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
+				 CKPT_HDR_IPC_MSG, checkpoint_ipc_msg);
+	if (ret < 0)
+		return ret;
+	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SEM_IDS,
+				 CKPT_HDR_IPC_SEM, checkpoint_ipc_sem);
+#endif
+	return ret;
+}
+
+int checkpoint_ipc_ns(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_ipc_ns(ctx, (struct ipc_namespace *) ptr);
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+/*
+ * check whether current task may create ipc object with
+ * checkpointed uids and gids.
+ * Return 1 if ok, 0 if not.
+ */
+static int validate_created_perms(struct ckpt_hdr_ipc_perms *h)
+{
+	const struct cred *cred = current_cred();
+	uid_t uid = cred->uid, euid = cred->euid;
+
+	/* actually I don't know - is CAP_IPC_OWNER the right one? */
+	if (((h->uid != uid && h->uid == euid) ||
+			(h->cuid != uid && h->cuid != euid) ||
+			!in_group_p(h->cgid) ||
+			!in_group_p(h->gid)) &&
+			!capable(CAP_IPC_OWNER))
+		return 0;
+	return 1;
+}
+
+/*
+ * Requires that ids->rw_mutex be held; this is sufficient because:
+ *
+ * (a) The data accessed either may only change by ipc_update_perm()
+ * or by security hooks (perm->security), all of which are only called
+ * with the mutex write-held.
+ *
+ * (b) During restart, we are guarantted to be using a brand new
+ * ipc-ns, only accessible to us, so there will be no attempt for
+ * access validation while we restore the state (by other tasks).
+ */
+int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+			   struct kern_ipc_perm *perm)
+{
+	if (h->id < 0)
+		return -EINVAL;
+	if (CKPT_TST_OVERFLOW_16(h->uid, perm->uid) ||
+	    CKPT_TST_OVERFLOW_16(h->gid, perm->gid) ||
+	    CKPT_TST_OVERFLOW_16(h->cuid, perm->cuid) ||
+	    CKPT_TST_OVERFLOW_16(h->cgid, perm->cgid) ||
+	    CKPT_TST_OVERFLOW_16(h->mode, perm->mode))
+		return -EINVAL;
+	if (h->seq >= USHORT_MAX)
+		return -EINVAL;
+	if (h->mode & ~S_IRWXUGO)
+		return -EINVAL;
+
+	/* FIX: verify the ->mode field makes sense */
+
+	if (!validate_created_perms(h))
+		return -EPERM;
+	perm->uid = h->uid;
+	perm->gid = h->gid;
+	perm->cuid = h->cuid;
+	perm->cgid = h->cgid;
+	perm->mode = h->mode;
+
+	/*
+	 * Todo: restore perm->security.
+	 * At the moment it gets set by security_x_alloc() called through
+	 * ipcget()->ipcget_public()->ops-.getnew (->nequeue for instance)
+	 * We will want to ask the LSM to consider resetting the
+	 * checkpointed ->security, based on current_security(),
+	 * the checkpointed ->security, and the checkpoint file context.
+	 */
+
+	return 0;
+}
+
+static int restore_ipc_any(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns,
+			   int ipc_ind, int ipc_type,
+			   int (*func)(struct ckpt_ctx *ctx,
+				       struct ipc_namespace *ns))
+{
+	struct ckpt_hdr_ipc *h;
+	int n, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("ipc-%s: count %d\n", ipc_ind_to_str[ipc_ind], h->ipc_count);
+
+	ret = -EINVAL;
+	if (h->ipc_type != ipc_type)
+		goto out;
+
+	ret = 0;
+	for (n = 0; n < h->ipc_count; n++) {
+		ret = (*func)(ctx, ipc_ns);
+		if (ret < 0)
+			goto out;
+	}
+ out:
+	ckpt_debug("ipc-%s: ret %d\n", ipc_ind_to_str[ipc_ind], ret);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static struct ipc_namespace *do_restore_ipc_ns(struct ckpt_ctx *ctx)
+{
+	struct ipc_namespace *ipc_ns = NULL;
+	struct ckpt_hdr_ipcns *h;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_NS);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	ret = -EINVAL;
+	if (h->shm_ctlmax < 0 || h->shm_ctlall < 0 || h->shm_ctlmni < 0)
+		goto out;
+	if (h->msg_ctlmax < 0 || h->msg_ctlmnb < 0 || h->msg_ctlmni < 0)
+		goto out;
+	if (h->sem_ctl_msl < 0 || h->sem_ctl_mns < 0 ||
+	    h->sem_ctl_opm < 0 || h->sem_ctl_mni < 0)
+		goto out;
+
+	/*
+	 * If !CONFIG_IPC_NS, do not restore the global IPC state, as
+	 * it is used by other processes. It is ok to try to restore
+	 * the {shm,msg,sem} objects: in the worst case the requested
+	 * identifiers will be in use.
+	 */
+#ifdef CONFIG_IPC_NS
+	ret = -ENOMEM;
+	ipc_ns = create_ipc_ns();
+	if (!ipc_ns)
+		goto out;
+
+	down_read(&shm_ids(ipc_ns).rw_mutex);
+	ipc_ns->shm_ctlmax = h->shm_ctlmax;
+	ipc_ns->shm_ctlall = h->shm_ctlall;
+	ipc_ns->shm_ctlmni = h->shm_ctlmni;
+	up_read(&shm_ids(ipc_ns).rw_mutex);
+
+	down_read(&msg_ids(ipc_ns).rw_mutex);
+	ipc_ns->msg_ctlmax = h->msg_ctlmax;
+	ipc_ns->msg_ctlmnb = h->msg_ctlmnb;
+	ipc_ns->msg_ctlmni = h->msg_ctlmni;
+	up_read(&msg_ids(ipc_ns).rw_mutex);
+
+	down_read(&sem_ids(ipc_ns).rw_mutex);
+	ipc_ns->sem_ctls[0] = h->sem_ctl_msl;
+	ipc_ns->sem_ctls[1] = h->sem_ctl_mns;
+	ipc_ns->sem_ctls[2] = h->sem_ctl_opm;
+	ipc_ns->sem_ctls[3] = h->sem_ctl_mni;
+	up_read(&sem_ids(ipc_ns).rw_mutex);
+#else
+	ret = -EEXIST;
+	/* complain if image contains multiple namespaces */
+	if (ctx->stats.ipc_ns)
+		goto out;
+	ipc_ns = current->nsproxy->ipc_ns;
+	get_ipc_ns(ipc_ns);
+#endif
+
+#if 0 /* NEXT FEW PATCHES */
+	ret = restore_ipc_any(ctx, ipc_ns, IPC_SHM_IDS,
+			      CKPT_HDR_IPC_SHM, restore_ipc_shm);
+	if (ret < 0)
+		goto out;
+	ret = restore_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
+			      CKPT_HDR_IPC_MSG, restore_ipc_msg);
+	if (ret < 0)
+		goto out;
+	ret = restore_ipc_any(ctx, ipc_ns, IPC_SEM_IDS,
+			      CKPT_HDR_IPC_SEM, restore_ipc_sem);
+#endif
+	if (ret < 0)
+		goto out;
+
+	ctx->stats.ipc_ns++;
+ out:
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0) {
+		put_ipc_ns(ipc_ns);
+		ipc_ns = ERR_PTR(ret);
+	}
+	return ipc_ns;
+}
+
+void *restore_ipc_ns(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_ipc_ns(ctx);
+}
diff --git a/ipc/namespace.c b/ipc/namespace.c
index a1094ff..8e5ea32 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -14,7 +14,7 @@
 
 #include "util.h"
 
-static struct ipc_namespace *create_ipc_ns(void)
+struct ipc_namespace *create_ipc_ns(void)
 {
 	struct ipc_namespace *ns;
 	int err;
diff --git a/ipc/util.h b/ipc/util.h
index 159a73c..8ae1f8e 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -12,6 +12,7 @@
 
 #include <linux/unistd.h>
 #include <linux/err.h>
+#include <linux/checkpoint.h>
 
 #define SEQ_MULTIPLIER	(IPCMNI)
 
@@ -175,4 +176,13 @@ int ipcget(struct ipc_namespace *ns, struct ipc_ids *ids,
 void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
 	       void (*free)(struct ipc_namespace *, struct kern_ipc_perm *));
 
+struct ipc_namespace *create_ipc_ns(void);
+
+#ifdef CONFIG_CHECKPOINT
+extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+				     struct kern_ipc_perm *perm);
+extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+				  struct kern_ipc_perm *perm);
+#endif
+
 #endif
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 90cba48..a2c1548 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -248,6 +248,7 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	ret = ckpt_obj_collect(ctx, nsproxy->uts_ns, CKPT_OBJ_UTS_NS);
 	if (ret < 0)
 		goto out;
+	ret = ckpt_obj_collect(ctx, nsproxy->ipc_ns, CKPT_OBJ_IPC_NS);
 
 	/* TODO: collect other namespaces here */
  out:
@@ -268,6 +269,11 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 	if (ret <= 0)
 		goto out;
 	h->uts_objref = ret;
+	ret = checkpoint_obj(ctx, nsproxy->ipc_ns, CKPT_OBJ_IPC_NS);
+	if (ret < 0)
+		goto out;
+	h->ipc_objref = ret;
+
 	/* TODO: Write other namespaces here */
 
 	ret = ckpt_write_obj(ctx, &h->h);
@@ -305,7 +311,15 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 		goto out;
 	}
 
-	ipc_ns = ctx->root_nsproxy->ipc_ns;
+	if (h->ipc_objref == 0)
+		ipc_ns = ctx->root_nsproxy->ipc_ns;
+	else
+		ipc_ns = ckpt_obj_fetch(ctx, h->ipc_objref, CKPT_OBJ_IPC_NS);
+	if (IS_ERR(ipc_ns)) {
+		ret = PTR_ERR(ipc_ns);
+		goto out;
+	}
+
 	mnt_ns = ctx->root_nsproxy->mnt_ns;
 	net_ns = ctx->root_nsproxy->net_ns;
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
