Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5A49362003E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:26:13 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 85/96] c/r: preliminary support mounts namespace
Date: Wed, 17 Mar 2010 12:09:13 -0400
Message-Id: <1268842164-5590-86-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-85-git-send-email-orenl@cs.columbia.edu>
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
 <1268842164-5590-82-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-83-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-84-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-85-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

We only allow c/r when all processes shared a single mounts ns.

We do intend to implement c/r of mounts and mounts namespaces in the
kernel.  It shouldn't be ugly or complicate locking to do so.  Just
haven't gotten around to it. A more complete solution is more than we
want to take on now for v19.

But we'd like as much as possible for everything which we don't
support, to not be checkpointable, since not doing so has in the past
invited slanderous accusations of being a toy implementation :)

Meanwhile, we get the following:
1) Checkpoint bails if not all tasks share the same mnt-ns
2) Leak detection works for full container checkpoint

On restart, all tasks inherit the same mnt-ns of the coordinator, by
default. A follow-up patch to user-cr will add a new switch to the
'restart' to request a CLONE_NEWMNT flag when creating the root-task
of the restart.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/objhash.c           |   25 +++++++++++++++++++++++++
 include/linux/checkpoint.h     |    2 +-
 include/linux/checkpoint_hdr.h |    4 ++++
 kernel/nsproxy.c               |   16 +++++++++++++---
 4 files changed, 43 insertions(+), 4 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 5c4749d..42998b2 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -19,6 +19,7 @@
 #include <linux/sched.h>
 #include <linux/ipc_namespace.h>
 #include <linux/user_namespace.h>
+#include <linux/mnt_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <net/sock.h>
@@ -214,6 +215,22 @@ static int obj_ipc_ns_users(void *ptr)
 	return atomic_read(&((struct ipc_namespace *) ptr)->count);
 }
 
+static int obj_mnt_ns_grab(void *ptr)
+{
+	get_mnt_ns((struct mnt_namespace *) ptr);
+	return 0;
+}
+
+static void obj_mnt_ns_drop(void *ptr, int lastref)
+{
+	put_mnt_ns((struct mnt_namespace *) ptr);
+}
+
+static int obj_mnt_ns_users(void *ptr)
+{
+	return atomic_read(&((struct mnt_namespace *) ptr)->count);
+}
+
 static int obj_cred_grab(void *ptr)
 {
 	get_cred((struct cred *) ptr);
@@ -411,6 +428,14 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_ipc_ns,
 		.restore = restore_ipc_ns,
 	},
+	/* mnt_ns object */
+	{
+		.obj_name = "MOUNTS NS",
+		.obj_type = CKPT_OBJ_MNT_NS,
+		.ref_grab = obj_mnt_ns_grab,
+		.ref_drop = obj_mnt_ns_drop,
+		.ref_users = obj_mnt_ns_users,
+	},
 	/* user_ns object */
 	{
 		.obj_name = "USER_NS",
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 3e0937a..64b4b8a 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,7 +10,7 @@
  *  distribution for more details.
  */
 
-#define CHECKPOINT_VERSION  4
+#define CHECKPOINT_VERSION  5
 
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4dc852d..28dfc36 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -90,6 +90,8 @@ enum {
 #define CKPT_HDR_UTS_NS CKPT_HDR_UTS_NS
 	CKPT_HDR_IPC_NS,
 #define CKPT_HDR_IPC_NS CKPT_HDR_IPC_NS
+	CKPT_HDR_MNT_NS,
+#define CKPT_HDR_MNT_NS CKPT_HDR_MNT_NS
 	CKPT_HDR_CAPABILITIES,
 #define CKPT_HDR_CAPABILITIES CKPT_HDR_CAPABILITIES
 	CKPT_HDR_USER_NS,
@@ -216,6 +218,8 @@ enum obj_type {
 #define CKPT_OBJ_UTS_NS CKPT_OBJ_UTS_NS
 	CKPT_OBJ_IPC_NS,
 #define CKPT_OBJ_IPC_NS CKPT_OBJ_IPC_NS
+	CKPT_OBJ_MNT_NS,
+#define CKPT_OBJ_MNT_NS CKPT_OBJ_MNT_NS
 	CKPT_OBJ_USER_NS,
 #define CKPT_OBJ_USER_NS CKPT_OBJ_USER_NS
 	CKPT_OBJ_CRED,
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 17b048e..0da0d83 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -255,10 +255,17 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	 * ipc_ns (shm) may keep references to files: if this is the
 	 * first time we see this ipc_ns (ret > 0), proceed inside.
 	 */
-	if (ret)
+	if (ret) {
 		ret = ckpt_collect_ipc_ns(ctx, nsproxy->ipc_ns);
+		if (ret < 0)
+			goto out;
+	}
 
-	/* TODO: collect other namespaces here */
+	ret = ckpt_obj_collect(ctx, nsproxy->mnt_ns, CKPT_OBJ_MNT_NS);
+	if (ret < 0)
+		goto out;
+
+	ret = 0;
  out:
 	put_nsproxy(nsproxy);
 	return ret;
@@ -282,7 +289,10 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 		goto out;
 	h->ipc_objref = ret;
 
-	/* TODO: Write other namespaces here */
+	/* FIXME: for now, only marked visited to pacify leaks */
+	ret = ckpt_obj_visit(ctx, nsproxy->mnt_ns, CKPT_OBJ_MNT_NS);
+	if (ret < 0)
+		goto out;
 
 	ret = ckpt_write_obj(ctx, &h->h);
  out:
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
