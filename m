Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C25AC62004E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:29:36 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 95/96] c/r: add selinux support (v6)
Date: Wed, 17 Mar 2010 12:09:23 -0400
Message-Id: <1268842164-5590-96-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-95-git-send-email-orenl@cs.columbia.edu>
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
 <1268842164-5590-95-git-send-email-orenl@cs.columbia.edu>
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

This patch adds the ability to checkpoint and restore selinux
contexts for tasks, open files, and sysvipc objects.  Contexts
are checkpointed as strings.  For tasks and files, where a security
struct actually points to several contexts, all contexts are
written out in one string, separated by ':::'.

The default behaviors are to checkpoint contexts, but not to
restore them.  To attempt to restore them, sys_restart() must
be given the RESTART_KEEP_LSM flag.  If this is given then
the caller of sys_restart() must have the new 'restore' permission
to the target objclass, or for instance PROCESS__SETFSCREATE to
itself to specify a create_sid.

There are some tests under cr_tests/selinux at
git://git.sr71.net/~hallyn/cr_tests.git.

A corresponding simple refpolicy (and /usr/share/selinux/devel/include)
patch is needed.

The programs to checkpoint and restart (called 'checkpoint' and
'restart') come from git://git.ncl.cs.columbia.edu/pub/git/user-cr.git.
This patch applies against the checkpoint/restart-enabled kernel
tree at git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git/.

Changelog:
	Feb 02: [orenl] rebase to kernel 2.6.33
	        * add tags in classmap.h (includes files autogenerated)
	Dec 09: update to use common_audit_data.
	oct 09: fix memory overrun in selinux_cred_checkpoint.
	oct 02: (Stephen Smalley suggestions):
		1. s/__u32/u32/
		2. enable the fown sid restoration
		3. use process_restore to authorize resetting osid
		4. don't make new hooks inline.
	oct 01: Remove some debugging that is redundant with
		avc log data.
	sep 10: (Most addressing suggestions by Stephen Smalley)
		1. change xyz_get_ctx() to xyz_checkpoint().
		2. check entrypoint permission on cred_restore
		3. always dec context length by 1
		4. don't allow SECSID_NULL when that's not valid
		5. when SECSID_NULL is valid, restore it
		6. c/r task->osid
		7. Just print nothing instead of 'null' for SECSID_NULL
		8. sids are __u32, as are lenghts passed to sid_to_context.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/restart.c                |    1 +
 security/selinux/hooks.c            |  369 +++++++++++++++++++++++++++++++++++
 security/selinux/include/classmap.h |    9 +-
 3 files changed, 375 insertions(+), 4 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 0d1b9bf..6a9644d 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -680,6 +680,7 @@ static int restore_lsm(struct ckpt_ctx *ctx)
 
 	if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
 			strcmp(ctx->lsm_name, "smack") != 0 &&
+			strcmp(ctx->lsm_name, "selinux") != 0 &&
 			strcmp(ctx->lsm_name, "default") != 0) {
 		ckpt_debug("c/r: RESTART_KEEP_LSM unsupported for %s\n",
 				ctx->lsm_name);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 9a2ee84..dd22750 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -76,6 +76,10 @@
 #include <linux/selinux.h>
 #include <linux/mutex.h>
 #include <linux/posix-timers.h>
+#include <linux/checkpoint.h>
+
+#include "flask.h"
+#include "av_permissions.h"
 
 #include "avc.h"
 #include "objsec.h"
@@ -2978,6 +2982,104 @@ static int selinux_file_permission(struct file *file, int mask)
 	return selinux_revalidate_file_permission(file, mask);
 }
 
