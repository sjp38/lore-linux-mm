Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E1F2162003F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:29:27 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 93/96] c/r: add generic LSM c/r support (v7)
Date: Wed, 17 Mar 2010 12:09:21 -0400
Message-Id: <1268842164-5590-94-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-93-git-send-email-orenl@cs.columbia.edu>
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
 <1268842164-5590-86-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-87-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-88-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-89-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-90-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-91-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-92-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-93-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: Serge E. Hallyn <serue@us.ibm.com>

Documentation/checkpoint/readme.txt begins:
"""
Application checkpoint/restart is the ability to save the state
of a running application so that it can later resume its execution
from the time at which it was checkpointed.
"""

This patch adds generic support for c/r of LSM credentials.  Support
for Smack and SELinux (and TOMOYO if appropriate) will be added later.
Capabilities is already supported through generic creds code.

This patch supports ipc_perm, msg_msg, cred (task) and file ->security
fields.  Inodes, superblocks, netif, and xfrm currently are restored
not through sys_restart() but through container creation, and so the
security fields should be done then as well.  Network should be added
when network c/r is added.

Briefly, all security fields must be exported by the LSM as a simple
null-terminated string.  They are checkpointed through the
security_checkpoint_obj() helper, because we must pass it an extra
sectype field.  Splitting SECURITY_OBJ_SEC into one type per object
type would not work because, in Smack, one void* security is used for
all object types.  But we must pass the sectype field because in
SELinux a different type of structure is stashed in each object type.

The RESTART_KEEP_LSM flag indicates that the LSM should
attempt to reuse checkpointed security labels.  It is always
invalid when the LSM at restart differs from that at checkpoint.
It is currently only usable for capabilities.

(For capabilities, restart without RESTART_KEEP_LSM is technically
not implemented.  There actually might be a use case for that,
but the safety of it is dubious so for now we always re-create
checkpointed capability sets whether RESTART_KEEP_LSM is
specified or not)

Changelog[v20]
  - [Serge Hallyn] Fix unlabeled restore case
  - [Serge Hallyn] Always restore msg_msg label
  - [Serge Hallyn] Selinux prevents msgrcv on restore message queues?
Changelog:
        sep 3: fix memory leak on LSM restore error path
        Sep 3: provide 2 hooks, may_restart and checkpoint_header, to facilitate
                an LSM tracking policy changes.
        sep 10: merge RESTART_KEEP_LSM patch with basic LSM c/r
                support patches.
        sep 10: rename security_xyz_get_ctx() to security_xyz_checkpoint(),
                in order to avoid confusing with the various other 'context'
                helpers in the security_ namespace, relating to secids and
                sysfs xattrs.
        sep 10: pass context file to security_cred_restore.  SELinux will
                want the file's security context to authorize it as an
                entrypoint for the new process context.
        oct 01: roll up some generic c/r debug hunks from selinux patch.
        oct 05: address set of Oren comments, including:
                1. fix memleak in restore_msg_contents_one
                2. use a separate container checkpoint image section
                3. define SECURITY_CTX_NONE
                4. allocate the right size to l in security_checkpoint_obj
                5. fix ckpt_hdr_lsm alignment
        oct 09: at checkpoint, key on the void*security in the objhash,
                and don't cache the ckpt_stored_lsm at all.  At restart,
                do_restore_security (now moved to security/security.c)
                creates and caches the ckpt_stored_lsm.
	oct 19: At checkpoint, we insert the void* security into the
		objhash.  The first time that we do so, we next write out
		the string representation of the context to the checkpoint
		image, along with the value of the objref for the void*
		security, and insert that into the objhash.  Then at
		restart, when we read a LSM context, we read the objref
		which the void* security had at checkpoint, and we then
		insert the string context with that objref as well.
	oct 19: Address a bunch of Oren comments: add ckpt_write_err()s,
		more commenting, use -ENOSYS not -EOPNOTSUPP.  The biggest
		change is always failing restart when RESTART_KEEP_LSM is
		used but one of the security_XYZ_restore() returns -ENOSYS.
	oct 20: SECURITY_CTX_NONE becomes 0 (from -1) and security_checkpoint_obj
		returns an objref or SECURITY_CTX_NONE on success.
	nov 11: update ckpt_write_err->ckpt_err.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/files.c               |   31 ++++++-
 checkpoint/objhash.c             |  129 +++++++++++++++++++++++++
 include/linux/checkpoint.h       |    4 +
 include/linux/checkpoint_hdr.h   |   19 ++++
 include/linux/checkpoint_types.h |    8 ++
 include/linux/security.h         |  170 +++++++++++++++++++++++++++++++++
 ipc/checkpoint.c                 |   26 +++---
 ipc/checkpoint_msg.c             |   25 ++++-
 ipc/checkpoint_sem.c             |    4 +-
 ipc/checkpoint_shm.c             |    4 +-
 ipc/util.h                       |    6 +-
 kernel/cred.c                    |   28 +++++-
 security/capability.c            |   48 ++++++++++
 security/security.c              |  193 ++++++++++++++++++++++++++++++++++++++
 14 files changed, 668 insertions(+), 27 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 7855bae..55c5eb3 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -151,6 +151,19 @@ static int scan_fds(struct files_struct *files, int **fdtable)
 	return n;
 }
 
