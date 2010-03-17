Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D164E62003E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:24:12 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 82/96] c/r: checkpoint/restart epoll sets
Date: Wed, 17 Mar 2010 12:09:10 -0400
Message-Id: <1268842164-5590-83-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-82-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Matt Helsley <matthltc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Matt Helsley <matthltc@us.ibm.com>

Save/restore epoll items during checkpoint/restart respectively.

Output the epoll header and items separately. Chunk the output much
like the pid array gets chunked. This ensures that even sub-order 0
allocations will enable checkpoint of large epoll sets. A subsequent
patch will do something similar for the restore path.

On restart, we grab a piece of memory suitable to store a "chunk" of
items for input. Read the input one chunk at a time and add epoll
items for each item in the chunk.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>

Changelog [v19]:
  - [Oren Laadan] Fix broken compilation for no-c/r architectures
Changelog [v19-rc1]:
  - [Oren Laadan] Return -EBUSY (not BUG_ON) if fd is gone on restart
  - [Oren Laadan] Fix the chunk size instead of auto-tune

Changelog v5:
	Fix potential recursion during collect.
	Replace call to ckpt_obj_collect() with ckpt_collect_file().
		[Oren]
	Fix checkpoint leak detection when there are more items than
		expected.
	Cleanup/simplify error write paths. (will complicate in a later
		patch) [Oren]
	Remove files_deferq bits. [Oren]
	Remove extra newline. [Oren]
	Remove aggregate check on number of watches added. [Oren]
		This is OK since these will be done individually anyway.
	Remove check for negative objrefs during restart. [Oren]
	Fixup comment regarding race that indicates checkpoint leaks.
		[Oren]
	s/ckpt_read_obj/ckpt_read_buf_type/ [Oren]
		Patch for lots of epoll items follows.
	Moved sys_close(epfd) right under fget(). [Oren]
	Use CKPT_HDR_BUFFER rather than custome ckpt_read/write_*
		This makes it more similar to the pid array code. [Oren]
		It also simplifies the error recovery paths.
	Tested polling a pipe and 50,000 UNIX sockets.

Changelog v4: ckpt-v18
	Use files_deferq as submitted by Dan Smith
		Cleanup to only report >= 1 items when debugging.

Changelog v3: [unposted]
	Removed most of the TODOs -- the remainder will be removed by
		subsequent patches.
	Fixed missing ep_file_collect() [Serge]
	Rather than include checkpoint_hdr.h declare (but do not define)
		the two structs needed in eventpoll.h [Oren]
	Complain with ckpt_write_err() when we detect checkpoint obj
		leaks. [Oren]
	Remove redundant is_epoll_file() check in collect. [Oren]
	Move epfile_objref lookup to simplify error handling. [Oren]
	Simplify error handling with early return in
		ep_eventpoll_checkpoint(). [Oren]
	Cleaned up a comment. [Oren]
	Shorten CKPT_HDR_FILE_EPOLL_ITEMS (-FILE) [Oren]
		Renumbered to indicate that it follows the file table.
	Renamed the epoll struct in checkpoint_hdr.h [Oren]
		Also renamed substruct.
	Fixup return of empty ep_file_restore(). [Oren]
	Changed some error returns. [Oren]
	Changed some tests to BUG_ON(). [Oren]
	Factored out watch insert with epoll_ctl() into do_epoll_ctl().
		[Cedric, Oren]

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/files.c             |    7 +
 fs/eventpoll.c                 |  334 ++++++++++++++++++++++++++++++++++++----
 include/linux/checkpoint_hdr.h |   18 ++
 include/linux/eventpoll.h      |   17 ++-
 4 files changed, 347 insertions(+), 29 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index bcc1fbf..6aaaf22 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -22,6 +22,7 @@
 #include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/eventpoll.h>
 #include <net/sock.h>
 
 
@@ -637,6 +638,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_TTY,
 		.restore = tty_file_restore,
 	},