+/*
+ * for file context, we print both the fsec->sid and fsec->fown_sid
+ * as string representations, separated by ':::'
+ * We don't touch isid - if you wanted that set you shoulda set up the
+ * fs correctly.
+ */
+static char *selinux_file_checkpoint(void *security)
+{
+	struct file_security_struct *fsec = security;
+	char *s1 = NULL, *s2 = NULL, *sfull;
+	u32 len1, len2, lenfull;
+	int ret;
+
+	if (fsec->sid == 0 || fsec->fown_sid == 0)
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(fsec->sid, &s1, &len1);
+	if (ret)
+		return ERR_PTR(ret);
+	len1--;
+	ret = security_sid_to_context(fsec->fown_sid, &s2, &len2);
+	if (ret) {
+		kfree(s1);
+		return ERR_PTR(ret);
+	}
+	len2--;
+	lenfull = len1 + len2 + 3;
+	sfull = kmalloc(lenfull + 1, GFP_KERNEL);
+	if (!sfull) {
+		sfull = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	sfull[lenfull] = '\0';
+	sprintf(sfull, "%s:::%s", s1, s2);
+
+out:
+	kfree(s1);
+	kfree(s2);
+	return sfull;
+}
+
+static int selinux_file_restore(struct file *file, char *ctx)
+{
+	char *s1, *s2;
+	u32 sid1 = 0, sid2 = 0;
+	int ret = -EINVAL;
+	struct file_security_struct *fsec = file->f_security;
+
+	/*
+	 * Objhash made sure the string is null-terminated.
+	 * We make a copy so we can mangle it.
+	 */
+	s1 = kstrdup(ctx, GFP_KERNEL);
+	if (!s1)
+		return -ENOMEM;
+	s2 = strstr(s1, ":::");
+	if (!s2)
+		goto out;
+
+	*s2 = '\0';
+	s2 += 3;
+	if (*s2 == '\0')
+		goto out;
+
+	/* SECSID_NULL is not valid for file sids */
+	if (strlen(s1) == 0 || strlen(s2) == 0)
+		goto out;
+
+	ret = security_context_to_sid(s1, strlen(s1), &sid1);
+	if (ret)
+		goto out;
+	ret = security_context_to_sid(s2, strlen(s2), &sid2);
+	if (ret)
+		goto out;
+
+	if (sid1 && fsec->sid != sid1) {
+		ret = avc_has_perm(current_sid(), sid1, SECCLASS_FILE,
+					FILE__RESTORE, NULL);
+		if (ret)
+			goto out;
+		fsec->sid = sid1;
+	}
+
+	if (sid2 && fsec->fown_sid != sid2) {
+		ret = avc_has_perm(current_sid(), sid2, SECCLASS_FILE,
+				FILE__FOWN_RESTORE, NULL);
+		if (ret)
+			goto out;
+	       fsec->fown_sid = sid2;
+	}
+
+	ret = 0;
+
+out:
+	kfree(s1);
+	return ret;
+}
+
 static int selinux_file_alloc_security(struct file *file)
 {
 	return file_alloc_security(file);
@@ -3236,6 +3338,186 @@ static int selinux_task_create(unsigned long clone_flags)
 	return current_has_perm(current, PROCESS__FORK);
 }
 
+#define NUMTASKSIDS 6
+/*
+ * for cred context, we print:
+ *   osid, sid, exec_sid, create_sid, keycreate_sid, sockcreate_sid;
+ * as string representations, separated by ':::'
+ */
+static char *selinux_cred_checkpoint(void *security)
+{
+	struct task_security_struct *tsec = security;
+	char *stmp, *sfull = NULL;
+	u32 slen, runlen;
+	int i, ret;
+	u32 sids[NUMTASKSIDS] = { tsec->osid, tsec->sid, tsec->exec_sid,
+		tsec->create_sid, tsec->keycreate_sid, tsec->sockcreate_sid };
+
+	if (sids[0] == 0 || sids[1] == 0)
+		/* SECSID_NULL is not valid for osid or sid */
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(sids[0], &sfull, &runlen);
+	if (ret)
+		return ERR_PTR(ret);
+	runlen--;
+
+	for (i = 1; i < NUMTASKSIDS; i++) {
+		if (sids[i] == 0) {
+			stmp = NULL;
+			slen = 0;
+		} else {
+			ret = security_sid_to_context(sids[i], &stmp, &slen);
+			if (ret) {
+				kfree(sfull);
+				return ERR_PTR(ret);
+			}
+			slen--;
+		}
+		/* slen + runlen + ':::' + \0 */
+		sfull = krealloc(sfull, slen + runlen + 3 + 1,
+				 GFP_KERNEL);
+		if (!sfull) {
+			kfree(stmp);
+			return ERR_PTR(-ENOMEM);
+		}
+		sprintf(sfull+runlen, ":::%s", stmp ? stmp : "");
+		runlen += slen + 3;
+		kfree(stmp);
+	}
+
+	return sfull;
+}
+
+static inline int credrestore_nullvalid(int which)
+{
+	int valid_array[NUMTASKSIDS] = {
+		0, /* task osid */
+		0, /* task sid */
+		1, /* exec sid */
+		1, /* create sid */
+		1, /* keycreate_sid */
+		1, /* sockcreate_sid */
+	};
+
+	return valid_array[which];
+}
+
+static int selinux_cred_restore(struct file *file, struct cred *cred,
+					char *ctx)
+{
+	char *s, *s1, *s2 = NULL;
+	int ret = -EINVAL;
+	struct task_security_struct *tsec = cred->security;
+	int i;
+	u32 sids[NUMTASKSIDS];
+	struct inode *ctx_inode = file->f_dentry->d_inode;
+	struct common_audit_data ad;
+
+	/*
+	 * objhash made sure the string is null-terminated
+	 * now we want our own copy so we can chop it up with \0's
+	 */
+	s = kstrdup(ctx, GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+
+	s1 = s;
+	for (i = 0; i < NUMTASKSIDS; i++) {
+		if (i < NUMTASKSIDS-1) {
+			ret = -EINVAL;
+			s2 = strstr(s1, ":::");
+			if (!s2)
+				goto out;
+			*s2 = '\0';
+			s2 += 3;
+		}
+		if (strlen(s1) == 0) {
+			ret = -EINVAL;
+			if (credrestore_nullvalid(i))
+				sids[i] = 0;
+			else
+				goto out;
+		} else {
+			ret = security_context_to_sid(s1, strlen(s1), &sids[i]);
+			if (ret)
+				goto out;
+		}
+		s1 = s2;
+	}
+
+	/*
+	 * Check that these transitions are allowed, and effect them.
+	 * XXX: Do these checks suffice?
+	 */
+	if (tsec->osid != sids[0]) {
+		ret = avc_has_perm(current_sid(), sids[0], SECCLASS_PROCESS,
+					PROCESS__RESTORE, NULL);
+		if (ret)
+			goto out;
+		 tsec->osid = sids[0];
+	}
+
+	if (tsec->sid != sids[1]) {
+		struct inode_security_struct *isec;
+		ret = avc_has_perm(current_sid(), sids[1], SECCLASS_PROCESS,
+					PROCESS__RESTORE, NULL);
+		if (ret)
+			goto out;
+
+		/* check whether checkpoint file type is a valid entry
+		 * point to the new domain:  we may want a specific
+		 * 'restore_entrypoint' permission for this, but let's
+		 * see if just entrypoint is deemed sufficient
+		 */
+
+		COMMON_AUDIT_DATA_INIT(&ad, FS);
+		ad.u.fs.path = file->f_path;
+
+		isec = ctx_inode->i_security;
+		ret = avc_has_perm(sids[1], isec->sid, SECCLASS_FILE,
+				FILE__ENTRYPOINT, &ad);
+		if (ret)
+			goto out;
+		/* TODO: do we need to check for shared state? */
+		tsec->sid = sids[1];
+	}
+
+	ret = -EPERM;
+	if (sids[2] != tsec->exec_sid) {
+		if (!current_has_perm(current, PROCESS__SETEXEC))
+			goto out;
+		tsec->exec_sid = sids[2];
+	}
+
+	if (sids[3] != tsec->create_sid) {
+		if (!current_has_perm(current, PROCESS__SETFSCREATE))
+			goto out;
+		tsec->create_sid = sids[3];
+	}
+
+	if (tsec->keycreate_sid != sids[4]) {
+		if (!current_has_perm(current, PROCESS__SETKEYCREATE))
+			goto out;
+		if (!may_create_key(sids[4], current))
+			goto out;
+		tsec->keycreate_sid = sids[4];
+	}
+
+	if (tsec->sockcreate_sid != sids[5]) {
+		if (!current_has_perm(current, PROCESS__SETSOCKCREATE))
+			goto out;
+		tsec->sockcreate_sid = sids[5];
+	}
+
+	ret = 0;
+
+out:
+	kfree(s);
+	return ret;
+}
+
+
 /*
  * allocate the SELinux part of blank credentials
  */
@@ -4767,6 +5049,44 @@ static void ipc_free_security(struct kern_ipc_perm *perm)
 	kfree(isec);
 }
 
+static char *selinux_msg_msg_checkpoint(void *security)
+{
+	struct msg_security_struct *msec = security;
+	char *s;
+	u32 len;
+	int ret;
+
+	if (msec->sid == 0)
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(msec->sid, &s, &len);
+	if (ret)
+		return ERR_PTR(ret);
+	return s;
+}
+
+static int selinux_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	struct msg_security_struct *msec = msg->security;
+	int ret;
+	u32 sid = 0;
+
+	ret = security_context_to_sid(ctx, strlen(ctx), &sid);
+	if (ret)
+		return ret;
+
+	if (msec->sid == sid)
+		return 0;
+
+	ret = avc_has_perm(current_sid(), sid, SECCLASS_MSG,
+				MSG__RESTORE, NULL);
+	if (ret)
+		return ret;
+
+	msec->sid = sid;
+	return 0;
+}
+
 static int msg_msg_alloc_security(struct msg_msg *msg)
 {
 	struct msg_security_struct *msec;
@@ -5170,6 +5490,47 @@ static void selinux_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
 	*secid = isec->sid;
 }
 