+#ifdef CONFIG_SECURITY
+int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
+{
+	return security_checkpoint_obj(ctx, file->f_security,
+				       CKPT_SECURITY_FILE);
+}
+#else
+int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
+{
+	return SECURITY_CTX_NONE;
+}
+#endif
+
 int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 			   struct ckpt_hdr_file *h)
 {
@@ -165,8 +178,14 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 	if (h->f_credref < 0)
 		return h->f_credref;
 
-	ckpt_debug("file %s credref %d", file->f_dentry->d_name.name,
-		h->f_credref);
+	h->f_secref = checkpoint_file_security(ctx, file);
+	if (h->f_secref < 0) {
+		ckpt_err(ctx, h->f_secref, "%(T)file->f_security");
+		return h->f_secref;
+	}
+
+	ckpt_debug("file %s credref %d secref %d\n",
+		file->f_dentry->d_name.name, h->f_credref, h->f_secref);
 
 	/* FIX: need also file->f_owner, etc */
 
@@ -630,6 +649,14 @@ int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 	put_cred(file->f_cred);
 	file->f_cred = get_cred(cred);
 
+	ret = security_restore_obj(ctx, (void *) file, CKPT_SECURITY_FILE,
+				   h->f_secref);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "file secref %(O)%(P)\n", h->f_secref,
+			 file);
+		return ret;
+	}
+
 	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
 	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
 	if (ret < 0)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 42998b2..7208382 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -17,6 +17,7 @@
 #include <linux/fdtable.h>
 #include <linux/fs_struct.h>
 #include <linux/sched.h>
+#include <linux/kref.h>
 #include <linux/ipc_namespace.h>
 #include <linux/user_namespace.h>
 #include <linux/mnt_namespace.h>
@@ -326,6 +327,36 @@ static int obj_tty_users(void *ptr)
 	return atomic_read(&((struct tty_struct *) ptr)->kref.refcount);
 }
 
+void lsm_string_free(struct kref *kref)
+{
+	struct ckpt_lsm_string *s = container_of(kref, struct ckpt_lsm_string,
+					kref);
+	kfree(s->string);
+	kfree(s);
+}
+
+static int lsm_string_grab(void *ptr)
+{
+	struct ckpt_lsm_string *s = ptr;
+	kref_get(&s->kref);
+	return 0;
+}
+
+static void lsm_string_drop(void *ptr, int lastref)
+{
+	struct ckpt_lsm_string *s = ptr;
+	kref_put(&s->kref, lsm_string_free);
+}
+
+/* security context strings */
+static int checkpoint_lsm_string(struct ckpt_ctx *ctx, void *ptr);
+static struct ckpt_lsm_string *restore_lsm_string(struct ckpt_ctx *ctx);
+static void *restore_lsm_string_wrap(struct ckpt_ctx *ctx)
+{
+	return (void *)restore_lsm_string(ctx);
+}
+
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -492,6 +523,33 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_tty,
 		.restore = restore_tty,
 	},
+	/*
+	 * LSM void *security on objhash - at checkpoint
+	 * We don't take a ref because we won't be doing
+	 * anything more with this void* - unless we happen
+	 * to run into it again through some other objects's
+	 * ->security (in which case that object has it pinned).
+	 */
+	{
+		.obj_name = "SECURITY PTR",
+		.obj_type = CKPT_OBJ_SECURITY_PTR,
+		.ref_drop = obj_no_drop,
+		.ref_grab = obj_no_grab,
+	},
+	/*
+	 * LSM security strings - at restart
+	 * This is a struct which we malloc during restart and
+	 * must be freed (by objhash cleanup) at the end of
+	 * restart
+	 */
+	{
+		.obj_name = "SECURITY STRING",
+		.obj_type = CKPT_OBJ_SECURITY,
+		.ref_grab = lsm_string_grab,
+		.ref_drop = lsm_string_drop,
+		.checkpoint = checkpoint_lsm_string,
+		.restore = restore_lsm_string_wrap,
+	},
 };
 
 
@@ -1088,3 +1146,74 @@ void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
 	return ret;
 }
 EXPORT_SYMBOL(ckpt_obj_fetch);
+
+/*
+ * checkpoint a security context string.  This is done by
+ * security/security.c:security_checkpoint_obj() when it checkpoints
+ * a void*security whose context string has not yet been written out.
+ * The objref for the void*security (which is not itself written out
+ * to the checkpoint image) is stored alongside the context string,
+ * as is the type of object which contained the void* security, i.e.
+ * struct file, struct cred, etc.
+ */
+static int checkpoint_lsm_string(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_hdr_lsm *h;
+	struct ckpt_lsm_string *l = ptr;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SECURITY);
+	if (!h)
+		return -ENOMEM;
+	h->sectype = l->sectype;
+	h->ptrref = l->ptrref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	if (ret < 0)
+		return ret;
+	return ckpt_write_string(ctx, l->string, strlen(l->string)+1);
+}
+
+/*
+ * callback invoked when a security context string is found in a
+ * checkpoint image at restart.  The context string is saved in the object
+ * hash.  The objref under which the void* security was inserted in the
+ * objhash at checkpoint is also found here, and we re-insert this context
+ * string a second time under that objref.  This is because objects which
+ * had this context will have the objref of the void*security, not of the
+ * context string.
+ */
+static struct ckpt_lsm_string *restore_lsm_string(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_lsm *h;
+	struct ckpt_lsm_string *l;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SECURITY);
+	if (IS_ERR(h)) {
+		ckpt_debug("ckpt_read_obj_type returned %ld\n", PTR_ERR(h));
+		return ERR_PTR(PTR_ERR(h));
+	}
+
+	l = kzalloc(sizeof(*l), GFP_KERNEL);
+	if (!l) {
+		l = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	l->string = ckpt_read_string(ctx, CKPT_LSM_STRING_MAX);
+	if (IS_ERR(l->string)) {
+		void *s = l->string;
+		ckpt_debug("ckpt_read_string returned %ld\n", PTR_ERR(s));
+		kfree(l);
+		l = s;
+		goto out;
+	}
+	kref_init(&l->kref);
+	l->sectype = h->sectype;
+	/* l is just a placeholder, don't grab a ref */
+	ckpt_obj_insert(ctx, l, h->ptrref, CKPT_OBJ_SECURITY);
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return l;
+}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 70198f9..792b523 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -64,6 +64,7 @@ extern long do_sys_restart(pid_t pid, int fd,
 	 RESTART_CONN_RESET)
 
 #define CKPT_LSM_INFO_LEN 200
