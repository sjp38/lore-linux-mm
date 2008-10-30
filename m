From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v8][PATCH 03/12] Make file_pos_read/write() public
Date: Thu, 30 Oct 2008 09:51:06 -0400
Message-Id: <1225374675-22850-4-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

These two are needed when we will use vfs_read() and vfs_write(),
in the next patch.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 fs/read_write.c    |   10 ----------
 include/linux/fs.h |   10 ++++++++++
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 9ba495d..5d5c192 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -324,16 +324,6 @@ ssize_t vfs_write(struct file *file, const char __user *buf, size_t count, loff_
 
 EXPORT_SYMBOL(vfs_write);
 
-static inline loff_t file_pos_read(struct file *file)
-{
-	return file->f_pos;
-}
-
-static inline void file_pos_write(struct file *file, loff_t pos)
-{
-	file->f_pos = pos;
-}
-
 asmlinkage ssize_t sys_read(unsigned int fd, char __user * buf, size_t count)
 {
 	struct file *file;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 580b513..5537435 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1296,6 +1296,16 @@ ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 				struct iovec *fast_pointer,
 				struct iovec **ret_pointer);
 
+static inline loff_t file_pos_read(struct file *file)
+{
+	return file->f_pos;
+}
+
+static inline void file_pos_write(struct file *file, loff_t pos)
+{
+	file->f_pos = pos;
+}
+
 extern ssize_t vfs_read(struct file *, char __user *, size_t, loff_t *);
 extern ssize_t vfs_write(struct file *, const char __user *, size_t, loff_t *);
 extern ssize_t vfs_readv(struct file *, const struct iovec __user *,
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