+static char *selinux_ipc_checkpoint(void *security)
+{
+	struct ipc_security_struct *isec = security;
+	char *s;
+	u32 len;
+	int ret;
+
+	if (isec->sid == 0)
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(isec->sid, &s, &len);
+	if (ret)
+		return ERR_PTR(ret);
+	return s;
+}
+
+static int selinux_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	struct ipc_security_struct *isec = ipcp->security;
+	int ret;
+	u32 sid = 0;
+	struct common_audit_data ad;
+
+	ret = security_context_to_sid(ctx, strlen(ctx), &sid);
+	if (ret)
+		return ret;
+
+	if (isec->sid == sid)
+		return 0;
+
+	COMMON_AUDIT_DATA_INIT(&ad, IPC);
+	ad.u.ipc_id = ipcp->key;
+	ret = avc_has_perm(current_sid(), sid, SECCLASS_IPC,
+				IPC__RESTORE, &ad);
+	if (ret)
+		return ret;
+
+	isec->sid = sid;
+	return 0;
+}
+
 static void selinux_d_instantiate(struct dentry *dentry, struct inode *inode)
 {
 	if (inode)
@@ -5517,6 +5878,8 @@ static struct security_operations selinux_ops = {
 	.inode_getsecid =		selinux_inode_getsecid,
 
 	.file_permission =		selinux_file_permission,
+	.file_checkpoint =		selinux_file_checkpoint,
+	.file_restore =			selinux_file_restore,
 	.file_alloc_security =		selinux_file_alloc_security,
 	.file_free_security =		selinux_file_free_security,
 	.file_ioctl =			selinux_file_ioctl,
@@ -5532,6 +5895,8 @@ static struct security_operations selinux_ops = {
 
 	.task_create =			selinux_task_create,
 	.cred_alloc_blank =		selinux_cred_alloc_blank,
+	.cred_checkpoint =		selinux_cred_checkpoint,
+	.cred_restore =			selinux_cred_restore,
 	.cred_free =			selinux_cred_free,
 	.cred_prepare =			selinux_cred_prepare,
 	.cred_transfer =		selinux_cred_transfer,
@@ -5555,8 +5920,12 @@ static struct security_operations selinux_ops = {
 
 	.ipc_permission =		selinux_ipc_permission,
 	.ipc_getsecid =			selinux_ipc_getsecid,
+	.ipc_checkpoint =		selinux_ipc_checkpoint,
+	.ipc_restore =			selinux_ipc_restore,
 
 	.msg_msg_alloc_security =	selinux_msg_msg_alloc_security,
+	.msg_msg_checkpoint =		selinux_msg_msg_checkpoint,
+	.msg_msg_restore =		selinux_msg_msg_restore,
 	.msg_msg_free_security =	selinux_msg_msg_free_security,
 
 	.msg_queue_alloc_security =	selinux_msg_queue_alloc_security,
diff --git a/security/selinux/include/classmap.h b/security/selinux/include/classmap.h
index 8b32e95..b1cde03 100644
--- a/security/selinux/include/classmap.h
+++ b/security/selinux/include/classmap.h
@@ -24,7 +24,7 @@ struct security_class_mapping secclass_map[] = {
 	    "getattr", "setexec", "setfscreate", "noatsecure", "siginh",
 	    "setrlimit", "rlimitinh", "dyntransition", "setcurrent",
 	    "execmem", "execstack", "execheap", "setkeycreate",
-	    "setsockcreate", NULL } },
+	    "setsockcreate", "restore", NULL } },
 	{ "system",
 	  { "ipc_info", "syslog_read", "syslog_mod",
 	    "syslog_console", "module_request", NULL } },
@@ -43,7 +43,8 @@ struct security_class_mapping secclass_map[] = {
 	    "quotaget", NULL } },
 	{ "file",
 	  { COMMON_FILE_PERMS,
-	    "execute_no_trans", "entrypoint", "execmod", "open", NULL } },
+	    "execute_no_trans", "entrypoint", "execmod", "open",
+	    "restore", "fown_restore", NULL } },
 	{ "dir",
 	  { COMMON_FILE_PERMS, "add_name", "remove_name",
 	    "reparent", "search", "rmdir", "open", NULL } },
@@ -93,13 +94,13 @@ struct security_class_mapping secclass_map[] = {
 	  } },
 	{ "sem",
 	  { COMMON_IPC_PERMS, NULL } },
-	{ "msg", { "send", "receive", NULL } },
+	{ "msg", { "send", "receive", "restore", NULL } },
 	{ "msgq",
 	  { COMMON_IPC_PERMS, "enqueue", NULL } },
 	{ "shm",
 	  { COMMON_IPC_PERMS, "lock", NULL } },
 	{ "ipc",
-	  { COMMON_IPC_PERMS, NULL } },
+	  { COMMON_IPC_PERMS, "restore", NULL } },
 	{ "netlink_route_socket",
 	  { COMMON_SOCK_PERMS,
 	    "nlmsg_read", "nlmsg_write", NULL } },
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