+#define CKPT_LSM_STRING_MAX 1024
 
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
@@ -107,6 +108,9 @@ extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
 extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
 extern struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid);
 
+/* defined in objhash.c and also used in security/security.c */
+extern void lsm_string_free(struct kref *kref);
+
 /* socket functions */
 extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 			      struct socket *socket,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index fad955f..41412d1 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -80,6 +80,8 @@ enum {
 #define CKPT_HDR_OBJREF CKPT_HDR_OBJREF
 	CKPT_HDR_LSM_INFO,
 #define CKPT_HDR_LSM_INFO CKPT_HDR_LSM_INFO
+	CKPT_HDR_SECURITY,
+#define CKPT_HDR_SECURITY CKPT_HDR_SECURITY
 
 	CKPT_HDR_TREE = 101,
 #define CKPT_HDR_TREE CKPT_HDR_TREE
@@ -247,6 +249,10 @@ enum obj_type {
 #define CKPT_OBJ_SOCK CKPT_OBJ_SOCK
 	CKPT_OBJ_TTY,
 #define CKPT_OBJ_TTY CKPT_OBJ_TTY
+	CKPT_OBJ_SECURITY_PTR,
+#define CKPT_OBJ_SECURITY_PTR CKPT_OBJ_SECURITY_PTR
+	CKPT_OBJ_SECURITY,
+#define CKPT_OBJ_SECURITY CKPT_OBJ_SECURITY
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -376,6 +382,7 @@ struct ckpt_hdr_cred {
 	__u32 gid, sgid, egid, fsgid;
 	__s32 user_ref;
 	__s32 groupinfo_ref;
+	__s32 sec_ref;
 	struct ckpt_capabilities cap_s;
 } __attribute__((aligned(8)));
 
@@ -388,6 +395,15 @@ struct ckpt_hdr_groupinfo {
 	__u32 groups[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_lsm {
+	struct ckpt_hdr h;
+	__s32 ptrref;
+	__u8 sectype;
+	/*
+	 * This is followed by a string of size len+1,
+	 * null-terminated
+	 */
+} __attribute__((aligned(8)));
 /*
  * todo - keyrings and LSM
  * These may be better done with userspace help though
@@ -532,6 +548,7 @@ struct ckpt_hdr_file {
 	__s32 f_credref;
 	__u64 f_pos;
 	__u64 f_version;
+	__s32 f_secref;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_file_generic {
@@ -924,6 +941,7 @@ struct ckpt_hdr_ipc_perms {
 	__u32 mode;
 	__u32 _padding;
 	__u64 seq;
+	__s32 sec_ref;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_shm {
@@ -957,6 +975,7 @@ struct ckpt_hdr_ipc_msg_msg {
 	struct ckpt_hdr h;
 	__s64 m_type;
 	__u32 m_ts;
+	__s32 sec_ref;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_sem {
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index efd34b6..ecd3e91 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -97,6 +97,14 @@ struct ckpt_ctx {
 #endif
 };
 
+/* stored on hashtable */
+struct ckpt_lsm_string {
+	struct kref kref;
+	int sectype;			/* Containing object (file,cred,&c) */
+	int ptrref;			/* the objref for the void* security */
+	char *string;
+};
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_CHECKPOINT_TYPES_H_ */
diff --git a/include/linux/security.h b/include/linux/security.h
index 980c942..de860ed 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -43,6 +43,9 @@
 #define SECURITY_CAP_NOAUDIT 0
 #define SECURITY_CAP_AUDIT 1
 
+/* checkpoint 'N/A' in a checkpoint image for a security context */
+#define SECURITY_CTX_NONE 0
+
 struct ctl_table;
 struct audit_krule;
 
@@ -604,6 +607,15 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	created.
  *	@file contains the file structure to secure.
  *	Return 0 if the hook is successful and permission is granted.
+ * @file_checkpoint:
+ *	Return a string representing the security context on a file.
+ *	@security contains the security field.
+ *	Returns a char* which the caller will free, or -error on error.
+ * @file_restore:
+ *	Set a security context on a file according to the checkpointed context.
+ *	@file contains the file.
+ *	@ctx contains a string representation of the checkpointed context.
+ *	Returns 0 on success, -error on failure.
  * @file_free_security:
  *	Deallocate and free any security structures stored in file->f_security.
  *	@file contains the file structure being modified.
@@ -688,6 +700,17 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@gfp indicates the atomicity of any memory allocations.
  *	Only allocate sufficient memory and attach to @cred such that
  *	cred_transfer() will not get ENOMEM.
+ * @cred_checkpoint:
+ *	Return a string representing the security context on the task cred.
+ *	@security contains the security field.
+ *	Returns a char* which the caller will free, or -error on error.
+ * @cred_restore:
+ *	Set a security context on a task cred according to the checkpointed
+ *	context.
+ *	@file contains the checkpoint file
+ *	@cred contains the cred.
+ *	@ctx contains a string representation of the checkpointed context.
+ *	Returns 0 on success, -error on failure.
  * @cred_free:
  *	@cred points to the credentials.
  *	Deallocate and clear the cred->security field in a set of credentials.
@@ -1163,6 +1186,19 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@ipcp contains the kernel IPC permission structure.
  *	@secid contains a pointer to the location where result will be saved.
  *	In case of failure, @secid will be set to zero.
+ * @ipc_checkpoint:
+ *	Return a string representing the security context on the IPC
+ *	permission structure.
+ *	@security contains the security field.
+ *	Returns a char* which the caller will free, or -error on error.
+ * @ipc_restore:
+ *	Set a security context on a IPC permission structure according to
+ *	the checkpointed context.
+ *	@ipcp contains the IPC permission structure, which will have
+ *	already been allocated and initialized when the IPC structure was
+ *	created.
+ *	@ctx contains a string representation of the checkpointed context.
+ *	Returns 0 on success, -error on failure.
  *
  * Security hooks for individual messages held in System V IPC message queues
  * @msg_msg_alloc_security:
@@ -1171,6 +1207,16 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	created.
  *	@msg contains the message structure to be modified.
  *	Return 0 if operation was successful and permission is granted.
+ * @msg_msg_checkpoint:
+ *	Return a string representing the security context on an msg_msg
+ *	struct.
+ *	@security contains the security field
+ *	Returns a char* which the caller will free, or -error on error.
+ * @msg_msg_restore:
+ *	Set msg_msg->security according to the checkpointed context.
+ *	@msg contains the message structure to be modified.
+ *	@ctx contains a string representation of the checkpointed context.
+ *	Return 0 on success, -error on failure.
  * @msg_msg_free_security:
  *	Deallocate the security structure for this message.
  *	@msg contains the message structure to be modified.
@@ -1586,6 +1632,8 @@ struct security_operations {
 
 	int (*file_permission) (struct file *file, int mask);
 	int (*file_alloc_security) (struct file *file);
+	char *(*file_checkpoint) (void *security);
+	int (*file_restore) (struct file *file, char *ctx);
 	void (*file_free_security) (struct file *file);
 	int (*file_ioctl) (struct file *file, unsigned int cmd,
 			   unsigned long arg);
@@ -1607,6 +1655,10 @@ struct security_operations {
 
 	int (*task_create) (unsigned long clone_flags);
 	int (*cred_alloc_blank) (struct cred *cred, gfp_t gfp);
+
+	char *(*cred_checkpoint) (void *security);
+	int (*cred_restore) (struct file *file, struct cred *cred, char *ctx);
+
 	void (*cred_free) (struct cred *cred);
 	int (*cred_prepare)(struct cred *new, const struct cred *old,
 			    gfp_t gfp);
@@ -1642,8 +1694,12 @@ struct security_operations {
 
 	int (*ipc_permission) (struct kern_ipc_perm *ipcp, short flag);
 	void (*ipc_getsecid) (struct kern_ipc_perm *ipcp, u32 *secid);
+	char *(*ipc_checkpoint) (void *security);
+	int (*ipc_restore) (struct kern_ipc_perm *ipcp, char *ctx);
 
 	int (*msg_msg_alloc_security) (struct msg_msg *msg);
+	char *(*msg_msg_checkpoint) (void *security);
+	int (*msg_msg_restore) (struct msg_msg *msg, char *ctx);
 	void (*msg_msg_free_security) (struct msg_msg *msg);
 
 	int (*msg_queue_alloc_security) (struct msg_queue *msq);
@@ -1862,6 +1918,8 @@ int security_inode_listsecurity(struct inode *inode, char *buffer, size_t buffer
 void security_inode_getsecid(const struct inode *inode, u32 *secid);
 int security_file_permission(struct file *file, int mask);
 int security_file_alloc(struct file *file);
+char *security_file_checkpoint(void *security);
+int security_file_restore(struct file *file, char *ctx);
 void security_file_free(struct file *file);
 int security_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
 int security_file_mmap(struct file *file, unsigned long reqprot,
@@ -1878,6 +1936,8 @@ int security_file_receive(struct file *file);
 int security_dentry_open(struct file *file, const struct cred *cred);
 int security_task_create(unsigned long clone_flags);
 int security_cred_alloc_blank(struct cred *cred, gfp_t gfp);
+char *security_cred_checkpoint(void *security);
+int security_cred_restore(struct file *file, struct cred *cred, char *ctx);
 void security_cred_free(struct cred *cred);
 int security_prepare_creds(struct cred *new, const struct cred *old, gfp_t gfp);
 void security_commit_creds(struct cred *new, const struct cred *old);
@@ -1910,7 +1970,11 @@ int security_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 void security_task_to_inode(struct task_struct *p, struct inode *inode);
 int security_ipc_permission(struct kern_ipc_perm *ipcp, short flag);
 void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid);
+char *security_ipc_checkpoint(void *security);
+int security_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx);
 int security_msg_msg_alloc(struct msg_msg *msg);
+char *security_msg_msg_checkpoint(void *security);
+int security_msg_msg_restore(struct msg_msg *msg, char *ctx);
 void security_msg_msg_free(struct msg_msg *msg);
 int security_msg_queue_alloc(struct msg_queue *msq);
 void security_msg_queue_free(struct msg_queue *msq);
@@ -2363,6 +2427,19 @@ static inline int security_file_alloc(struct file *file)
 	return 0;
 }
 
+static inline char *security_file_checkpoint(void *security)
+{
+	/* this shouldn't ever get called if SECURITY=n */
+	return ERR_PTR(-EINVAL);
+}
+
+static inline int security_file_restore(struct file *file, char *ctx)
+{
+	/* we're asked to recreate security contexts for an LSM which had
+	 * contexts, but CONFIG_SECURITY=n now! */
+	return -EINVAL;
+}
+
 static inline void security_file_free(struct file *file)
 { }
 
@@ -2432,6 +2509,20 @@ static inline int security_cred_alloc_blank(struct cred *cred, gfp_t gfp)
 	return 0;
 }
 
+static inline char *security_cred_checkpoint(void *security)
+{
+	/* this shouldn't ever get called if SECURITY=n */
+	return ERR_PTR(-EINVAL);
+}
+
+static inline int security_cred_restore(struct file *file, struct cred *cred,
+					char *ctx)
+{
+	/* we're asked to recreate security contexts for an LSM which had
+	 * contexts, but CONFIG_SECURITY=n now! */
+	return -EINVAL;
+}
+
 static inline void security_cred_free(struct cred *cred)
 { }
 
@@ -2584,11 +2675,37 @@ static inline void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
 	*secid = 0;
 }
 
+static inline char *security_ipc_checkpoint(void *security)
+{
+	/* this shouldn't ever get called if SECURITY=n */
+	return ERR_PTR(-EINVAL);
+}
+
+static inline int security_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	/* we're asked to recreate security contexts for an LSM which had
+	 * contexts, but CONFIG_SECURITY=n now! */
+	return -EINVAL;
+}
+
 static inline int security_msg_msg_alloc(struct msg_msg *msg)
 {
 	return 0;
 }
 
+static inline char *security_msg_msg_checkpoint(void *security)
+{
+	/* this shouldn't ever get called if SECURITY=n */
+	return ERR_PTR(-EINVAL);
+}
+
+static inline int security_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	/* we're asked to recreate security contexts for an LSM which had
+	 * contexts, but CONFIG_SECURITY=n now! */
+	return -EINVAL;
+}
+
 static inline void security_msg_msg_free(struct msg_msg *msg)
 { }
 
@@ -3247,5 +3364,58 @@ static inline void free_secdata(void *secdata)
 { }
 #endif /* CONFIG_SECURITY */
 
+#ifdef CONFIG_CHECKPOINT
+#define CKPT_SECURITY_MSG_MSG	1
+#define CKPT_SECURITY_IPC	2
+#define CKPT_SECURITY_FILE	3
+#define CKPT_SECURITY_CRED	4
+#define CKPT_SECURITY_MAX	4
+
+#ifdef CONFIG_SECURITY
+/*
+ * @security_checkpoint_obj:
+ *	Checkpoint a LSM security context.  The context is written out
+ *	as a string.  A positive integer objref uniquely representing the
+ *	security context in this checkpoint image will be returned.
+ *	If the security context has already been written out, then the
+ *	objref of that already written-out context will be used.
+ *	@ctx: the checkpoint context.
+ *	@security: the void*security being checkpointed.
+ *	@sectype: represents the type of object which contained the
+ *		void *security.
+ *	Return 0 or a valid objref on success, or -error on error.
+ */
+int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security, int sectype);
+/*
+ * @security_restore_obj:
+ *	Re-create a checkpointed LSM security context.  The LSM will decide
+ *	based upon the string representation which actual security context
+ *	to assign.
+ *	@ctx: the checkpoint context.
+ *	@obj: The object containing the security context to be restored (cast
+ *	to a void *).
+ *	@sectype: represents the type of object which contained the
+ *		void *security.
+ *	@secref: an integer objref for the string representation of the
+ *		security context to be restored.
+ *	Return 0 on success, or -error on error.
+ */
+int security_restore_obj(struct ckpt_ctx *ctx, void *obj,
+				int sectype, int secref);
+#else
+static inline int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
+				int sectype)
+{
+	return SECURITY_CTX_NONE;
+}
+static inline int security_restore_obj(struct ckpt_ctx *ctx, void *obj,
+				int sectype, int secref)
+{
+	return 0;
+}
+#endif /* CONFIG_SECURITY */
+
+#endif /* CONFIG_CHECKPOINT */
+
 #endif /* ! __LINUX_SECURITY_H */
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 4e7ac81..ca181ae 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -46,7 +46,8 @@ static char *ipc_ind_to_str[] = { "sem", "msg", "shm" };
  * (c) The security context perm->security also may only change when the
  * mutex is taken.
  */
