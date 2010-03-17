Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0E75B620049
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:29:29 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 94/96] c/r: add smack support to lsm c/r (v4)
Date: Wed, 17 Mar 2010 12:09:22 -0400
Message-Id: <1268842164-5590-95-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-94-git-send-email-orenl@cs.columbia.edu>
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
 <1268842164-5590-94-git-send-email-orenl@cs.columbia.edu>
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

This patch implements checkpoint and restore of Smack security
labels.  The rules are the same as in previous versions:

	1. when objects are created during restore() they are
	   automatically labeled with current_security().
	2. if there was a label checkpointed with the object,
	   and that label != current_security() (which is the
	   same as obj->security), then the object is relabeled
	   if the sys_restart() caller has CAP_MAC_ADMIN.
	   Otherwise we return -EPERM.

This has been tested by checkpointing tasks under labels
_, vs1, and vs2, and restarting from tasks under _, vs1,
and vs2, with and without CAP_MAC_ADMIN in the bounding
set, and with and without the '-k' (keep_lsm) flag to mktree.
Expected results:

	#shell 1:
	echo vs1 > /proc/self/attr/current
	ckpt > out
	echo vs2 > /proc/self/attr/current
	mktree -F /cgroup/2 < out
		(frozen)
	# shell 2:
	cat /proc/`pidof ckpt`/attr/current
		vs2
	echo THAWED > /cgroup/2/freezer.state
	# shell 1:
	mktree -k -F /cgroup/2 < out
		(frozen)
	# shell 2:
	cat /proc/`pidof ckpt`/attr/current
		vs1
	echo THAWED > /cgroup/2/freezer.state
	# shell 1:
	capsh --drop=cap_mac_admin --
	mktree -k -F /cgroup/2 < out
		(permission denied)

There are testcases in git://git.sr71.net/~hallyn/cr_tests.git
under cr_tests/smack, which automate the above (and pass).

Changelog:
	sep 3: add a version to smack lsm, accessible through
		/smack/version  (Casey and Serge)
	sep 10: rename xyz_get_ctx() to xyz_checkpoint()

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Acked-by: Casey Schaufler <casey@schaufler-ca.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/restart.c       |    1 +
 security/smack/smack.h     |    1 +
 security/smack/smack_lsm.c |  144 ++++++++++++++++++++++++++++++++++++++++++++
 security/smack/smackfs.c   |   83 +++++++++++++++++++++++++
 4 files changed, 229 insertions(+), 0 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index cfcb62b..0d1b9bf 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -679,6 +679,7 @@ static int restore_lsm(struct ckpt_ctx *ctx)
 	}
 
 	if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
+			strcmp(ctx->lsm_name, "smack") != 0 &&
 			strcmp(ctx->lsm_name, "default") != 0) {
 		ckpt_debug("c/r: RESTART_KEEP_LSM unsupported for %s\n",
 				ctx->lsm_name);
diff --git a/security/smack/smack.h b/security/smack/smack.h
index c6e9aca..a8917b0 100644
--- a/security/smack/smack.h
+++ b/security/smack/smack.h
@@ -216,6 +216,7 @@ u32 smack_to_secid(const char *);
 extern int smack_cipso_direct;
 extern char *smack_net_ambient;
 extern char *smack_onlycap;
+extern char *smack_version;
 extern const char *smack_cipso_option;
 
 extern struct smack_known smack_known_floor;
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 529c9ca..cd1d330 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -27,6 +27,7 @@
 #include <linux/udp.h>
 #include <linux/mutex.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/checkpoint.h>
 #include <net/netlabel.h>
 #include <net/cipso_ipv4.h>
 #include <linux/audit.h>
@@ -886,6 +887,28 @@ static int smack_file_permission(struct file *file, int mask)
 	return 0;
 }
 
+static inline char *smack_file_checkpoint(void *security)
+{
+	return kstrdup((char *)security, GFP_KERNEL);
+}
+
+static inline int smack_file_restore(struct file *file, char *ctx)
+{
+	char *newsmack = smk_import(ctx, 0);
+
+	if (newsmack == NULL)
+		return -EINVAL;
+	/* I think by definition, file->f_security == current_security
+	 * right now, but let's assume somehow it might not be */
+	if (newsmack == file->f_security)
+		return 0;
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+	file->f_security = newsmack;
+
+	return 0;
+}
+
 /**
  * smack_file_alloc_security - assign a file security blob
  * @file: the object
@@ -1073,6 +1096,27 @@ static int smack_file_receive(struct file *file)
  * Task hooks
  */
 
