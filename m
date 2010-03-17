Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 07F7562003C
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:24:11 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 79/96] c/r: [pty 1/2] allow allocation of desired pty slave
Date: Wed, 17 Mar 2010 12:09:07 -0400
Message-Id: <1268842164-5590-80-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-79-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

During restart, we need to allocate pty slaves with the same
identifiers as recorded during checkpoint. Modify the allocation code
to allow an in-kernel caller to request a specific slave identifier.

For this, add a new field to task_struct - 'required_id'. It will
hold the desired identifier when restoring a (master) pty.

The code in ptmx_open() will use this value only for tasks that try to
open /dev/ptmx that are restarting (PF_RESTARTING), and if the value
isn't CKPT_REQUIRED_NONE (-1).

Changelog[v19-rc3]:
  - Rebase to kernel 2.6.33

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 drivers/char/pty.c        |   65 +++++++++++++++++++++++++++++++++++++++++---
 drivers/char/tty_io.c     |    1 +
 fs/devpts/inode.c         |   13 +++++++--
 include/linux/devpts_fs.h |    6 +++-
 include/linux/tty.h       |    2 +
 5 files changed, 78 insertions(+), 9 deletions(-)

diff --git a/drivers/char/pty.c b/drivers/char/pty.c
index 385c44b..33f720b 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -614,9 +614,10 @@ static const struct tty_operations pty_unix98_ops = {
 };
 
 /**
- *	ptmx_open		-	open a unix 98 pty master
+ *	__ptmx_open		-	open a unix 98 pty master
  *	@inode: inode of device file
  *	@filp: file pointer to tty
+ *	@index: desired slave index
  *
  *	Allocate a unix98 pty master device from the ptmx driver.
  *
@@ -625,16 +626,15 @@ static const struct tty_operations pty_unix98_ops = {
  *		allocated_ptys_lock handles the list of free pty numbers
  */
 