-int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
+			      struct ckpt_hdr_ipc_perms *h,
 			      struct kern_ipc_perm *perm)
 {
 	if (ipcperms(perm, S_IROTH))
@@ -61,6 +62,13 @@ int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 	h->mode = perm->mode & S_IRWXUGO;
 	h->seq = perm->seq;
 
+	h->sec_ref = security_checkpoint_obj(ctx, perm->security,
+					     CKPT_SECURITY_IPC);
+	if (h->sec_ref < 0) {
+		ckpt_err(ctx, h->sec_ref, "%(T)ipc_perm->security\n");
+		return h->sec_ref;
+	}
+
 	return 0;
 }
 
@@ -202,7 +210,8 @@ static int validate_created_perms(struct ckpt_hdr_ipc_perms *h)
  * ipc-ns, only accessible to us, so there will be no attempt for
  * access validation while we restore the state (by other tasks).
  */
-int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+int restore_load_ipc_perms(struct ckpt_ctx *ctx,
+			   struct ckpt_hdr_ipc_perms *h,
 			   struct kern_ipc_perm *perm)
 {
 	if (h->id < 0)
@@ -228,16 +237,9 @@ int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 	perm->cgid = h->cgid;
 	perm->mode = h->mode;
 
-	/*
-	 * Todo: restore perm->security.
-	 * At the moment it gets set by security_x_alloc() called through
-	 * ipcget()->ipcget_public()->ops-.getnew (->nequeue for instance)
-	 * We will want to ask the LSM to consider resetting the
-	 * checkpointed ->security, based on current_security(),
-	 * the checkpointed ->security, and the checkpoint file context.
-	 */
-
-	return 0;
+	return security_restore_obj(ctx, (void *)perm,
+				    CKPT_SECURITY_IPC,
+				    h->sec_ref);
 }
 
 static int restore_ipc_any(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns,
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index 16ebbb5..e461991 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -36,7 +36,7 @@ static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
 {
 	int ret;
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &msq->q_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &msq->q_perm);
 	if (ret < 0)
 		return ret;
 
@@ -62,14 +62,21 @@ static int checkpoint_msg_contents(struct ckpt_ctx *ctx, struct msg_msg *msg)
 	struct ckpt_hdr_ipc_msg_msg *h;
 	struct msg_msgseg *seg;
 	int total, len;
-	int ret;
+	int secref, ret;
 
+	secref = security_checkpoint_obj(ctx, msg->security,
+				      CKPT_SECURITY_MSG_MSG);
+	if (secref < 0) {
+		ckpt_err(ctx, secref, "%(T)msg_msg->security");
+		return secref;
+	}
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG_MSG);
 	if (!h)
 		return -ENOMEM;
 
 	h->m_type = msg->m_type;
 	h->m_ts = msg->m_ts;