+static inline char *smack_cred_checkpoint(void *security)
+{
+	return kstrdup((char *)security, GFP_KERNEL);
+}
+
+static inline int smack_cred_restore(struct file *file, struct cred *cred,
+					char *ctx)
+{
+	char *newsmack = smk_import(ctx, 0);
+
+	if (newsmack == NULL)
+		return -EINVAL;
+	if (newsmack == cred->security)
+		return 0;
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+	cred->security = newsmack;
+
+	return 0;
+}
+
 /**
  * smack_cred_alloc_blank - "allocate" blank task-level security credentials
  * @new: the new credentials
@@ -1765,6 +1809,26 @@ static int smack_msg_msg_alloc_security(struct msg_msg *msg)
 	return 0;
 }
 
+static inline char *smack_msg_msg_checkpoint(void *security)
+{
+	return kstrdup((char *)security, GFP_KERNEL);
+}
+
+static inline int smack_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	char *newsmack = smk_import(ctx, 0);
+
+	if (newsmack == NULL)
+		return -EINVAL;
+	if (newsmack == msg->security)
+		return 0;
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+	msg->security = newsmack;
+
+	return 0;
+}
+
 /**
  * smack_msg_msg_free_security - Clear the security blob for msg_msg
  * @msg: the object
@@ -2198,6 +2262,26 @@ static void smack_ipc_getsecid(struct kern_ipc_perm *ipp, u32 *secid)
 	*secid = smack_to_secid(smack);
 }
 
+static inline char *smack_ipc_checkpoint(void *security)
+{
+	return kstrdup((char *)security, GFP_KERNEL);
+}
+
+static inline int smack_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	char *newsmack = smk_import(ctx, 0);
+
+	if (newsmack == NULL)
+		return -EINVAL;
+	if (newsmack == ipcp->security)
+		return 0;
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+	ipcp->security = newsmack;
+
+	return 0;
+}
+
 /**
  * smack_d_instantiate - Make sure the blob is correct on an inode
  * @opt_dentry: unused
@@ -3073,6 +3157,51 @@ static int smack_inode_getsecctx(struct inode *inode, void **ctx, u32 *ctxlen)
 	return 0;
 }
 
+#ifdef CONFIG_CHECKPOINT
+
+static int smack_may_restart(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr *chp;
+	char *saved_version;
+	int ret = 0;
+
+	chp = ckpt_read_buf_type(ctx, CKPT_LSM_INFO_LEN, CKPT_HDR_LSM_INFO);
+	if (IS_ERR(chp))
+		return PTR_ERR(chp);
+
+	/*
+	 * After the checkpoint header comes the null terminated
+	 * Smack "policy" version. This will usually be the
+	 * floor label "_".
+	 */
+	saved_version = (char *)(chp + 1);
+
+	/*
+	 * Of course, it is possible that a "policy" version mismatch
+	 * is not considered threatening.
+	 */
+	if (!(ctx->uflags & RESTART_KEEP_LSM))
+		goto skip;
+
+	if (strcmp(saved_version, smack_version) != 0) {
+		ckpt_debug("Smack version at checkpoint was"
+			   "\"%s\", now is \"%s\".\n",
+				saved_version, smack_version);
+		ret = -EINVAL;
+	}
+skip:
+	ckpt_hdr_put(ctx, chp);
+	return ret;
+}
+
+static int smack_checkpoint_header(struct ckpt_ctx *ctx)
+{
+	return ckpt_write_obj_type(ctx, smack_version,
+					strlen(smack_version) + 1,
+					CKPT_HDR_LSM_INFO);
+}
+#endif
+
 struct security_operations smack_ops = {
 	.name =				"smack",
 
@@ -3108,6 +3237,8 @@ struct security_operations smack_ops = {
 	.inode_getsecid =		smack_inode_getsecid,
 
 	.file_permission = 		smack_file_permission,
+	.file_checkpoint = 		smack_file_checkpoint,
+	.file_restore = 		smack_file_restore,
 	.file_alloc_security = 		smack_file_alloc_security,
 	.file_free_security = 		smack_file_free_security,
 	.file_ioctl = 			smack_file_ioctl,
@@ -3118,6 +3249,10 @@ struct security_operations smack_ops = {
 	.file_receive = 		smack_file_receive,
 
 	.cred_alloc_blank =		smack_cred_alloc_blank,
+
+	.cred_checkpoint =		smack_cred_checkpoint,
+	.cred_restore =			smack_cred_restore,
+
 	.cred_free =			smack_cred_free,
 	.cred_prepare =			smack_cred_prepare,
 	.cred_commit =			smack_cred_commit,
@@ -3140,8 +3275,12 @@ struct security_operations smack_ops = {
 
 	.ipc_permission = 		smack_ipc_permission,
 	.ipc_getsecid =			smack_ipc_getsecid,
+	.ipc_checkpoint =		smack_ipc_checkpoint,
+	.ipc_restore =			smack_ipc_restore,
 
 	.msg_msg_alloc_security = 	smack_msg_msg_alloc_security,
+	.msg_msg_checkpoint =		smack_msg_msg_checkpoint,
+	.msg_msg_restore =		smack_msg_msg_restore,
 	.msg_msg_free_security = 	smack_msg_msg_free_security,
 
 	.msg_queue_alloc_security = 	smack_msg_queue_alloc_security,
@@ -3204,6 +3343,11 @@ struct security_operations smack_ops = {
 	.inode_notifysecctx =		smack_inode_notifysecctx,
 	.inode_setsecctx =		smack_inode_setsecctx,
 	.inode_getsecctx =		smack_inode_getsecctx,
+
+#ifdef CONFIG_CHECKPOINT
+	.may_restart =			smack_may_restart,
+	.checkpoint_header =		smack_checkpoint_header,
+#endif
 };
 
 
diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index aeead75..0634a08 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -42,6 +42,7 @@ enum smk_inos {
 	SMK_NETLBLADDR	= 8,	/* single label hosts */
 	SMK_ONLYCAP	= 9,	/* the only "capable" label */
 	SMK_LOGGING	= 10,	/* logging */
+	SMK_VERSION	= 11,	/* logging */
 };
 
 /*
@@ -51,6 +52,7 @@ static DEFINE_MUTEX(smack_list_lock);
 static DEFINE_MUTEX(smack_cipso_lock);
 static DEFINE_MUTEX(smack_ambient_lock);
 static DEFINE_MUTEX(smk_netlbladdr_lock);
+static DEFINE_MUTEX(smack_version_lock);
 
 /*
  * This is the "ambient" label for network traffic.
@@ -60,6 +62,16 @@ static DEFINE_MUTEX(smk_netlbladdr_lock);
 char *smack_net_ambient = smack_known_floor.smk_known;
 
 /*
+ * This is the policy version. In the interest of simplicity the
+ * policy version is a string that meets all of the requirements
+ * of a Smack label. This is enforced by the expedient of
+ * importing it like a label. The policy version is thus always
+ * also a valid label on the system. This may prove useful under
+ * some as yet undiscovered circumstance.
+ */
+char *smack_version = smack_known_floor.smk_known;
+
+/*
  * This is the level in a CIPSO header that indicates a
  * smack label is contained directly in the category set.
  * It can be reset via smackfs/direct
@@ -1255,6 +1267,75 @@ static const struct file_operations smk_logging_ops = {
 	.read		= smk_read_logging,
 	.write		= smk_write_logging,
 };
+
+#define SMK_VERSIONLEN 12
+/**
+ * smk_read_version - read() for /smack/version
+ * @filp: file pointer, not actually used
+ * @buf: where to put the result
+ * @cn: maximum to send along
+ * @ppos: where to start
+ *
+ * Returns number of bytes read or error code, as appropriate
+ */
+static ssize_t smk_read_version(struct file *filp, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	int rc;
+
+	if (*ppos != 0)
+		return 0;
+
+	mutex_lock(&smack_version_lock);
+
+	rc = simple_read_from_buffer(buf, count, ppos, smack_version,
+					strlen(smack_version) + 1);
+
+	mutex_unlock(&smack_version_lock);
+
+	return rc;
+}
+
+/**
+ * smk_write_version - write() for /smack/version
+ * @file: file pointer, not actually used
+ * @buf: where to get the data from
+ * @count: bytes sent
+ * @ppos: where to start
+ *
+ * Returns number of bytes written or error code, as appropriate
+ */
+static ssize_t smk_write_version(struct file *file, const char __user *buf,
+				 size_t count, loff_t *ppos)
+{
+	char *smack;
+	char in[SMK_LABELLEN];
+
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+
+	if (count >= SMK_LABELLEN)
+		return -EINVAL;
+
+	if (copy_from_user(in, buf, count) != 0)
+		return -EFAULT;
+
+	smack = smk_import(in, count);
+	if (smack == NULL)
+		return -EINVAL;
+
+	mutex_lock(&smack_version_lock);
+	smack_version = smack;
+	mutex_unlock(&smack_version_lock);
+
+	return count;
+}
+
+static const struct file_operations smk_version_ops = {
+	.read		= smk_read_version,
+	.write		= smk_write_version,
+};
+
 /**
  * smk_fill_super - fill the /smackfs superblock
  * @sb: the empty superblock
@@ -1287,6 +1368,8 @@ static int smk_fill_super(struct super_block *sb, void *data, int silent)
 			{"onlycap", &smk_onlycap_ops, S_IRUGO|S_IWUSR},
 		[SMK_LOGGING]	=
 			{"logging", &smk_logging_ops, S_IRUGO|S_IWUSR},
+		[SMK_VERSION]	=
+			{"version", &smk_version_ops, S_IRUGO|S_IWUSR},
 		/* last one */ {""}
 	};
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