-static int __ptmx_open(struct inode *inode, struct file *filp)
+static int __ptmx_open(struct inode *inode, struct file *filp, int index)
 {
 	struct tty_struct *tty;
 	int retval;
-	int index;
 
 	nonseekable_open(inode, filp);
 
 	/* find a device that is not in use. */
-	index = devpts_new_index(inode);
+	index = devpts_new_index(inode, index);
 	if (index < 0)
 		return index;
 
@@ -670,12 +670,66 @@ static int ptmx_open(struct inode *inode, struct file *filp)
 {
 	int ret;
 
+#ifdef CONFIG_CHECKPOINT
+	/*
+	 * If current task is restarting, we skip the actual open.
+	 * Instead, leave it up to the caller (restart code) to invoke
+	 * __ptmx_open() with the desired pty index request.
+	 *
+	 * NOTE: this gives a half-baked file that has ptmx f_op but
+	 * the tty (private_data) is NULL. It is the responsibility of
+	 * the _caller_ to ensure proper initialization before
+	 * allowing it to be used (ptmx_release() tolerates NULL tty).
+	 */
+	if (current->flags & PF_RESTARTING)
+		return 0;
+#endif
+
 	lock_kernel();
-	ret = __ptmx_open(inode, filp);
+	ret = __ptmx_open(inode, filp, UNSPECIFIED_PTY_INDEX);
 	unlock_kernel();
 	return ret;
 }
 
+static int ptmx_release(struct inode *inode, struct file *filp)
+{
+#ifdef CONFIG_CHECKPOINT
+	/*
+	 * It is possible for a restart to create a half-baked
+	 * ptmx file - see ptmx_open(). In that case there is no
+	 * tty (private_data) and nothing to do.
+	 */
+	if (!filp->private_data)
+		return 0;
+#endif
+
+	return tty_release(inode, filp);
+}
+
+struct file *pty_open_by_index(char *ptmxpath, int index)
+{
+	struct file *ptmxfile;
+	int ret;
+
+	/*
+	 * We need to pick a way to specify which devpts mountpoint to
+	 * use. For now, we'll just use whatever /dev/ptmx points to.
+	 */
+	ptmxfile = filp_open(ptmxpath, O_RDWR|O_NOCTTY, 0);
+	if (IS_ERR(ptmxfile))
+		return ptmxfile;
+
+	lock_kernel();
+	ret = __ptmx_open(ptmxfile->f_dentry->d_inode, ptmxfile, index);
+	unlock_kernel();
+	if (ret) {
+		fput(ptmxfile);
+		return ERR_PTR(ret);
+	}
+
+	return ptmxfile;
+}
+
 static struct file_operations ptmx_fops;
 
 static void __init unix98_pty_init(void)
@@ -732,6 +786,7 @@ static void __init unix98_pty_init(void)
 	/* Now create the /dev/ptmx special device */
 	tty_default_fops(&ptmx_fops);
 	ptmx_fops.open = ptmx_open;
+	ptmx_fops.release = ptmx_release;
 
 	cdev_init(&ptmx_cdev, &ptmx_fops);
 	if (cdev_add(&ptmx_cdev, MKDEV(TTYAUX_MAJOR, 2), 1) ||
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index dcb9083..169c130 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -142,6 +142,7 @@ ssize_t redirected_tty_write(struct file *, const char __user *,
 							size_t, loff_t *);
 static unsigned int tty_poll(struct file *, poll_table *);
 static int tty_open(struct inode *, struct file *);
+int tty_release(struct inode *, struct file *);
 long tty_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
 #ifdef CONFIG_COMPAT
 static long tty_compat_ioctl(struct file *file, unsigned int cmd,
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 8882ecc..e997f8a 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -432,11 +432,11 @@ static struct file_system_type devpts_fs_type = {
  * to the System V naming convention
  */
 
-int devpts_new_index(struct inode *ptmx_inode)
+int devpts_new_index(struct inode *ptmx_inode, int req_idx)
 {
 	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
-	int index;
+	int index = req_idx;
 	int ida_ret;
 
 retry:
@@ -444,7 +444,9 @@ retry:
 		return -ENOMEM;
 
 	mutex_lock(&allocated_ptys_lock);
-	ida_ret = ida_get_new(&fsi->allocated_ptys, &index);
+	if (index == UNSPECIFIED_PTY_INDEX)
+		index = 0;
+	ida_ret = ida_get_new_above(&fsi->allocated_ptys, index, &index);
 	if (ida_ret < 0) {
 		mutex_unlock(&allocated_ptys_lock);
 		if (ida_ret == -EAGAIN)
@@ -452,6 +454,11 @@ retry:
 		return -EIO;
 	}
 
+	if (req_idx != UNSPECIFIED_PTY_INDEX && index != req_idx) {
+		ida_remove(&fsi->allocated_ptys, index);
+		mutex_unlock(&allocated_ptys_lock);
+		return -EBUSY;
+	}
 	if (index >= pty_limit) {
 		ida_remove(&fsi->allocated_ptys, index);
 		mutex_unlock(&allocated_ptys_lock);
diff --git a/include/linux/devpts_fs.h b/include/linux/devpts_fs.h
index 5ce0e5f..163a70e 100644
--- a/include/linux/devpts_fs.h
+++ b/include/linux/devpts_fs.h
@@ -15,9 +15,13 @@
 
 #include <linux/errno.h>
 
+#define UNSPECIFIED_PTY_INDEX -1
+
 #ifdef CONFIG_UNIX98_PTYS
 
-int devpts_new_index(struct inode *ptmx_inode);
+struct file *pty_open_by_index(char *ptmxpath, int index);
+
+int devpts_new_index(struct inode *ptmx_inode, int req_idx);
 void devpts_kill_index(struct inode *ptmx_inode, int idx);
 /* mknod in devpts */
 int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty);
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 6abfcf5..7d77487 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -501,6 +501,8 @@ extern void tty_ldisc_begin(void);
 /* This last one is just for the tty layer internals and shouldn't be used elsewhere */
 extern void tty_ldisc_enable(struct tty_struct *tty);
 
+/* This one is for ptmx_close() */
+extern int tty_release(struct inode *inode, struct file *filp);
 
 /* n_tty.c */
 extern struct tty_ldisc_ops tty_ldisc_N_TTY;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