+	h->sec_ref = secref;
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -178,7 +185,7 @@ static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
 {
 	int ret = 0;
 
-	ret = restore_load_ipc_perms(&h->perms, &msq->q_perm);
+	ret = restore_load_ipc_perms(ctx, &h->perms, &msq->q_perm);
 	if (ret < 0)
 		return ret;
 
@@ -225,6 +232,17 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 	msg->next = NULL;
 	pseg = &msg->next;
 
+	/* set default MAC attributes */
+	ret = security_msg_msg_alloc(msg);
+	if (ret < 0)
+		goto out;
+
+	/* if requested and allowed, reset checkpointed MAC attributes */
+	ret = security_restore_obj(ctx, (void *) msg, CKPT_SECURITY_MSG_MSG,
+				   h->sec_ref);
+	if (ret < 0)
+		goto out;
+
 	ret = _ckpt_read_buffer(ctx, (msg + 1), len);
 	if (ret < 0)
 		goto out;
@@ -250,7 +268,6 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 	msg->m_type = h->m_type;
 	msg->m_ts = h->m_ts;
 	*clen = h->m_ts;
-	ret = security_msg_msg_alloc(msg);
  out:
 	if (ret < 0 && msg) {
 		free_msg(msg);
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index a1a4356..890374d 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -36,7 +36,7 @@ static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
 {
 	int ret = 0;
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &sem->sem_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &sem->sem_perm);
 	if (ret < 0)
 		return ret;
 
@@ -114,7 +114,7 @@ static int load_ipc_sem_hdr(struct ckpt_ctx *ctx,
 {
 	int ret = 0;
 
-	ret = restore_load_ipc_perms(&h->perms, &sem->sem_perm);
+	ret = restore_load_ipc_perms(ctx, &h->perms, &sem->sem_perm);
 	if (ret < 0)
 		return ret;
 
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index cb26633..bfba5dc 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -40,7 +40,7 @@ static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 {
 	int ret = 0;
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &shp->shm_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &shp->shm_perm);
 	if (ret < 0)
 		return ret;
 
@@ -177,7 +177,7 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 {
 	int ret;
 
-	ret = restore_load_ipc_perms(&h->perms, &shp->shm_perm);
+	ret = restore_load_ipc_perms(ctx, &h->perms, &shp->shm_perm);
 	if (ret < 0)
 		return ret;
 
diff --git a/ipc/util.h b/ipc/util.h
index ba080de..ce34de0 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -199,9 +199,11 @@ void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
 
 #ifdef CONFIG_CHECKPOINT
-extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+extern int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
+				     struct ckpt_hdr_ipc_perms *h,
 				     struct kern_ipc_perm *perm);
-extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+extern int restore_load_ipc_perms(struct ckpt_ctx *ctx,
+				  struct ckpt_hdr_ipc_perms *h,
 				  struct kern_ipc_perm *perm);
 
 extern int ckpt_collect_ipc_shm(int id, void *p, void *data);
diff --git a/kernel/cred.c b/kernel/cred.c
index 68f69b5..53b6663 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -1007,10 +1007,22 @@ int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
 }
 
 #ifdef CONFIG_CHECKPOINT
+#ifdef CONFIG_SECURITY
+int checkpoint_cred_security(struct ckpt_ctx *ctx, struct cred *cred)
+{
+	return security_checkpoint_obj(ctx, cred->security, CKPT_SECURITY_CRED);
+}
+#else
+int checkpoint_cred_security(struct ckpt_ctx *ctx, struct cred *cred)
+{
+	return SECURITY_CTX_NONE;
+}
+#endif
+
 static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 {
 	int ret;
-	int groupinfo_ref, user_ref;
+	int groupinfo_ref, user_ref, secref;
 	struct ckpt_hdr_cred *h;
 
 	groupinfo_ref = checkpoint_obj(ctx, cred->group_info,
@@ -1020,13 +1032,18 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 	user_ref = checkpoint_obj(ctx, cred->user, CKPT_OBJ_USER);
 	if (user_ref < 0)
 		return user_ref;
+	secref = checkpoint_cred_security(ctx, cred);
+	if (secref < 0) {
+		ckpt_err(ctx, secref, "%(T)cred->security");
+		return secref;
+	}
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CRED);
 	if (!h)
 		return -ENOMEM;
 
-	ckpt_debug("cred uid %d fsuid %d gid %d\n", cred->uid, cred->fsuid,
-			cred->gid);
+	ckpt_debug("cred uid %d fsuid %d gid %d secref %d\n", cred->uid,
+			cred->fsuid, cred->gid, secref);
 
 	h->uid = cred->uid;
 	h->suid = cred->suid;
@@ -1037,6 +1054,7 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 	h->sgid = cred->sgid;
 	h->egid = cred->egid;
 	h->fsgid = cred->fsgid;
+	h->sec_ref = secref;
 
 	checkpoint_capabilities(&h->cap_s, cred);
 
@@ -1110,6 +1128,10 @@ static struct cred *do_restore_cred(struct ckpt_ctx *ctx)
 	ret = cred_setfsgid(cred, h->fsgid, &oldgid);
 	if (oldgid != h->fsgid && ret < 0)
 		goto err_putcred;
+	ret = security_restore_obj(ctx, (void *) cred, CKPT_SECURITY_CRED,
+				   h->sec_ref);
+	if (ret)
+		goto err_putcred;
 	ret = restore_capabilities(&h->cap_s, cred);
 	if (ret)
 		goto err_putcred;
diff --git a/security/capability.c b/security/capability.c
index f79911a..24e5974 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -331,6 +331,16 @@ static int cap_file_permission(struct file *file, int mask)
 	return 0;
 }
 
+static inline char *cap_file_checkpoint(void *security)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static int cap_file_restore(struct file *file, char *ctx)
+{
+	return -ENOSYS;
+}
+
 static int cap_file_alloc_security(struct file *file)
 {
 	return 0;
@@ -394,6 +404,16 @@ static int cap_cred_alloc_blank(struct cred *cred, gfp_t gfp)
 	return 0;
 }
 
+static char *cap_cred_checkpoint(void *security)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static int cap_cred_restore(struct file *file, struct cred *cred, char *ctx)
+{
+	return -ENOSYS;
+}
+
 static void cap_cred_free(struct cred *cred)
 {
 }
@@ -506,11 +526,31 @@ static void cap_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
 	*secid = 0;
 }
 
+static char *cap_ipc_checkpoint(void *security)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static int cap_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	return -ENOSYS;
+}
+
 static int cap_msg_msg_alloc_security(struct msg_msg *msg)
 {
 	return 0;
 }
 
+static inline char *cap_msg_msg_checkpoint(void *security)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static int cap_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	return -ENOSYS;
+}
+
 static void cap_msg_msg_free_security(struct msg_msg *msg)
 {
 }