+	/* epoll */
+	{
+		.file_name = "EPOLL",
+		.file_type = CKPT_FILE_EPOLL,
+		.restore = ep_file_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index bd056a5..7f1a091 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -39,6 +39,9 @@
 #include <asm/mman.h>
 #include <asm/atomic.h>
 
+#include <linux/checkpoint.h>
+#include <linux/deferqueue.h>
+
 /*
  * LOCKING:
  * There are three level of locking required by epoll :
@@ -671,10 +674,20 @@ static unsigned int ep_eventpoll_poll(struct file *file, poll_table *wait)
 	return pollflags != -1 ? pollflags : 0;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file);
+#else
+#define ep_eventpoll_checkpoint NULL
+#define ep_file_collect NULL
+#endif
+
 /* File callbacks that implement the eventpoll file behaviour */
 static const struct file_operations eventpoll_fops = {
 	.release	= ep_eventpoll_release,
-	.poll		= ep_eventpoll_poll
+	.poll		= ep_eventpoll_poll,
+	.checkpoint 	= ep_eventpoll_checkpoint,
+	.collect 	= ep_file_collect,
 };
 
 /* Fast test to see if the file is an evenpoll file */
@@ -1226,35 +1239,18 @@ SYSCALL_DEFINE1(epoll_create, int, size)
  * the eventpoll file that enables the insertion/removal/change of
  * file descriptors inside the interest set.
  */
-SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
-		struct epoll_event __user *, event)
+int do_epoll_ctl(int op, int fd,
+		 struct file *file, struct file *tfile,
+		 struct epoll_event *epds)
 {
 	int error;
-	struct file *file, *tfile;
 	struct eventpoll *ep;
 	struct epitem *epi;
-	struct epoll_event epds;
-
-	error = -EFAULT;
-	if (ep_op_has_event(op) &&
-	    copy_from_user(&epds, event, sizeof(struct epoll_event)))
-		goto error_return;
-
-	/* Get the "struct file *" for the eventpoll file */
-	error = -EBADF;
-	file = fget(epfd);
-	if (!file)
-		goto error_return;
-
-	/* Get the "struct file *" for the target file */
-	tfile = fget(fd);
-	if (!tfile)
-		goto error_fput;
 
 	/* The target file descriptor must support poll */
 	error = -EPERM;
 	if (!tfile->f_op || !tfile->f_op->poll)
-		goto error_tgt_fput;
+		return error;
 
 	/*
 	 * We have to check that the file structure underneath the file descriptor
@@ -1263,7 +1259,7 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
 	 */
 	error = -EINVAL;
 	if (file == tfile || !is_file_epoll(file))
-		goto error_tgt_fput;
+		return error;
 
 	/*
 	 * At this point it is safe to assume that the "private_data" contains
@@ -1284,8 +1280,8 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
 	switch (op) {
 	case EPOLL_CTL_ADD:
 		if (!epi) {
-			epds.events |= POLLERR | POLLHUP;
-			error = ep_insert(ep, &epds, tfile, fd);
+			epds->events |= POLLERR | POLLHUP;
+			error = ep_insert(ep, epds, tfile, fd);
 		} else
 			error = -EEXIST;
 		break;
@@ -1297,15 +1293,46 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
 		break;
 	case EPOLL_CTL_MOD:
 		if (epi) {
-			epds.events |= POLLERR | POLLHUP;
-			error = ep_modify(ep, epi, &epds);
+			epds->events |= POLLERR | POLLHUP;
+			error = ep_modify(ep, epi, epds);
 		} else
 			error = -ENOENT;
 		break;
 	}
 	mutex_unlock(&ep->mtx);
 
-error_tgt_fput:
+	return error;
+}
+
+/*
+ * The following function implements the controller interface for
+ * the eventpoll file that enables the insertion/removal/change of
+ * file descriptors inside the interest set.
+ */
+SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
+		struct epoll_event __user *, event)
+{
+	int error;
+	struct file *file, *tfile;
+	struct epoll_event epds;
+
+	error = -EFAULT;
+	if (ep_op_has_event(op) &&
+	    copy_from_user(&epds, event, sizeof(struct epoll_event)))
+		goto error_return;
+
+	/* Get the "struct file *" for the eventpoll file */
+	error = -EBADF;
+	file = fget(epfd);
+	if (!file)
+		goto error_return;
+
+	/* Get the "struct file *" for the target file */
+	tfile = fget(fd);
+	if (!tfile)
+		goto error_fput;
+
+	error = do_epoll_ctl(op, fd, file, tfile, &epds);
 	fput(tfile);
 error_fput:
 	fput(file);
@@ -1413,6 +1440,257 @@ SYSCALL_DEFINE6(epoll_pwait, int, epfd, struct epoll_event __user *, events,
 
 #endif /* HAVE_SET_RESTORE_SIGMASK */
 
+#ifdef CONFIG_CHECKPOINT
+static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct rb_node *rbp;
+	struct eventpoll *ep;
+	int ret = 0;
+
+	ep = file->private_data;
+	mutex_lock(&ep->mtx);
+	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
+		struct epitem *epi;
+
+		epi = rb_entry(rbp, struct epitem, rbn);
+		if (is_file_epoll(epi->ffd.file))
+			continue; /* Don't recurse */
+		ret = ckpt_collect_file(ctx, epi->ffd.file);
+		if (ret < 0)
+			break;
+	}
+	mutex_unlock(&ep->mtx);
+	return ret;
+}
+
+struct epoll_deferq_entry {
+	struct ckpt_ctx *ctx;
+	struct file *epfile;
+};
+
+#define CKPT_EPOLL_CHUNK  (8096 / (int) sizeof(struct ckpt_eventpoll_item))
+
+static int ep_items_checkpoint(void *data)
+{
+	struct epoll_deferq_entry *dq_entry = data;
+	struct ckpt_ctx *ctx;
+	struct ckpt_hdr_eventpoll_items *h;
+	struct ckpt_eventpoll_item *items;
+	struct rb_node *rbp;
+	struct eventpoll *ep;
+	__s32 epfile_objref;
+	int num_items = 0, ret;
+
+	ctx = dq_entry->ctx;
+
+	epfile_objref = ckpt_obj_lookup(ctx, dq_entry->epfile, CKPT_OBJ_FILE);
+	BUG_ON(epfile_objref <= 0);
+
+	ep = dq_entry->epfile->private_data;
+	mutex_lock(&ep->mtx);
+	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp))
+		num_items++;
+	mutex_unlock(&ep->mtx);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_EPOLL_ITEMS);
+	if (!h)
+		return -ENOMEM;
+	h->num_items = num_items;
+	h->epfile_objref = epfile_objref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret || !num_items)
+		return ret;
+
+	ret = ckpt_write_obj_type(ctx, NULL, sizeof(*items)*num_items,
+				  CKPT_HDR_BUFFER);
+	if (ret < 0)
+		return ret;
+
+	items = kzalloc(sizeof(*items) * CKPT_EPOLL_CHUNK, GFP_KERNEL);
+	if (!items)
+		return -ENOMEM;
+
+	/*
+	 * Walk the rbtree copying items into the chunk of memory and then
+	 * writing them to the checkpoint image
+	 */
+	ret = 0;
+	mutex_lock(&ep->mtx);
+	rbp = rb_first(&ep->rbr);
+	while ((num_items > 0) && rbp) {
+		int n = min(num_items, CKPT_EPOLL_CHUNK);
+		int j;
+
+		for (j = 0; rbp && j < n; j++, rbp = rb_next(rbp)) {
+			struct epitem *epi;
+			int objref;
+
+			epi = rb_entry(rbp, struct epitem, rbn);
+			items[j].fd = epi->ffd.fd;
+			items[j].events = epi->event.events;
+			items[j].data = epi->event.data;
+			objref = ckpt_obj_lookup(ctx, epi->ffd.file,
+						 CKPT_OBJ_FILE);
+			if (objref <= 0)
+				goto unlock;
+			items[j].file_objref = objref;
+		}
+		ret = ckpt_kwrite(ctx, items, n*sizeof(*items));
+		if (ret < 0)
+			break;
+		num_items -= n;
+	}
+unlock:
+	mutex_unlock(&ep->mtx);
+	kfree(items);
+	if (num_items != 0 || (num_items == 0 && rbp))
+		ret = -EBUSY; /* extra item(s) -- checkpoint obj leak */
+	if (ret)
+		ckpt_err(ctx, ret, "Checkpointing epoll items.\n");
+	return ret;
+}
+
+static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file *h;
+	struct epoll_deferq_entry dq_entry;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+	h->f_type = CKPT_FILE_EPOLL;
+	ret = checkpoint_file_common(ctx, file, h);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	/*
+	 * Defer saving the epoll items until all of the ffd.file pointers
+	 * have an objref; after the file table has been checkpointed.
+	 */
+	dq_entry.ctx = ctx;
+	dq_entry.epfile = file;
+	ret = deferqueue_add(ctx->files_deferq, &dq_entry,
+			     sizeof(dq_entry), ep_items_checkpoint, NULL);
+out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int ep_items_restore(void *data)
+{
+	struct ckpt_ctx *ctx = deferqueue_data_ptr(data);
+	struct ckpt_hdr_eventpoll_items *h;
+	struct ckpt_eventpoll_item *items = NULL;
+	struct eventpoll *ep;
+	struct file *epfile = NULL;
+	int ret, num_items;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_EPOLL_ITEMS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+	num_items = h->num_items;
+	epfile = ckpt_obj_fetch(ctx, h->epfile_objref, CKPT_OBJ_FILE);
+	ckpt_hdr_put(ctx, h);
+
+	/* Make sure userspace didn't give us a ref to a non-epoll file. */
+	if (IS_ERR(epfile))
+		return PTR_ERR(epfile);
+	if (!is_file_epoll(epfile))
+		return -EINVAL;
+	if (!num_items)
+		return 0;
+
+	ret = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_BUFFER);
+	if (ret < 0)
+		return ret;
+	/* Make sure the items match the size we expect */
+	if (num_items != (ret / sizeof(*items)))
+		return -EINVAL;
+
+	items = kzalloc(sizeof(*items) * CKPT_EPOLL_CHUNK, GFP_KERNEL);
+	if (!items)
+		return -ENOMEM;
+
+	ep = epfile->private_data;
+
+	while (num_items > 0) {
+		int n = min(num_items, CKPT_EPOLL_CHUNK);
+		int j;
+
+		ret = ckpt_kread(ctx, items, n*sizeof(*items));
+		if (ret < 0)
+			break;
+
+		/* Restore the epoll items/watches */
+		for (j = 0; !ret && j < n; j++) {
+			struct epoll_event epev;
+			struct file *tfile;
+
+			tfile = ckpt_obj_fetch(ctx, items[j].file_objref,
+					       CKPT_OBJ_FILE);
+			if (IS_ERR(tfile)) {
+				ret = PTR_ERR(tfile);
+				goto out;
+			}
+			epev.events = items[j].events;
+			epev.data = items[j].data;
+			ret = do_epoll_ctl(EPOLL_CTL_ADD, items[j].fd,
+					   epfile, tfile, &epev);
+		}
+		num_items -= n;
+	}
+out:
+	kfree(items);
+	return ret;
+}
+
+struct file *ep_file_restore(struct ckpt_ctx *ctx,
+			     struct ckpt_hdr_file *h)
+{
+	struct file *epfile;
+	int epfd, ret;
+
+	if (h->h.type != CKPT_HDR_FILE ||
+	    h->h.len  != sizeof(*h) ||
+	    h->f_type != CKPT_FILE_EPOLL)
+		return ERR_PTR(-EINVAL);
+
+	epfd = sys_epoll_create1(h->f_flags & EPOLL_CLOEXEC);
+	if (epfd < 0)
+		return ERR_PTR(epfd);
+	epfile = fget(epfd);
+	sys_close(epfd); /* harmless even if an error occured */
+	if (!epfile)  /* can happen with a malicious user */
+		return ERR_PTR(-EBUSY);
+
+	/*
+	 * Needed before we can properly restore the watches and enforce the
+	 * limit on watch numbers.
+	 */
+	ret = restore_file_common(ctx, epfile, h);
+	if (ret < 0)
+		goto fput_out;
+
+	/*
+	 * Defer restoring the epoll items until the file table is
+	 * fully restored. Ensures that valid file objrefs will resolve.
+	 */
+	ret = deferqueue_add_ptr(ctx->files_deferq, ctx, ep_items_restore, NULL);
+	if (ret < 0) {
+fput_out:
+		fput(epfile);
+		epfile = ERR_PTR(ret);
+	}
+	return epfile;
+}
+
+#endif /* CONFIG_CHECKPOINT */
+
 static int __init eventpoll_init(void)
 {
 	struct sysinfo si;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4fe63b1..b96d2dc 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -119,6 +119,8 @@ enum {
 #define CKPT_HDR_TTY CKPT_HDR_TTY
 	CKPT_HDR_TTY_LDISC,
 #define CKPT_HDR_TTY_LDISC CKPT_HDR_TTY_LDISC
+	CKPT_HDR_EPOLL_ITEMS,  /* must be after file-table */
+#define CKPT_HDR_EPOLL_ITEMS CKPT_HDR_EPOLL_ITEMS
 
 	CKPT_HDR_MM = 401,
 #define CKPT_HDR_MM CKPT_HDR_MM
@@ -477,6 +479,8 @@ enum file_type {
 #define CKPT_FILE_SOCKET CKPT_FILE_SOCKET
 	CKPT_FILE_TTY,
 #define CKPT_FILE_TTY CKPT_FILE_TTY
+	CKPT_FILE_EPOLL,
+#define CKPT_FILE_EPOLL CKPT_FILE_EPOLL
 	CKPT_FILE_MAX
 #define CKPT_FILE_MAX CKPT_FILE_MAX
 };
@@ -693,6 +697,20 @@ struct ckpt_hdr_file_socket {
 	__s32 sock_objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_eventpoll_items {
+	struct ckpt_hdr h;
+	__s32  epfile_objref;
+	__u32  num_items;
+} __attribute__((aligned(8)));
+
+/* Contained in a CKPT_HDR_BUFFER following the ckpt_hdr_eventpoll_items */
+struct ckpt_eventpoll_item {
+	__u64 data;
+	__u32 fd;
+	__s32 file_objref;
+	__u32 events;
+} __attribute__((aligned(8)));
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
diff --git a/include/linux/eventpoll.h b/include/linux/eventpoll.h
index f6856a5..52282ae 100644
--- a/include/linux/eventpoll.h
+++ b/include/linux/eventpoll.h
@@ -56,6 +56,9 @@ struct file;
 
 
 #ifdef CONFIG_EPOLL
+struct ckpt_ctx;
+struct ckpt_hdr_file;
+
 
 /* Used to initialize the epoll bits inside the "struct file" */
 static inline void eventpoll_init_file(struct file *file)
@@ -95,11 +98,23 @@ static inline void eventpoll_release(struct file *file)
 	eventpoll_release_file(file);
 }
 
-#else
 
+#ifdef CONFIG_CHECKPOINT
+extern struct file *ep_file_restore(struct ckpt_ctx *ctx,
+				    struct ckpt_hdr_file *h);
+#endif
+#else
+/* !defined(CONFIG_EPOLL) */
 static inline void eventpoll_init_file(struct file *file) {}
 static inline void eventpoll_release(struct file *file) {}
 
+#ifdef CONFIG_CHECKPOINT
+static inline struct file *ep_file_restore(struct ckpt_ctx *ctx,
+					   struct ckpt_hdr_file *ptr)
+{
+	return ERR_PTR(-ENOSYS);
+}
+#endif
 #endif
 
 #endif /* #ifdef __KERNEL__ */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
