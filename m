Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A16F562003E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:26:10 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 83/96] c/r: checkpoint/restart eventfd
Date: Wed, 17 Mar 2010 12:09:11 -0400
Message-Id: <1268842164-5590-84-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-83-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Matt Helsley <matthltc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Matt Helsley <matthltc@us.ibm.com>

Save/restore eventfd files. These are anon_inodes just like epoll
but instead of a set of files to poll they are a 64-bit counter
and a flag value. Used for AIO.

[Oren Laadan] Added #ifdef's around checkpoint/restart to compile even
without CONFIG_CHECKPOINT

Changelog[v19]:
  - Fix broken compilation for architectures that don't support c/r

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/files.c             |    7 +++++
 fs/eventfd.c                   |   55 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    8 ++++++
 include/linux/eventfd.h        |   12 ++++++++
 4 files changed, 82 insertions(+), 0 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 6aaaf22..4b551fe 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -23,6 +23,7 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/eventpoll.h>
+#include <linux/eventfd.h>
 #include <net/sock.h>
 
 
@@ -644,6 +645,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_EPOLL,
 		.restore = ep_file_restore,
 	},
+	/* eventfd */
+	{
+		.file_name = "EVENTFD",
+		.file_type = CKPT_FILE_EVENTFD,
+		.restore = eventfd_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/fs/eventfd.c b/fs/eventfd.c
index 7758cc3..f2785c0 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -18,6 +18,7 @@
 #include <linux/module.h>
 #include <linux/kref.h>
 #include <linux/eventfd.h>
+#include <linux/checkpoint.h>
 
 struct eventfd_ctx {
 	struct kref kref;
@@ -287,11 +288,65 @@ static ssize_t eventfd_write(struct file *file, const char __user *buf, size_t c
 	return res;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int eventfd_checkpoint(struct ckpt_ctx *ckpt_ctx, struct file *file)
+{
+	struct eventfd_ctx *ctx;
+	struct ckpt_hdr_file_eventfd *h;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ckpt_ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+	h->common.f_type = CKPT_FILE_EVENTFD;
+	ret = checkpoint_file_common(ckpt_ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ctx = file->private_data;
+	h->count = ctx->count;
+	h->flags = ctx->flags;
+	ret = ckpt_write_obj(ckpt_ctx, &h->common.h);
+out:
+	ckpt_hdr_put(ckpt_ctx, h);
+	return ret;
+}
+
+struct file *eventfd_restore(struct ckpt_ctx *ckpt_ctx,
+			     struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_eventfd *h = (struct ckpt_hdr_file_eventfd *) ptr;
+	struct file *evfile;
+	int evfd, ret;
+
+	/* Already know type == CKPT_HDR_FILE and f_type == CKPT_FILE_EVENTFD */
+	if (h->common.h.len != sizeof(*h))
+		return ERR_PTR(-EINVAL);
+
+	evfd = sys_eventfd2(h->count, h->flags);
+	if (evfd < 0)
+		return ERR_PTR(evfd);
+	evfile = fget(evfd);
+	sys_close(evfd);
+	if (!evfile)
+		return ERR_PTR(-EBUSY);
+
+	ret = restore_file_common(ckpt_ctx, evfile, &h->common);
+	if (ret < 0) {
+		fput(evfile);
+		return ERR_PTR(ret);
+	}
+	return evfile;
+}
+#else
+#define eventfd_checkpoint NULL
+#endif
+
 static const struct file_operations eventfd_fops = {
 	.release	= eventfd_release,
 	.poll		= eventfd_poll,
 	.read		= eventfd_read,
 	.write		= eventfd_write,
+	.checkpoint     = eventfd_checkpoint,
 };
 
 /**
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b96d2dc..0b36430 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -481,6 +481,8 @@ enum file_type {
 #define CKPT_FILE_TTY CKPT_FILE_TTY
 	CKPT_FILE_EPOLL,
 #define CKPT_FILE_EPOLL CKPT_FILE_EPOLL
+	CKPT_FILE_EVENTFD,
+#define CKPT_FILE_EVENTFD CKPT_FILE_EVENTFD
 	CKPT_FILE_MAX
 #define CKPT_FILE_MAX CKPT_FILE_MAX
 };
@@ -505,6 +507,12 @@ struct ckpt_hdr_file_pipe {
 	__s32 pipe_objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_eventfd {
+	struct ckpt_hdr_file common;
+	__u64 count;
+	__u32 flags;
+} __attribute__((aligned(8)));
+
 /* socket */
 struct ckpt_hdr_socket {
 	struct ckpt_hdr h;
diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
index 91bb4f2..2ce8525 100644
--- a/include/linux/eventfd.h
+++ b/include/linux/eventfd.h
@@ -39,6 +39,16 @@ ssize_t eventfd_ctx_read(struct eventfd_ctx *ctx, int no_wait, __u64 *cnt);
 int eventfd_ctx_remove_wait_queue(struct eventfd_ctx *ctx, wait_queue_t *wait,
 				  __u64 *cnt);
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+struct ckpt_hdr_file;
+
+struct file *eventfd_restore(struct ckpt_ctx *ckpt_ctx,
+			     struct ckpt_hdr_file *ptr);
+#else
+#define eventfd_restore NULL
+#endif
+
 #else /* CONFIG_EVENTFD */
 
 /*
@@ -77,6 +87,8 @@ static inline int eventfd_ctx_remove_wait_queue(struct eventfd_ctx *ctx,
 	return -ENOSYS;
 }
 
+#define eventfd_restore NULL
+
 #endif
 
 #endif /* _LINUX_EVENTFD_H */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