@@ -1019,6 +1059,8 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, path_chroot);
 #endif
 	set_to_cap_if_null(ops, file_permission);
+	set_to_cap_if_null(ops, file_checkpoint);
+	set_to_cap_if_null(ops, file_restore);
 	set_to_cap_if_null(ops, file_alloc_security);
 	set_to_cap_if_null(ops, file_free_security);
 	set_to_cap_if_null(ops, file_ioctl);
@@ -1032,6 +1074,8 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, dentry_open);
 	set_to_cap_if_null(ops, task_create);
 	set_to_cap_if_null(ops, cred_alloc_blank);
+	set_to_cap_if_null(ops, cred_checkpoint);
+	set_to_cap_if_null(ops, cred_restore);
 	set_to_cap_if_null(ops, cred_free);
 	set_to_cap_if_null(ops, cred_prepare);
 	set_to_cap_if_null(ops, cred_commit);
@@ -1060,7 +1104,11 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, task_to_inode);
 	set_to_cap_if_null(ops, ipc_permission);
 	set_to_cap_if_null(ops, ipc_getsecid);
+	set_to_cap_if_null(ops, ipc_checkpoint);
+	set_to_cap_if_null(ops, ipc_restore);
 	set_to_cap_if_null(ops, msg_msg_alloc_security);
+	set_to_cap_if_null(ops, msg_msg_checkpoint);
+	set_to_cap_if_null(ops, msg_msg_restore);
 	set_to_cap_if_null(ops, msg_msg_free_security);
 	set_to_cap_if_null(ops, msg_queue_alloc_security);
 	set_to_cap_if_null(ops, msg_queue_free_security);
diff --git a/security/security.c b/security/security.c
index abc1142..4b3f932 100644
--- a/security/security.c
+++ b/security/security.c
@@ -671,6 +671,16 @@ int security_file_alloc(struct file *file)
 	return security_ops->file_alloc_security(file);
 }
 
+char *security_file_checkpoint(void *security)
+{
+	return security_ops->file_checkpoint(security);
+}
+
+int security_file_restore(struct file *file, char *ctx)
+{
+	return security_ops->file_restore(file, ctx);
+}
+
 void security_file_free(struct file *file)
 {
 	security_ops->file_free_security(file);
@@ -740,6 +750,16 @@ int security_cred_alloc_blank(struct cred *cred, gfp_t gfp)
 	return security_ops->cred_alloc_blank(cred, gfp);
 }
 
+char *security_cred_checkpoint(void *security)
+{
+	return security_ops->cred_checkpoint(security);
+}
+
+int security_cred_restore(struct file *file, struct cred *cred, char *ctx)
+{
+	return security_ops->cred_restore(file, cred, ctx);
+}
+
 void security_cred_free(struct cred *cred)
 {
 	security_ops->cred_free(cred);
@@ -885,11 +905,31 @@ void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
 	security_ops->ipc_getsecid(ipcp, secid);
 }
 
+char *security_ipc_checkpoint(void *security)
+{
+	return security_ops->ipc_checkpoint(security);
+}
+
+int security_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	return security_ops->ipc_restore(ipcp, ctx);
+}
+
 int security_msg_msg_alloc(struct msg_msg *msg)
 {
 	return security_ops->msg_msg_alloc_security(msg);
 }
 
+char *security_msg_msg_checkpoint(void *security)
+{
+	return security_ops->msg_msg_checkpoint(security);
+}
+
+int security_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	return security_ops->msg_msg_restore(msg, ctx);
+}
+
 void security_msg_msg_free(struct msg_msg *msg)
 {
 	security_ops->msg_msg_free_security(msg);
@@ -1371,3 +1411,156 @@ int security_audit_rule_match(u32 secid, u32 field, u32 op, void *lsmrule,
 }
 
 #endif /* CONFIG_AUDIT */
+
+#ifdef CONFIG_CHECKPOINT
+
+/**
+ * security_checkpoint_obj - called during application checkpoint to
+ * record the security context of objects.
+ *
+ * First we add the void*security address to the objhash as a type
+ * CKPT_OBJ_SECURITY_PTR.  This records the fact that we've seen this
+ * context.  If we've seen the context before, then we simply place the
+ * recorded objref in *secref and return success.
+
+ * If this is the first time we've seen this context for this checkpoint
+ * image, then we
+ * 1. ask the LSM for a string representation of the context
+ * 2. create a struct ckpt_lsm_string pointing to the string and to the
+ *    objref which we got for the void*security in the objhash.
+ * 3. write that out to the checkpoint image as a CKPT_OBJ_SECURITY.  it
+ *    will be freed when the objhash is cleared.
+ *
+ * Returns 0 or a valid objref on success, or -error on error.
+ *
+ * This is only used at checkpoint of course.
+ */
+int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security, int sectype)
+{
+	int new, ret = -ENOMEM;
+	char *str;
+	struct ckpt_lsm_string *l;
+	int secref;
+
+	if (!security)
+		return SECURITY_CTX_NONE;
+
+	secref = ckpt_obj_lookup_add(ctx, security, CKPT_OBJ_SECURITY_PTR,
+				     &new);
+	if (!new)
+		return secref;
+
+	/*
+	 * Ask the LSM for a string representation
+	 */
+	switch (sectype) {
+	case CKPT_SECURITY_MSG_MSG:
+		str = security_msg_msg_checkpoint(security);
+		break;
+	case CKPT_SECURITY_IPC:
+		str = security_ipc_checkpoint(security);
+		break;
+	case CKPT_SECURITY_FILE:
+		str = security_file_checkpoint(security);
+		break;
+	case CKPT_SECURITY_CRED:
+		str = security_cred_checkpoint(security);
+		break;
+	default:
+		str = ERR_PTR(-EINVAL);
+		break;
+	}
+
+	if (IS_ERR(str)) {
+		if (PTR_ERR(str) == -ENOSYS)
+			return SECURITY_CTX_NONE;
+		return PTR_ERR(str);
+	}
+
+	l = kzalloc(sizeof(*l), GFP_KERNEL);
+	if (!l) {
+		kfree(str);
+		return -ENOMEM;
+	}
+	l->ptrref = secref;
+	l->sectype = sectype;
+	l->string = str;
+	kref_init(&l->kref);
+	ret = checkpoint_obj(ctx, l, CKPT_OBJ_SECURITY);
+	kref_put(&l->kref, lsm_string_free);
+	if (ret < 0)
+		return ret;
+
+	return secref;
+}
+
+/*
+ * Choose a security context for an object being restored during
+ * application restart.  @v is an object (file, cred, etc) containing
+ * a security context and being re-created.  It has been type-cast
+ * to a void*.  @sectype tells us what sort of object v is.  @secref
+ * is the objhash id representing the security context.
+ *
+ * If sys_restart() was called without the RESTART_KEEP_LSM flag,
+ * then default security contexts will be assigned to the re-created
+ * object (in fact, they already have by this point).  Otherwise, the
+ * LSM is expected to use the string context representation to assign
+ * the same security context to this object (if allowed).
+ *
+ * At checkpoint time, @secref was the objref for the void*security
+ * (which was not written to disk).  The
+ * checkpoint/objhash.c:restore_lsm_string() function should, before we
+ * get here, have read the context string in the checkpoint image, and
+ * inserted a second copy of the struct ckpt_lsm_string on the objhash,
+ * with this objref.
+ *
+ * Returns 0 on success, -error on error.
+ */
+int security_restore_obj(struct ckpt_ctx *ctx, void *v, int sectype,
+			 int secref)
+{
+	struct ckpt_lsm_string *l;
+	int ret;
+
+	/* return if caller didn't want to restore checkpointed labels */
+	if (!(ctx->uflags & RESTART_KEEP_LSM))
+		/* though msg_msg label must always be restored */
+		if (sectype != CKPT_SECURITY_MSG_MSG)
+			return 0;
+
+	/* return if checkpointed label was "Not Applicable" */
+	if (secref == SECURITY_CTX_NONE)
+		return 0;
+
+	l = ckpt_obj_fetch(ctx, secref, CKPT_OBJ_SECURITY);
+	if (IS_ERR(l))
+		return PTR_ERR(l);
+
+	/* Ask the LSM to apply a void*security to the object
+	 * based on the checkpointed context string */
+	switch (sectype) {
+	case CKPT_SECURITY_IPC:
+		ret = security_ipc_restore((struct kern_ipc_perm *) v,
+					l->string);
+		break;
+	case CKPT_SECURITY_MSG_MSG:
+		ret = security_msg_msg_restore((struct msg_msg *) v,
+						l->string);
+		break;
+	case CKPT_SECURITY_FILE:
+		ret = security_file_restore((struct file *) v, l->string);
+		break;
+	case CKPT_SECURITY_CRED:
+		ret = security_cred_restore(ctx->file, (struct cred *) v,
+						l->string);
+		break;
+	default:
+		ret = -EINVAL;
+	}
+	if (ret)
+		ckpt_err(ctx, ret, "%(O)sectype %d lsm restore hook error\n",
+			   secref, sectype);
+
+	return ret;
+}
+#endif
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
