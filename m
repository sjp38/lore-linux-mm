Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A269B620035
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:21:43 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 76/96] c/r: Add AF_UNIX support (v12)
Date: Wed, 17 Mar 2010 12:09:04 -0400
Message-Id: <1268842164-5590-77-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-76-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Dan Smith <danms@us.ibm.com>, Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Dan Smith <danms@us.ibm.com>

This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
has been tested with a single and multiple processes, and with data inflight
at the time of checkpoint.  It supports socketpair()s, path-based, and
abstract sockets.

Changes in ckpt-v19:
  - [Serge Hallyn] skb->tail can be offset

Changes in ckpt-v19-rc3:
  - Rebase to kernel 2.6.33: export and leverage sock_alloc_file()
  - [Nathan Lynch] Fix net/checkpoint.c for 64-bit

Changes in ckpt-v19-rc2:
  - Change select uses of ckpt_debug() to ckpt_err() in net c/r
  - [Dan Smith] Unify skb read/write functions and handle fragmented buffers
  - [Dan Smith] Update buffer restore code to match the new format

Changes in ckpt-v19-rc1:
  - [Dan Smith] Fix compile issue with CONFIG_CHECKPOINT=n
  - [Dan Smith] Remove an unnecessary check on socket restart
  - [Matt Helsley] Add cpp definitions for enums
  - [Dan Smith] Pass the stored sock->protocol into sock_create() on restore

Changes in v12:
  - Collect sockets for leak-detection
  - Adjust socket reference count during leak detection phase

Changes in v11:
  - Create a struct socket for orphan socket during checkpoint
  - Make sockets proper objhash objects and use checkpoint_obj() on them
  - Rename headerless struct ckpt_hdr_* to struct ckpt_*
  - Remove struct timeval from socket header
  - Save and restore UNIX socket peer credentials
  - Set socket flags on restore using sock_setsockopt() where possible
  - Fail on the TIMESTAMPING_* flags for the moment (with a TODO)
  - Remove other explicit flag checks that are no longer copied blindly
  - Changed functions/variables names to follow existing conventions
  - Use proto_ops->{checkpoint,restart} methods for af_unix
  - Cleanup sock_file_restore()/sock_file_checkpoint()
  - Make ckpt_hdr_socket be part of ckpt_hdr_file_socket
  - Fold do_sock_file_checkpoint() into sock_file_checkpoint()
  - Fold do_sock_file_restore() into sock_file_restore()
  - Move sock_file_{checkpoint,restore} to net/checkpoint.c
  - Properly define sock_file_{checkpoint,restore} in header file
  - sock_file_restore() now calls restore_file_common()

Changes in v10:
  - Moved header structure definitions back to checkpoint_hdr.h
  - Moved AF_UNIX checkpoint/restart code to net/unix/checkpoint.c
  - Make sock_unix_*() functions only compile if CONFIG_UNIX=y
  - Add TODO for CONFIG_UNIX=m case

Changes in v9:
  - Fix double-free of skb's in the list and target holding queue in the
    error path of sock_copy_buffers()
  - Adjust use of ckpt_read_string() to match new signature

Changes in v8:
  - Fix stale dev_alloc_skb() from before the conversion to skb_clone()
  - Fix a couple of broken error paths
  - Fix memory leak of kvec.iov_base on successful return from sendmsg()
  - Fix condition for deciding when to run sock_cptrst_verify()
  - Fix buffer queue copy algorithm to hold the lock during walk(s)
  - Log the errno when either getname() or getpeer() fails
  - Add comments about ancillary messages in the UNIX queue
  - Add TODO comments for credential restore and flags via setsockopt()
  - Add TODO comment about strangely-connected dgram sockets and the use
    of sendmsg(peer)

Changes in v7:
  - Fix failure to free iov_base in error path of sock_read_buffer()
  - Change sock_read_buffer() to use _ckpt_read_obj_type() to get the
    header length and then use ckpt_kread() directly to read the payload
  - Change sock_read_buffers() to sock_unix_read_buffers() and break out
    some common functionality to better accommodate the subsequent INET
    patch
  - Generalize sock_unix_getnames() into sock_getnames() so INET can use it
  - Change skb_morph() to skb_clone() which uses the more common path and
    still avoids the copy
  - Add check to validate the socket type before creating socket
    on restore
  - Comment the CAP_NET_ADMIN override in sock_read_buffer_hdr
  - Strengthen the comment about priming the buffer limits
  - Change the objhash functions to deny direct checkpoint of sockets and
    remove the reference counting function
  - Change SOCKET_BUFFERS to SOCKET_QUEUE
  - Change this,peer objrefs to signed integers
  - Remove names from internal socket structures
  - Fix handling of sock_copy_buffers() result
  - Use ckpt_fill_fname() instead of d_path() for writing CWD
  - Use sock_getname() and sock_getpeer() for proper security hookage
  - Return -ENOSYS for unsupported socket families in checkpoint and restart
  - Use sock_setsockopt() and sock_getsockopt() where possible to save and
    restore socket option values
  - Check for SOCK_DESTROY flag in the global verify function because none
    of our supported socket types use it
  - Check for SOCK_USE_WRITE_QUEUE in AF_UNIX restore function because
    that flag should not be used on such a socket
  - Check socket state in UNIX restart path to validate the subset of valid
    values

Changes in v6:
  - Moved the socket addresses to the per-type header
  - Eliminated the HASCWD flag
  - Remove use of ckpt_write_err() in restart paths
  - Change the order in which buffers are read so that we can set the
    socket's limit equal to the size of the image's buffers (if appropriate)
    and then restore the original values afterwards.
  - Use the ckpt_validate_errno() helper
  - Add a check to make sure that we didn't restore a (UNIX) socket with
    any skb's in the send buffer
  - Fix up sock_unix_join() to not leave addr uninitialized for socketpair
  - Remove inclusion of checkpoint_hdr.h in the socket files
  - Make sock_unix_write_cwd() use ckpt_write_string() and use the new
    ckpt_read_string() for reading the cwd
  - Use the restored realcred credentials in sock_unix_join()
  - Fix error path of the chdir_and_bind
  - Change the algorithm for reloading the socket buffers to use sendmsg()
    on the socket's peer for better accounting
  - For DGRAM sockets, check the backlog value against the system max
    to avoid letting a restart bypass the overloaded queue length
  - Use sock_bind() instead of sock->ops->bind() to gain the security hook
  - Change "restart" to "restore" in some of the function names

Changes in v5:
  - Change laddr and raddr buffers in socket header to be long enough
    for INET6 addresses
  - Place socket.c and sock.h function definitions inside #ifdef
    CONFIG_CHECKPOINT
  - Add explicit check in sock_unix_makeaddr() to refuse if the
    checkpoint image specifies an addr length of 0
  - Split sock_unix_restart() into a few pieces to facilitate:
  - Changed behavior of the unix restore code so that unlinked LISTEN
    sockets don't do a bind()...unlink()
  - Save the base path of a bound socket's path so that we can chdir()
    to the base before bind() if it is a relative path
  - Call bind() for any socket that is not established but has a
    non-zero-length local address
  - Enforce the current sysctl limit on socket buffer size during restart
    unless the user holds CAP_NET_ADMIN
  - Unlink a path-based socket before calling bind()

Changes in v4:
  - Changed the signdness of rcvlowat, rcvtimeo, sndtimeo, and backlog
    to match their struct sock definitions.  This should avoid issues
    with sign extension.
  - Add a sock_cptrst_verify() function to be run at restore time to
    validate several of the values in the checkpoint image against
    limits, flag masks, etc.
  - Write an error string with ctk_write_err() in the obscure cases
  - Don't write socket buffers for listen sockets
  - Sanity check address lengths before we agree to allocate memory
  - Check the result of inserting the peer object in the objhash on
    restart
  - Check return value of sock_cptrst() on restart
  - Change logic in remote getname() phase of checkpoint to not fail for
    closed (et al) sockets
  - Eliminate the memory copy while reading socket buffers on restart

Changes in v3:
  - Move sock_file_checkpoint() above sock_file_restore()
  - Change __sock_file_*() functions to do_sock_file_*()
  - Adjust some of the struct cr_hdr_socket alignment
  - Improve the sock_copy_buffers() algorithm to avoid locking the source
    queue for the entire operation
  - Fix alignment in the socket header struct(s)
  - Move the per-protocol structure (ckpt_hdr_socket_un) out of the
    common socket header and read/write it separately
  - Fix missing call to sock_cptrst() in restore path
  - Break out the socket joining into another function
  - Fix failure to restore the socket address thus fixing getname()
  - Check the state values on restart
  - Fix case of state being TCP_CLOSE, which allows dgram sockets to be
    properly connected (if appropriate) to their peer and maintain the
    sockaddr for getname() operation
  - Fix restoring a listening socket that has been unlink()'d
  - Fix checkpointing sockets with an in-flight FD-passing SKB.  Fail
    with EBUSY.
  - Fix checkpointing listening sockets with an unaccepted connection.
    Fail with EBUSY.
  - Changed 'un' to 'unix' in function and structure names

Changes in v2:
  - Change GFP_KERNEL to GFP_ATOMIC in sock_copy_buffers() (this seems
    to be rather common in other uses of skb_copy())
  - Move the ckpt_hdr_socket structure definition to linux/socket.h
  - Fix whitespace issue
  - Move sock_file_checkpoint() to net/socket.c for symmetry

Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: netdev@vger.kernel.org
Acked-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Dan Smith <danms@us.ibm.com>
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/files.c             |    7 +
 checkpoint/objhash.c           |   69 +++
 include/linux/checkpoint.h     |    8 +
 include/linux/checkpoint_hdr.h |  117 +++++-
 include/linux/net.h            |    2 +
 include/net/af_unix.h          |   15 +
 include/net/sock.h             |   12 +
 net/Makefile                   |    2 +
 net/checkpoint.c               |  983 ++++++++++++++++++++++++++++++++++++++++
 net/socket.c                   |    6 +-
 net/unix/Makefile              |    1 +
 net/unix/af_unix.c             |    9 +
 net/unix/checkpoint.c          |  647 ++++++++++++++++++++++++++
 13 files changed, 1872 insertions(+), 6 deletions(-)
 create mode 100644 net/checkpoint.c
 create mode 100644 net/unix/checkpoint.c

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 63a611f..900d1c1 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -22,6 +22,7 @@
 #include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
 
 
 /**************************************************************************
@@ -624,6 +625,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_FIFO,
 		.restore = fifo_file_restore,
 	},
+	/* socket */
+	{
+		.file_name = "SOCKET",
+		.file_type = CKPT_FILE_SOCKET,
+		.restore = sock_file_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index ea2f063..b1f257f 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -20,6 +20,7 @@
 #include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <net/sock.h>
 
 struct ckpt_obj;
 struct ckpt_obj_ops;
@@ -234,6 +235,40 @@ static void obj_groupinfo_drop(void *ptr, int lastref)
 	put_group_info((struct group_info *) ptr);
 }
 
+static int obj_sock_grab(void *ptr)
+{
+	sock_hold((struct sock *) ptr);
+	return 0;
+}
+
+static void obj_sock_drop(void *ptr, int lastref)
+{
+	struct sock *sk = (struct sock *) ptr;
+
+	/*
+	 * Sockets created during restart are graft()ed, i.e. have a
+	 * valid @sk->sk_socket. Because only an fput() results in the
+	 * necessary sock_release(), we may leak the struct socket of
+	 * sockets that were not attached to a file. Therefore, if
+	 * @lastref is set, we hereby invoke sock_release() on sockets
+	 * that we have put into the objhash but were never attached
+	 * to a file.
+	 */
+	if (lastref && sk->sk_socket && !sk->sk_socket->file) {
+		struct socket *sock = sk->sk_socket;
+		sock_orphan(sk);
+		sock->sk = NULL;
+		sock_release(sock);
+	}
+
+	sock_put((struct sock *) ptr);
+}
+
+static int obj_sock_users(void *ptr)
+{
+	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -362,6 +397,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_groupinfo,
 		.restore = restore_groupinfo,
 	},
+	/* sock object */
+	{
+		.obj_name = "SOCKET",
+		.obj_type = CKPT_OBJ_SOCK,
+		.ref_drop = obj_sock_drop,
+		.ref_grab = obj_sock_grab,
+		.ref_users = obj_sock_users,
+		.checkpoint = checkpoint_sock,
+		.restore = restore_sock,
+	},
 };
 
 
@@ -756,6 +801,26 @@ static void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
  */
 
 /**
+ * obj_sock_adjust_users - remove implicit reference on DEAD sockets
+ * @obj: CKPT_OBJ_SOCK object to adjust
+ *
+ * Sockets that have been disconnected from their struct file have
+ * a reference count one less than normal sockets.  The objhash's
+ * assumption of such a reference is therefore incorrect, so we correct
+ * it here.
+ */
+static inline void obj_sock_adjust_users(struct ckpt_obj *obj)
+{
+	struct sock *sk = (struct sock *)obj->ptr;
+
+	if (sock_flag(sk, SOCK_DEAD)) {
+		obj->users--;
+		ckpt_debug("Adjusting SOCK %i count to %i\n",
+			   obj->objref, obj->users);
+	}
+}
+
+/**
  * ckpt_obj_contained - test if shared objects are contained in checkpoint
  * @ctx: checkpoint context
  *
@@ -780,6 +845,10 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
 	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
 		if (!obj->ops->ref_users)
 			continue;
+
+		if (obj->ops->obj_type == CKPT_OBJ_SOCK)
+			obj_sock_adjust_users(obj);
+
 		if (obj->ops->ref_users(obj->ptr) != obj->users) {
 			ckpt_err(ctx, -EBUSY,
 				 "%(O)%(P)%(S)Usage leak (%d != %d)\n",
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 220388d..e0f4bd1 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -33,6 +33,7 @@
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/err.h>
+#include <net/sock.h>
 
 /* sycall helpers */
 extern long do_sys_checkpoint(pid_t pid, int fd,
@@ -97,6 +98,13 @@ extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
 /* pids */
 extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
 
+/* socket functions */
+extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
+			      struct socket *socket,
+			      struct sockaddr *loc, unsigned *loc_len,
+			      struct sockaddr *rem, unsigned *rem_len);
+extern struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx);
+
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index f0a41ec..ad2f0f2 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -10,13 +10,15 @@
  *  distribution for more details.
  */
 
-#ifndef __KERNEL__
-#include <sys/types.h>
-#include <linux/types.h>
-#endif
-
 #ifdef __KERNEL__
 #include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/un.h>
+#else
+#include <sys/types.h>
+#include <linux/types.h>
+#include <sys/socket.h>
+#include <sys/un.h>
 #endif
 
 /*
@@ -140,6 +142,17 @@ enum {
 	CKPT_HDR_SIGPENDING,
 #define CKPT_HDR_SIGPENDING CKPT_HDR_SIGPENDING
 
+	CKPT_HDR_SOCKET = 701,
+#define CKPT_HDR_SOCKET CKPT_HDR_SOCKET
+	CKPT_HDR_SOCKET_QUEUE,
+#define CKPT_HDR_SOCKET_QUEUE CKPT_HDR_SOCKET_QUEUE
+	CKPT_HDR_SOCKET_BUFFER,
+#define CKPT_HDR_SOCKET_BUFFER CKPT_HDR_SOCKET_BUFFER
+	CKPT_HDR_SOCKET_FRAG,
+#define CKPT_HDR_SOCKET_FRAG CKPT_HDR_SOCKET_FRAG
+	CKPT_HDR_SOCKET_UNIX,
+#define CKPT_HDR_SOCKET_UNIX CKPT_HDR_SOCKET_UNIX
+
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
 
@@ -195,6 +208,8 @@ enum obj_type {
 #define CKPT_OBJ_USER CKPT_OBJ_USER
 	CKPT_OBJ_GROUPINFO,
 #define CKPT_OBJ_GROUPINFO CKPT_OBJ_GROUPINFO
+	CKPT_OBJ_SOCK,
+#define CKPT_OBJ_SOCK CKPT_OBJ_SOCK
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -444,6 +459,8 @@ enum file_type {
 #define CKPT_FILE_PIPE CKPT_FILE_PIPE
 	CKPT_FILE_FIFO,
 #define CKPT_FILE_FIFO CKPT_FILE_FIFO
+	CKPT_FILE_SOCKET,
+#define CKPT_FILE_SOCKET CKPT_FILE_SOCKET
 	CKPT_FILE_MAX
 #define CKPT_FILE_MAX CKPT_FILE_MAX
 };
@@ -468,6 +485,96 @@ struct ckpt_hdr_file_pipe {
 	__s32 pipe_objref;
 } __attribute__((aligned(8)));
 
+/* socket */
+struct ckpt_hdr_socket {
+	struct ckpt_hdr h;
+
+	struct { /* struct socket */
+		__u64 flags;
+		__u8 state;
+	} socket __attribute__ ((aligned(8)));
+
+	struct { /* struct sock_common */
+		__u32 bound_dev_if;
+		__u32 reuse;
+		__u16 family;
+		__u8 state;
+	} sock_common __attribute__ ((aligned(8)));
+
+	struct { /* struct sock */
+		__s64 rcvlowat;
+		__u64 flags;
+
+		__s64 rcvtimeo;
+		__s64 sndtimeo;
+
+		__u32 err;
+		__u32 err_soft;
+		__u32 priority;
+		__s32 rcvbuf;
+		__s32 sndbuf;
+		__u16 type;
+		__s16 backlog;
+
+		__u8 protocol;
+		__u8 state;
+		__u8 shutdown;
+		__u8 userlocks;
+		__u8 no_check;
+
+		struct linger linger;
+	} sock __attribute__ ((aligned(8)));
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket_queue {
+	struct ckpt_hdr h;
+	__u32 skb_count;
+	__u32 total_bytes;
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket_buffer {
+	struct ckpt_hdr h;
+	__u32 transport_header;
+	__u32 network_header;
+	__u32 mac_header;
+	__u32 lin_len; /* Length of linear data */
+	__u32 frg_len; /* Length of fragment data */
+	__u32 skb_len; /* Length of skb (adjusted) */
+	__u32 hdr_len; /* Length of skipped header */
+	__u32 mac_len;
+	__u32 data_offset; /* Offset of data pointer from head */
+	__s32 sk_objref;
+	__s32 pr_objref;
+	__u16 protocol;
+	__u16 nr_frags;
+	__u8 cb[48];
+};
+
+struct ckpt_hdr_socket_buffer_frag {
+	struct ckpt_hdr h;
+	__u32 size;
+	__u32 offset;
+};
+
+#define CKPT_UNIX_LINKED 1
+struct ckpt_hdr_socket_unix {
+	struct ckpt_hdr h;
+	__s32 this;
+	__s32 peer;
+	__u32 peercred_uid;
+	__u32 peercred_gid;
+	__u32 flags;
+	__u32 laddr_len;
+	__u32 raddr_len;
+	struct sockaddr_un laddr;
+	struct sockaddr_un raddr;
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_file_socket {
+	struct ckpt_hdr_file common;
+	__s32 sock_objref;
+} __attribute__((aligned(8)));
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
diff --git a/include/linux/net.h b/include/linux/net.h
index 72a53b9..9548e45 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -242,6 +242,8 @@ extern int   	     sock_sendmsg(struct socket *sock, struct msghdr *msg,
 				  size_t len);
 extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
 				  size_t size, int flags);
+extern int	     sock_alloc_file(struct socket *sock, struct file **f,
+				     int flags);
 extern int 	     sock_map_fd(struct socket *sock, int flags);
 extern struct socket *sockfd_lookup(int fd, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 1614d78..ee423d1 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -68,4 +68,19 @@ static inline int unix_sysctl_register(struct net *net) { return 0; }
 static inline void unix_sysctl_unregister(struct net *net) {}
 #endif
 #endif
+
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+struct ckpt_hdr_socket;
+extern int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
+extern int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
+			struct ckpt_hdr_socket *h);
+extern int unix_collect(struct ckpt_ctx *ctx, struct socket *sock);
+
+#else
+#define unix_checkpoint NULL
+#define unix_restore NULL
+#define unix_collect NULL
+#endif /* CONFIG_CHECKPOINT */
+
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index 623eb19..6d5f5b3 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1684,4 +1684,16 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
+#ifdef CONFIG_CHECKPOINT
+/* Checkpoint/Restart Functions */
+struct ckpt_ctx;
+struct ckpt_hdr_file;
+extern int checkpoint_sock(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_sock(struct ckpt_ctx *ctx);
+extern int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+extern struct file *sock_file_restore(struct ckpt_ctx *ctx,
+				      struct ckpt_hdr_file *h);
+extern int sock_file_collect(struct ckpt_ctx *ctx, struct file *file);
+#endif
+
 #endif	/* _SOCK_H */
diff --git a/net/Makefile b/net/Makefile
index 1542e72..74b038f 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -65,3 +65,5 @@ ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
 endif
 obj-$(CONFIG_WIMAX)		+= wimax/
+
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
diff --git a/net/checkpoint.c b/net/checkpoint.c
new file mode 100644
index 0000000..386a0c6
--- /dev/null
+++ b/net/checkpoint.c
@@ -0,0 +1,983 @@
+/*
+ *  Copyright 2009 IBM Corporation
+ *
+ *  Author(s): Dan Smith <danms@us.ibm.com>
+ *             Oren Laadan <orenl@cs.columbia.edu>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ */
+
+#include <linux/socket.h>
+#include <linux/mount.h>
+#include <linux/file.h>
+#include <linux/namei.h>
+#include <linux/syscalls.h>
+#include <linux/sched.h>
+#include <linux/fs_struct.h>
+#include <linux/highmem.h>
+
+#include <net/af_unix.h>
+#include <net/tcp_states.h>
+#include <net/tcp.h>
+
+#include <linux/deferqueue.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+struct dq_buffers {
+	struct ckpt_ctx *ctx;
+	struct sock *sk;
+};
+
+static int sock_copy_buffers(struct sk_buff_head *from,
+			     struct sk_buff_head *to,
+			     uint32_t *total_bytes)
+{
+	int count1 = 0;
+	int count2 = 0;
+	int i;
+	struct sk_buff *skb;
+	struct sk_buff **skbs;
+
+	*total_bytes = 0;
+
+	spin_lock(&from->lock);
+	skb_queue_walk(from, skb)
+		count1++;
+	spin_unlock(&from->lock);
+
+	skbs = kzalloc(sizeof(*skbs) * count1, GFP_KERNEL);
+	if (!skbs)
+		return -ENOMEM;
+
+	for (i = 0; i < count1;  i++) {
+		skbs[i] = dev_alloc_skb(0);
+		if (!skbs[i])
+			goto err;
+	}
+
+	i = 0;
+	spin_lock(&from->lock);
+	skb_queue_walk(from, skb) {
+		if (++count2 > count1)
+			break; /* The queue changed as we read it */
+
+		skb_morph(skbs[i], skb);
+		skbs[i]->sk = skb->sk;
+		skb_queue_tail(to, skbs[i]);
+
+		*total_bytes += skb->len;
+		i++;
+	}
+	spin_unlock(&from->lock);
+
+	if (count1 != count2)
+		goto err;
+
+	kfree(skbs);
+
+	return count1;
+ err:
+	while (skb_dequeue(to))
+		; /* Pull all the buffers out of the queue */
+	for (i = 0; i < count1; i++)
+		kfree_skb(skbs[i]);
+	kfree(skbs);
+
+	return -EAGAIN;
+}
+
+static void sock_record_header_info(struct sk_buff *skb,
+				    struct ckpt_hdr_socket_buffer *h)
+{
+
+	h->mac_len = skb->mac_len;
+	h->skb_len = skb->len;
+	h->hdr_len = skb->data - skb->head;
+	h->frg_len = skb->data_len;
+	h->data_offset = (skb->data - skb->head);
+
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	h->transport_header = skb->transport_header;
+	h->network_header = skb->network_header;
+	h->mac_header = skb->mac_header;
+	h->lin_len = (unsigned long) skb->tail;
+#else
+	h->transport_header = skb->transport_header - skb->head;
+	h->network_header = skb->network_header - skb->head;
+	h->mac_header = skb->mac_header - skb->head;
+	h->lin_len = ((unsigned long) skb->tail - (unsigned long) skb->head);
+#endif
+
+	memcpy(h->cb, skb->cb, sizeof(skb->cb));
+	h->nr_frags = skb_shinfo(skb)->nr_frags;
+}
+
+int sock_restore_header_info(struct ckpt_ctx *ctx,
+			     struct sk_buff *skb,
+			     struct ckpt_hdr_socket_buffer *h)
+{
+	if (h->mac_header + h->mac_len != h->network_header) {
+		ckpt_err(ctx, -EINVAL,
+			 "skb mac_header %u+%u != network header %u\n",
+			 h->mac_header, h->mac_len, h->network_header);
+		return -EINVAL;
+	}
+
+	if (h->network_header > h->lin_len) {
+		ckpt_err(ctx, -EINVAL,
+			 "skb network header %u > linear length %u\n",
+			 h->network_header, h->lin_len);
+		return -EINVAL;
+	}
+
+	if (h->transport_header > h->lin_len) {
+		ckpt_err(ctx, -EINVAL,
+			 "skb transport header %u > linear length %u\n",
+			 h->transport_header, h->lin_len);
+		return -EINVAL;
+	}
+
+	if (h->data_offset > h->lin_len) {
+		ckpt_err(ctx, -EINVAL,
+			 "skb data offset %u > linear length %u\n",
+			 h->data_offset, h->lin_len);
+		return -EINVAL;
+	}
+
+	if (h->skb_len > SKB_MAX_ALLOC) {
+		ckpt_err(ctx, -EINVAL,
+			 "skb total length %u larger than max of %lu\n",
+			 h->skb_len, SKB_MAX_ALLOC);
+		return -EINVAL;
+	}
+
+	skb_set_transport_header(skb, h->transport_header);
+	skb_set_network_header(skb, h->network_header);
+	skb_set_mac_header(skb, h->mac_header);
+	skb->mac_len = h->mac_len;
+
+	/* FIXME: This should probably be sanitized per-protocol to
+	 * make sure nothing bad happens if it is hijacked.  For the
+	 * current set of protocols that we restore this way, the data
+	 * contained within is not very risky (flags and sequence
+	 * numbers) but could still be evalutated from a
+	 * could-the-user- have-set-these-flags point of view.
+	 */
+	memcpy(skb->cb, h->cb, sizeof(skb->cb));
+
+	skb->data = skb->head + h->data_offset;
+	skb->len = h->skb_len;
+
+	return 0;
+}
+
+static int sock_restore_skb_frag(struct ckpt_ctx *ctx,
+				 struct sk_buff *skb,
+				 int frag_idx)
+{
+	struct ckpt_hdr_socket_buffer_frag *h;
+	struct page *page;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_FRAG);
+	if (IS_ERR(h)) {
+		ckpt_err(ctx, PTR_ERR(h), "failed to read buffer object\n");
+		return PTR_ERR(h);
+	}
+
+	if ((h->size > PAGE_SIZE) || (h->offset >= PAGE_SIZE)) {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret, "skb frag size=%i,offset=%i > PAGE_SIZE\n",
+			 h->size, h->offset);
+		goto out;
+	}
+
+	page = alloc_page(GFP_KERNEL);
+	if (!page) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = restore_read_page(ctx, page);
+	if (ret) {
+		ckpt_err(ctx, ret, "failed to read fragment: %i\n", ret);
+		__free_page(page);
+	} else {
+		ckpt_debug("read %i+%i for fragment %i\n",
+			   h->offset, h->size, frag_idx);
+		skb_add_rx_frag(skb, frag_idx, page, h->offset, h->size);
+		ret = h->size;
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_socket_buffer *h;
+	struct sk_buff *skb = NULL;
+	int i, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
+	if (IS_ERR(h))
+		return (struct sk_buff *)h;
+
+	ret = -ENOSPC;
+	if (h->lin_len > SKB_MAX_ALLOC) {
+		ckpt_err(ctx, ret, "socket linear buffer too big (%u > %lu)\n",
+			 h->lin_len, SKB_MAX_ALLOC);
+		goto out;
+	} else if (h->frg_len > SKB_MAX_ALLOC) {
+		ckpt_err(ctx, ret, "socket frag size too big (%u > %lu\n",
+			 h->frg_len, SKB_MAX_ALLOC);
+		goto out;
+	} else if (h->nr_frags >= MAX_SKB_FRAGS) {
+		ckpt_err(ctx, ret, "socket frag count too big (%u > %lu\n",
+			 h->nr_frags, MAX_SKB_FRAGS);
+		goto out;
+	}
+
+	skb = alloc_skb(h->lin_len, GFP_KERNEL);
+	if (!skb) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = _ckpt_read_obj_type(ctx, skb_put(skb, h->lin_len),
+				  h->lin_len, CKPT_HDR_BUFFER);
+	ckpt_debug("read linear skb length %u: %i\n", h->lin_len, ret);
+	if (ret < 0)
+		goto out;
+
+	for (i = 0; i < h->nr_frags; i++) {
+		ret = sock_restore_skb_frag(ctx, skb, i);
+		ckpt_debug("read skb frag %i/%i: %i\n",
+			   i + 1, h->nr_frags, ret);
+		if (ret < 0)
+			goto out;
+		h->frg_len -= ret;
+	}
+
+	if (h->frg_len != 0) {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret, "length %u remaining after reading frags\n",
+			 h->frg_len);
+		goto out;
+	}
+
+	sock_restore_header_info(ctx, skb, h);
+ out:
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0) {
+		kfree_skb(skb);
+		skb = ERR_PTR(ret);
+	}
+
+	return skb;
+}
+
+static int __sock_write_skb_frag(struct ckpt_ctx *ctx, skb_frag_t *frag)
+{
+	struct ckpt_hdr_socket_buffer_frag *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_FRAG);
+	if (!h)
+		return -ENOMEM;
+
+	h->size = frag->size;
+	h->offset = frag->page_offset;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	ret = checkpoint_dump_page(ctx, frag->page);
+	ckpt_debug("writing frag page: %i\n", ret);
+	return ret;
+}
+
+static int __sock_write_skb(struct ckpt_ctx *ctx,
+			    struct sk_buff *skb,
+			    int dst_objref)
+{
+	struct ckpt_hdr_socket_buffer *h;
+	int ret = 0;
+	int i;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
+	if (!h)
+		return -ENOMEM;
+
+	if (dst_objref > 0) {
+		BUG_ON(!skb->sk);
+		ret = checkpoint_obj(ctx, skb->sk, CKPT_OBJ_SOCK);
+		if (ret < 0)
+			goto out;
+		h->sk_objref = ret;
+		h->pr_objref = dst_objref;
+	}
+
+	sock_record_header_info(skb, h);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj_type(ctx, skb->head, h->lin_len, CKPT_HDR_BUFFER);
+	ckpt_debug("writing skb linear region %u: %i\n", h->lin_len, ret);
+	if (ret < 0)
+		goto out;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		ret = __sock_write_skb_frag(ctx, frag);
+		ckpt_debug("writing buffer fragment %i/%i (%i)\n",
+			   i + 1, h->nr_frags, ret);
+		if (ret < 0)
+			goto out;
+		h->frg_len -= frag->size;
+	}
+
+	WARN_ON(h->frg_len != 0);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int __sock_write_buffers(struct ckpt_ctx *ctx,
+				struct sk_buff_head *queue,
+				uint16_t family,
+				int dst_objref)
+{
+	struct sk_buff *skb;
+
+	skb_queue_walk(queue, skb) {
+		int ret = 0;
+
+		if (UNIXCB(skb).fp) {
+			ckpt_err(ctx, -EBUSY, "%(T)af_unix: pass fd\n");
+			return -EBUSY;
+		}
+
+		/* The other ancillary messages UNIX are always
+		 * present unlike descriptors.  Even though we can't
+		 * detect them and fail the checkpoint, we're not at
+		 * risk because we don't restore the control
+		 * information in the UNIX code.
+		 */
+
+		ret = __sock_write_skb(ctx, skb, dst_objref);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int sock_write_buffers(struct ckpt_ctx *ctx,
+			      struct sk_buff_head *queue,
+			      uint16_t family,
+			      int dst_objref)
+{
+	struct ckpt_hdr_socket_queue *h;
+	struct sk_buff_head tmpq;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
+	if (!h)
+		return -ENOMEM;
+
+	skb_queue_head_init(&tmpq);
+
+	ret = sock_copy_buffers(queue, &tmpq, &h->total_bytes);
+	if (ret < 0)
+		goto out;
+
+	h->skb_count = ret;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (!ret)
+		ret = __sock_write_buffers(ctx, &tmpq, family, dst_objref);
+
+ out:
+	ckpt_hdr_put(ctx, h);
+	__skb_queue_purge(&tmpq);
+
+	return ret;
+}
+
+int sock_deferred_write_buffers(void *data)
+{
+	struct dq_buffers *dq = (struct dq_buffers *)data;
+	struct ckpt_ctx *ctx = dq->ctx;
+	int ret;
+	int dst_objref;
+
+	dst_objref = ckpt_obj_lookup(ctx, dq->sk, CKPT_OBJ_SOCK);
+	if (dst_objref < 0) {
+		ckpt_err(ctx, dst_objref, "%(T)socket: owner gone?\n");
+		return dst_objref;
+	}
+
+	ret = sock_write_buffers(ctx, &dq->sk->sk_receive_queue,
+				 dq->sk->sk_family, dst_objref);
+	ckpt_debug("write recv buffers: %i\n", ret);
+	if (ret < 0)
+		return ret;
+
+	ret = sock_write_buffers(ctx, &dq->sk->sk_write_queue,
+				 dq->sk->sk_family, dst_objref);
+	ckpt_debug("write send buffers: %i\n", ret);
+
+	return ret;
+}
+
+int sock_defer_write_buffers(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct dq_buffers dq;
+
+	dq.ctx = ctx;
+	dq.sk = sk;
+
+	/* NB: This is safe to do inside deferqueue_run() since it uses
+	 * list_for_each_safe()
+	 */
+	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
+			      sock_deferred_write_buffers, NULL);
+}
+
+int ckpt_sock_getnames(struct ckpt_ctx *ctx, struct socket *sock,
+		       struct sockaddr *loc, unsigned *loc_len,
+		       struct sockaddr *rem, unsigned *rem_len)
+{
+	int ret;
+
+	ret = sock_getname(sock, loc, loc_len);
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)%(P)socket: getname local\n", sock);
+		return -EINVAL;
+	}
+
+	ret = sock_getpeer(sock, rem, rem_len);
+	if (ret) {
+		if ((sock->sk->sk_type != SOCK_DGRAM) &&
+		    (sock->sk->sk_state == TCP_ESTABLISHED)) {
+			ckpt_err(ctx, ret, "%(T)%(P)socket: getname peer\n",
+				       sock);
+			return -EINVAL;
+		}
+		*rem_len = 0;
+	}
+
+	return 0;
+}
+
+static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
+{
+	uint8_t userlocks_mask =
+		SOCK_SNDBUF_LOCK | SOCK_RCVBUF_LOCK |
+		SOCK_BINDADDR_LOCK | SOCK_BINDPORT_LOCK;
+
+	if (h->sock.shutdown & ~SHUTDOWN_MASK)
+		return -EINVAL;
+	if (h->sock.userlocks & ~userlocks_mask)
+		return -EINVAL;
+	if (!ckpt_validate_errno(h->sock.err))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int sock_cptrst_opt(int op, struct socket *sock,
+			   int optname, char *opt, int len)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+
+	if (op == CKPT_CPT)
+		ret = sock_getsockopt(sock, SOL_SOCKET, optname, opt, &len);
+	else
+		ret = sock_setsockopt(sock, SOL_SOCKET, optname, opt, len);
+
+	set_fs(fs);
+
+	return ret;
+}
+
+#define CKPT_COPY_SOPT(op, sk, name, opt) \
+	sock_cptrst_opt(op, sk->sk_socket, name, (char *)opt, sizeof(*opt))
+
+static int sock_cptrst_bufopts(int op, struct sock *sk,
+			       struct ckpt_hdr_socket *h)
+{
+	if (CKPT_COPY_SOPT(op, sk, SO_RCVBUF, &h->sock.rcvbuf))
+		if ((op == CKPT_RST) &&
+		    CKPT_COPY_SOPT(op, sk, SO_RCVBUFFORCE, &h->sock.rcvbuf)) {
+			ckpt_debug("Failed to set SO_RCVBUF");
+			return -EINVAL;
+		}
+
+	if (CKPT_COPY_SOPT(op, sk, SO_SNDBUF, &h->sock.sndbuf))
+		if ((op == CKPT_RST) &&
+		    CKPT_COPY_SOPT(op, sk, SO_SNDBUFFORCE, &h->sock.sndbuf)) {
+			ckpt_debug("Failed to set SO_SNDBUF");
+			return -EINVAL;
+		}
+
+	/* It's silly that we have to fight ourselves here, but
+	 * sock_setsockopt() doubles the initial value, so divide here
+	 * to store the user's value and avoid doubling on restart
+	 */
+	if ((op == CKPT_CPT) && (h->sock.rcvbuf != SOCK_MIN_RCVBUF))
+		h->sock.rcvbuf >>= 1;
+
+	if ((op == CKPT_CPT) && (h->sock.sndbuf != SOCK_MIN_SNDBUF))
+		h->sock.sndbuf >>= 1;
+
+	return 0;
+}
+
+struct sock_flag_mapping {
+	int opt;
+	int flag;
+};
+
+struct sock_flag_mapping sk_flag_map[] = {
+	{SO_OOBINLINE, SOCK_URGINLINE},
+	{SO_KEEPALIVE, SOCK_KEEPOPEN},
+	{SO_BROADCAST, SOCK_BROADCAST},
+	{SO_TIMESTAMP, SOCK_RCVTSTAMP},
+	{SO_TIMESTAMPNS, SOCK_RCVTSTAMPNS},
+	{SO_DEBUG, SOCK_DBG},
+	{SO_DONTROUTE, SOCK_LOCALROUTE},
+};
+
+struct sock_flag_mapping sock_flag_map[] = {
+	{SO_PASSCRED, SOCK_PASSCRED},
+};
+
+static int sock_restore_flag(struct socket *sock,
+			     unsigned long *flags,
+			     int flag,
+			     int option)
+{
+	int v = 1;
+	int ret = 0;
+
+	if (test_and_clear_bit(flag, flags))
+		ret = sock_setsockopt(sock, SOL_SOCKET, option,
+				      (char *)&v, sizeof(v));
+
+	return ret;
+}
+
+
+static int sock_restore_flags(struct socket *sock, struct ckpt_hdr_socket *h)
+{
+	unsigned long sk_flags = h->sock.flags;
+	unsigned long sock_flags = h->socket.flags;
+	int ret;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(sk_flag_map); i++) {
+		int opt = sk_flag_map[i].opt;
+		int flag = sk_flag_map[i].flag;
+		ret = sock_restore_flag(sock, &sk_flags, flag, opt);
+		if (ret) {
+			ckpt_debug("Failed to set skopt %i: %i\n", opt, ret);
+			return ret;
+		}
+	}
+
+	for (i = 0; i < ARRAY_SIZE(sock_flag_map); i++) {
+		int opt = sock_flag_map[i].opt;
+		int flag = sock_flag_map[i].flag;
+		ret = sock_restore_flag(sock, &sock_flags, flag, opt);
+		if (ret) {
+			ckpt_debug("Failed to set sockopt %i: %i\n", opt, ret);
+			return ret;
+		}
+	}
+
+	/* TODO: Handle SOCK_TIMESTAMPING_* flags */
+	if (test_bit(SOCK_TIMESTAMPING_TX_HARDWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_TX_SOFTWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_RX_HARDWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_RX_SOFTWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_SOFTWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_RAW_HARDWARE, &sk_flags) ||
+	    test_bit(SOCK_TIMESTAMPING_SYS_HARDWARE, &sk_flags)) {
+		ckpt_debug("SOF_TIMESTAMPING_* flags are not supported\n");
+		return -ENOSYS;
+	}
+
+	if (test_and_clear_bit(SOCK_DEAD, &sk_flags))
+		sock_set_flag(sock->sk, SOCK_DEAD);
+
+
+	/* Anything that is still set in the flags that isn't part of
+	 * our protocol's default set, indicates an error
+	 */
+	if (sk_flags & ~sock->sk->sk_flags) {
+		ckpt_debug("Unhandled sock flags: %lx\n", sk_flags);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int sock_copy_timeval(int op, struct sock *sk,
+			     int sockopt, __s64 *saved)
+{
+	struct timeval tv;
+
+	if (op == CKPT_CPT) {
+		if (CKPT_COPY_SOPT(op, sk, sockopt, &tv))
+			return -EINVAL;
+		*saved = timeval_to_ns(&tv);
+	} else {
+		tv = ns_to_timeval(*saved);
+		if (CKPT_COPY_SOPT(op, sk, sockopt, &tv))
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
+		       struct ckpt_hdr_socket *h, int op)
+{
+	if (sk->sk_socket)
+		CKPT_COPY(op, h->socket.state, sk->sk_socket->state);
+
+	CKPT_COPY(op, h->sock_common.bound_dev_if, sk->sk_bound_dev_if);
+	CKPT_COPY(op, h->sock_common.family, sk->sk_family);
+
+	CKPT_COPY(op, h->sock.shutdown, sk->sk_shutdown);
+	CKPT_COPY(op, h->sock.userlocks, sk->sk_userlocks);
+	CKPT_COPY(op, h->sock.no_check, sk->sk_no_check);
+	CKPT_COPY(op, h->sock.protocol, sk->sk_protocol);
+	CKPT_COPY(op, h->sock.err, sk->sk_err);
+	CKPT_COPY(op, h->sock.err_soft, sk->sk_err_soft);
+	CKPT_COPY(op, h->sock.type, sk->sk_type);
+	CKPT_COPY(op, h->sock.state, sk->sk_state);
+	CKPT_COPY(op, h->sock.backlog, sk->sk_max_ack_backlog);
+
+	if (sock_cptrst_bufopts(op, sk, h))
+		return -EINVAL;
+
+	if (CKPT_COPY_SOPT(op, sk, SO_REUSEADDR, &h->sock_common.reuse)) {
+		ckpt_err(ctx, -EINVAL, "Failed to set SO_REUSEADDR");
+
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sk, SO_PRIORITY, &h->sock.priority)) {
+		ckpt_err(ctx, -EINVAL, "Failed to set SO_PRIORITY");
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sk, SO_RCVLOWAT, &h->sock.rcvlowat)) {
+		ckpt_err(ctx, -EINVAL, "Failed to set SO_RCVLOWAT");
+		return -EINVAL;
+	}
+
+	if (CKPT_COPY_SOPT(op, sk, SO_LINGER, &h->sock.linger)) {
+		ckpt_err(ctx, -EINVAL, "Failed to set SO_LINGER");
+		return -EINVAL;
+	}
+
+	if (sock_copy_timeval(op, sk, SO_SNDTIMEO, &h->sock.sndtimeo)) {
+		ckpt_err(ctx, -EINVAL, "Failed to set SO_SNDTIMEO");
+		return -EINVAL;
+	}
+
+	if (sock_copy_timeval(op, sk, SO_RCVTIMEO, &h->sock.rcvtimeo)) {
+		ckpt_err(ctx, -EINVAL, "Failed to set SO_RCVTIMEO");
+		return -EINVAL;
+	}
+
+	if (op == CKPT_CPT) {
+		h->sock.flags = sk->sk_flags;
+		h->socket.flags = sk->sk_socket->flags;
+	} else {
+		int ret;
+		mm_segment_t old_fs;
+
+		old_fs = get_fs();
+		set_fs(KERNEL_DS);
+		ret = sock_restore_flags(sk->sk_socket, h);
+		set_fs(old_fs);
+		if (ret)
+			return ret;
+	}
+
+	if ((h->socket.state == SS_CONNECTED) &&
+	    (h->sock.state != TCP_ESTABLISHED)) {
+		ckpt_err(ctx, -EINVAL, "sock/et in inconsistent state: %i/%i",
+			 h->socket.state, h->sock.state);
+		return -EINVAL;
+	} else if ((h->sock.state < TCP_ESTABLISHED) ||
+		   (h->sock.state >= TCP_MAX_STATES)) {
+		ckpt_err(ctx, -EINVAL,
+			 "sock in invalid state: %i", h->sock.state);
+		return -EINVAL;
+	} else if (h->socket.state > SS_DISCONNECTING) {
+		ckpt_err(ctx, -EINVAL, "socket in invalid state: %i",
+			 h->socket.state);
+		return -EINVAL;
+	}
+
+	if (op == CKPT_RST)
+		return sock_cptrst_verify(h);
+	else
+		return 0;
+}
+
+static int __do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct socket *sock = sk->sk_socket;
+	struct ckpt_hdr_socket *h;
+	int ret;
+
+	if (!sock->ops->checkpoint) {
+		ckpt_err(ctx, -ENOSYS, "%(T)%(V)%(P)socket: proto_ops\n",
+			       sock->ops, sock);
+		return -ENOSYS;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
+	if (!h)
+		return -ENOMEM;
+
+	/* part I: common to all sockets */
+	ret = sock_cptrst(ctx, sk, h, CKPT_CPT);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	/* part II: per socket type state */
+	ret = sock->ops->checkpoint(ctx, sock);
+	if (ret < 0)
+		goto out;
+
+	/* part III: socket buffers */
+	if ((sk->sk_state != TCP_LISTEN) && (!sock_flag(sk, SOCK_DEAD)))
+		ret = sock_defer_write_buffers(ctx, sk);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct socket *sock;
+	int ret;
+
+	if (sk->sk_socket)
+		return __do_sock_checkpoint(ctx, sk);
+
+	/* Temporarily adopt this orphan socket */
+	ret = sock_create(sk->sk_family, sk->sk_type, 0, &sock);
+	if (ret < 0)
+		return ret;
+	sock_graft(sk, sock);
+
+	ret = __do_sock_checkpoint(ctx, sk);
+
+	sock_orphan(sk);
+	sock->sk = NULL;
+	sock_release(sock);
+
+	return ret;
+}
+
+int checkpoint_sock(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_sock_checkpoint(ctx, (struct sock *)ptr);
+}
+
+int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_socket *h;
+	struct socket *sock = file->private_data;
+	struct sock *sk = sock->sk;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	h->common.f_type = CKPT_FILE_SOCKET;
+
+	h->sock_objref = checkpoint_obj(ctx, sk, CKPT_OBJ_SOCK);
+	if (h->sock_objref < 0) {
+		ret = h->sock_objref;
+		goto out;
+	}
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int sock_collect_skbs(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+{
+	struct sk_buff_head tmpq;
+	struct sk_buff *skb;
+	int ret = 0;
+	int bytes;
+
+	skb_queue_head_init(&tmpq);
+
+	ret = sock_copy_buffers(queue, &tmpq, &bytes);
+	if (ret < 0)
+		return ret;
+
+	skb_queue_walk(&tmpq, skb) {
+		/* Socket buffers do not maintain a ref count on their
+		 * owning sock because they're counted in sock_wmem_alloc.
+		 * So, we only need to collect sockets from the queue that
+		 * won't be collected any other way (i.e. DEAD sockets that
+		 * are hanging around only because they're waiting for us
+		 * to process their skb.
+		 */
+
+		if (!ckpt_obj_lookup(ctx, skb->sk, CKPT_OBJ_SOCK) &&
+		    sock_flag(skb->sk, SOCK_DEAD)) {
+			ret = ckpt_obj_collect(ctx, skb->sk, CKPT_OBJ_SOCK);
+			if (ret < 0)
+				break;
+		}
+	}
+
+	__skb_queue_purge(&tmpq);
+
+	return ret;
+}
+
+int sock_file_collect(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct socket *sock = file->private_data;
+	struct sock *sk = sock->sk;
+	int ret;
+
+	ret = sock_collect_skbs(ctx, &sk->sk_write_queue);
+	if (ret < 0)
+		return ret;
+
+	ret = sock_collect_skbs(ctx, &sk->sk_receive_queue);
+	if (ret < 0)
+		return ret;
+
+	ret = ckpt_obj_collect(ctx, sk, CKPT_OBJ_SOCK);
+	if (ret < 0)
+		return ret;
+
+	if (sock->ops->collect)
+		ret = sock->ops->collect(ctx, sock);
+
+	return ret;
+}
+
+struct sock *do_sock_restore(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_socket *h;
+	struct socket *sock;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	/* silently clear flags, e.g. SOCK_NONBLOCK or SOCK_CLOEXEC */
+	h->sock.type &= SOCK_TYPE_MASK;
+
+	ret = sock_create(h->sock_common.family, h->sock.type,
+			  h->sock.protocol, &sock);
+	if (ret < 0)
+		goto err;
+
+	if (!sock->ops->restore) {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret, "proto_ops lacks restore %pS\n", sock->ops);
+		goto err;
+	}
+
+	/*
+	 * part II: per socket type state
+	 * (also takes care of part III: socket buffer)
+	 */
+	ret = sock->ops->restore(ctx, sock, h);
+	if (ret < 0)
+		goto err;
+
+	/* part I: common to all sockets */
+	ret = sock_cptrst(ctx, sock->sk, h, CKPT_RST);
+	if (ret < 0)
+		goto err;
+
+	ckpt_hdr_put(ctx, h);
+	return sock->sk;
+ err:
+	ckpt_hdr_put(ctx, h);
+	sock_release(sock);
+	return ERR_PTR(ret);
+}
+
+void *restore_sock(struct ckpt_ctx *ctx)
+{
+	return do_sock_restore(ctx);
+}
+
+struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_socket *h = (struct ckpt_hdr_file_socket *)ptr;
+	struct sock *sk;
+	struct file *file;
+	int fd, ret;
+
+	if (ptr->h.type != CKPT_HDR_FILE || ptr->f_type != CKPT_FILE_SOCKET)
+		return ERR_PTR(-EINVAL);
+
+	sk = ckpt_obj_fetch(ctx, h->sock_objref, CKPT_OBJ_SOCK);
+	if (IS_ERR(sk))
+		return ERR_PTR(PTR_ERR(sk));
+
+	fd = sock_alloc_file(sk->sk_socket, &file, O_RDWR);
+	if (fd < 0)
+		return ERR_PTR(fd);
+	put_unused_fd(fd); /* We'll let the checkpoint code re-allocate this */
+
+	/* Since objhash assumes the initial reference for a socket,
+	 * we bump it here for this descriptor, unlike other places in
+	 * the socket code which assume the descriptor is the owner.
+	 */
+	sock_hold(sk);
+
+	ret = restore_file_common(ctx, file, ptr);
+	if (ret < 0) {
+		fput(file);
+		return ERR_PTR(ret);
+	}
+
+	return file;
+}
diff --git a/net/socket.c b/net/socket.c
index 4d4fdc2..3253c04 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -147,6 +147,10 @@ static const struct file_operations socket_file_ops = {
 	.sendpage =	sock_sendpage,
 	.splice_write = generic_splice_sendpage,
 	.splice_read =	sock_splice_read,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint =   sock_file_checkpoint,
+	.collect = sock_file_collect,
+#endif
 };
 
 /*
@@ -342,7 +346,7 @@ static const struct dentry_operations sockfs_dentry_operations = {
  *	but we take care of internal coherence yet.
  */
 
-static int sock_alloc_file(struct socket *sock, struct file **f, int flags)
+int sock_alloc_file(struct socket *sock, struct file **f, int flags)
 {
 	struct qstr name = { .name = "" };
 	struct path path;
diff --git a/net/unix/Makefile b/net/unix/Makefile
index b852a2b..fbff1e6 100644
--- a/net/unix/Makefile
+++ b/net/unix/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_UNIX)	+= unix.o
 
 unix-y			:= af_unix.o garbage.o
 unix-$(CONFIG_SYSCTL)	+= sysctl_net_unix.o
+unix-$(CONFIG_CHECKPOINT) += checkpoint.o
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f255119..dacba62 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -523,6 +523,9 @@ static const struct proto_ops unix_stream_ops = {
 	.recvmsg =	unix_stream_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.checkpoint =	unix_checkpoint,
+	.restore =	unix_restore,
+	.collect =      unix_collect,
 };
 
 static const struct proto_ops unix_dgram_ops = {
@@ -544,6 +547,9 @@ static const struct proto_ops unix_dgram_ops = {
 	.recvmsg =	unix_dgram_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.checkpoint =	unix_checkpoint,
+	.restore =	unix_restore,
+	.collect =      unix_collect,
 };
 
 static const struct proto_ops unix_seqpacket_ops = {
@@ -565,6 +571,9 @@ static const struct proto_ops unix_seqpacket_ops = {
 	.recvmsg =	unix_dgram_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.checkpoint =	unix_checkpoint,
+	.restore =	unix_restore,
+	.collect =      unix_collect,
 };
 
 static struct proto unix_proto = {
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
new file mode 100644
index 0000000..90415b0
--- /dev/null
+++ b/net/unix/checkpoint.c
@@ -0,0 +1,647 @@
+#include <linux/namei.h>
+#include <linux/file.h>
+#include <linux/fs_struct.h>
+#include <linux/deferqueue.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/user.h>
+#include <net/af_unix.h>
+#include <net/tcp_states.h>
+
+struct dq_join {
+	struct ckpt_ctx *ctx;
+	int src_objref;
+	int dst_objref;
+};
+
+struct dq_buffers {
+	struct ckpt_ctx *ctx;
+	int sk_objref; /* objref of the socket these buffers belong to */
+};
+
+#define UNIX_ADDR_EMPTY(a) (a <= sizeof(short))
+
+static inline int unix_need_cwd(struct sockaddr_un *addr, unsigned long len)
+{
+	return (!UNIX_ADDR_EMPTY(len)) &&
+		addr->sun_path[0] &&
+		(addr->sun_path[0] != '/');
+}
+
+static int unix_join(struct sock *src, struct sock *dst)
+{
+	if (unix_sk(src)->peer != NULL)
+		return 0; /* We're second */
+
+	sock_hold(dst);
+	unix_sk(src)->peer = dst;
+
+	return 0;
+
+}
+
+static int unix_deferred_join(void *data)
+{
+	struct dq_join *dq = (struct dq_join *)data;
+	struct ckpt_ctx *ctx = dq->ctx;
+	struct sock *src;
+	struct sock *dst;
+
+	src = ckpt_obj_fetch(ctx, dq->src_objref, CKPT_OBJ_SOCK);
+	if (!src) {
+		ckpt_err(ctx, -EINVAL, "%(O)Bad src sock\n", dq->src_objref);
+		return -EINVAL;
+	}
+
+	dst = ckpt_obj_fetch(ctx, dq->dst_objref, CKPT_OBJ_SOCK);
+	if (!dst) {
+		ckpt_err(ctx, -EINVAL, "%(O)Bad dst sock\n", dq->dst_objref);
+		return -EINVAL;
+	}
+
+	return unix_join(src, dst);
+}
+
+static int unix_defer_join(struct ckpt_ctx *ctx,
+			   int src_objref,
+			   int dst_objref)
+{
+	struct dq_join dq;
+
+	dq.ctx = ctx;
+	dq.src_objref = src_objref;
+	dq.dst_objref = dst_objref;
+
+	/* NB: This is safe to do inside deferqueue_run() since it uses
+	 * list_for_each_safe()
+	 */
+	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
+			      unix_deferred_join, NULL);
+}
+
+static int unix_write_cwd(struct ckpt_ctx *ctx,
+			  struct sock *sk, const char *sockpath)
+{
+	struct path path;
+	char *buf;
+	char *fqpath;
+	int offset;
+	int len = PATH_MAX;
+	int ret = -ENOENT;
+
+	buf = kmalloc(len, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	path.dentry = unix_sk(sk)->dentry;
+	path.mnt = unix_sk(sk)->mnt;
+
+	fqpath = ckpt_fill_fname(&path, &ctx->root_fs_path, buf, &len);
+	if (IS_ERR(fqpath)) {
+		ret = PTR_ERR(fqpath);
+		goto out;
+	}
+
+	offset = strlen(fqpath) - strlen(sockpath);
+	if (offset <= 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	fqpath[offset] = '\0';
+
+	ckpt_debug("writing socket directory: %s\n", fqpath);
+	ret = ckpt_write_string(ctx, fqpath, offset + 1);
+ out:
+	kfree(buf);
+	return ret;
+}
+
+int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
+{
+	struct unix_sock *sk = unix_sk(sock->sk);
+	struct ckpt_hdr_socket_unix *un;
+	int new;
+	int ret = -ENOMEM;
+
+	if ((sock->sk->sk_state == TCP_LISTEN) &&
+	    !skb_queue_empty(&sock->sk->sk_receive_queue)) {
+		ckpt_err(ctx, -EBUSY,
+			 "%(T)%(E)%(P)af_unix: listen with pending peers\n",
+			 sock);
+		return -EBUSY;
+	}
+
+	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
+	if (!un)
+		return -EINVAL;
+
+	ret = ckpt_sock_getnames(ctx, sock,
+				 (struct sockaddr *)&un->laddr, &un->laddr_len,
+				 (struct sockaddr *)&un->raddr, &un->raddr_len);
+	if (ret)
+		goto out;
+
+	if (sk->dentry && (sk->dentry->d_inode->i_nlink > 0))
+		un->flags |= CKPT_UNIX_LINKED;
+
+	un->this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
+	if (un->this < 0)
+		goto out;
+
+	if (sk->peer)
+		un->peer = checkpoint_obj(ctx, sk->peer, CKPT_OBJ_SOCK);
+	else
+		un->peer = 0;
+
+	if (un->peer < 0) {
+		ret = un->peer;
+		goto out;
+	}
+
+	un->peercred_uid = sock->sk->sk_peercred.uid;
+	un->peercred_gid = sock->sk->sk_peercred.gid;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
+	if (ret < 0)
+		goto out;
+
+	if (unix_need_cwd(&un->laddr, un->laddr_len))
+		ret = unix_write_cwd(ctx, sock->sk, un->laddr.sun_path);
+ out:
+	ckpt_hdr_put(ctx, un);
+
+	return ret;
+}
+
+int unix_collect(struct ckpt_ctx *ctx, struct socket *sock)
+{
+	struct unix_sock *sk = unix_sk(sock->sk);
+	int ret;
+
+	ret = ckpt_obj_collect(ctx, sock->sk, CKPT_OBJ_SOCK);
+	if (ret < 0)
+		return ret;
+
+	if (sk->peer)
+		ret = ckpt_obj_collect(ctx, sk->peer, CKPT_OBJ_SOCK);
+
+	return 0;
+}
+
+static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
+				    struct sockaddr *addr,
+				    unsigned int addrlen)
+{
+	struct ckpt_hdr_socket_buffer *h;
+	struct sock *sk;
+	struct msghdr msg;
+	struct kvec kvec;
+	uint8_t sock_shutdown;
+	uint8_t peer_shutdown = 0;
+	void *buf = NULL;
+	int sndbuf;
+	int ret;
+
+	memset(&msg, 0, sizeof(msg));
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->lin_len > SKB_MAX_ALLOC) {
+		ckpt_err(ctx, ret, "socket buffer too big (%u > %lu)\n",
+			 h->lin_len, SKB_MAX_ALLOC);
+		goto out;
+	} else if (h->nr_frags != 0) {
+		ckpt_err(ctx, ret, "unix socket claims to have fragments\n");
+		goto out;
+	}
+
+	buf = kmalloc(h->lin_len, GFP_KERNEL);
+	if (!buf) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	kvec.iov_len = h->lin_len;
+	kvec.iov_base = buf;
+	ret = _ckpt_read_obj_type(ctx, kvec.iov_base,
+				  h->lin_len, CKPT_HDR_BUFFER);
+	ckpt_debug("read unix socket buffer %u: %i\n", h->lin_len, ret);
+	if (ret < h->lin_len) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	sk = ckpt_obj_fetch(ctx, h->sk_objref, CKPT_OBJ_SOCK);
+	if (IS_ERR(sk)) {
+		ret = PTR_ERR(sk);
+		goto out;
+	}
+
+	/* If we don't have a destination or a peer and we know the
+	 * destination of this skb, then we must need to join with our
+	 * peer
+	 */
+	if (!addrlen && !unix_sk(sk)->peer) {
+		struct sock *pr;
+		pr = ckpt_obj_fetch(ctx, h->pr_objref, CKPT_OBJ_SOCK);
+		if (IS_ERR(pr)) {
+			ret = PTR_ERR(pr);
+			ckpt_err(ctx, ret, "Failed to fetch peer\n");
+			goto out;
+		}
+		ret = unix_join(sk, pr);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "Failed to join sockets\n");
+			goto out;
+		}
+	}
+
+	msg.msg_name = addr;
+	msg.msg_namelen = addrlen;
+
+	/* If peer is shutdown, unshutdown it for this process */
+	sock_shutdown = sk->sk_shutdown;
+	sk->sk_shutdown &= ~SHUTDOWN_MASK;
+
+	/* Unshutdown peer too, if necessary */
+	if (unix_sk(sk)->peer) {
+		peer_shutdown = unix_sk(sk)->peer->sk_shutdown;
+		unix_sk(sk)->peer->sk_shutdown &= ~SHUTDOWN_MASK;
+	}
+
+	/* Make sure there's room in the send buffer: Worst case, we
+	 * give them the benefit of the doubt and set the buffer limit
+	 * to the system default.  This should cover the case where
+	 * the user set the limit low after loading up the buffer.
+	 *
+	 * However, if there isn't room in the buffer and the system
+	 * default won't accommodate them either, then increase the
+	 * limit as needed, only if they have CAP_NET_ADMIN.
+	 */
+	sndbuf = sk->sk_sndbuf;
+	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < h->lin_len) &&
+	    (h->lin_len > sysctl_wmem_max) &&
+	    capable(CAP_NET_ADMIN))
+		sk->sk_sndbuf += h->lin_len;
+	else
+		sk->sk_sndbuf = sysctl_wmem_max;
+
+	ret = kernel_sendmsg(sk->sk_socket, &msg, &kvec, 1, h->lin_len);
+	ckpt_debug("kernel_sendmsg(%i,%u): %i\n",
+		   h->sk_objref, h->lin_len, ret);
+	if ((ret > 0) && (ret != h->lin_len))
+		ret = -ENOMEM;
+
+	sk->sk_sndbuf = sndbuf;
+	sk->sk_shutdown = sock_shutdown;
+	if (peer_shutdown)
+		unix_sk(sk)->peer->sk_shutdown = peer_shutdown;
+ out:
+	ckpt_hdr_put(ctx, h);
+	kfree(buf);
+	return ret;
+}
+
+static int unix_read_buffers(struct ckpt_ctx *ctx,
+			     struct sockaddr *addr,
+			     unsigned int addrlen)
+{
+	struct ckpt_hdr_socket_queue *h;
+	int ret = 0;
+	int i;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	for (i = 0; i < h->skb_count; i++) {
+		ret = sock_read_buffer_sendmsg(ctx, addr, addrlen);
+		ckpt_debug("read_buffer_sendmsg(%i): %i\n", i, ret);
+		if (ret < 0)
+			goto out;
+
+		if (ret > h->total_bytes) {
+			ret = -EINVAL;
+			ckpt_err(ctx, ret, "Buffers exceeded claim");
+			goto out;
+		}
+
+		h->total_bytes -= ret;
+	}
+
+	ret = h->skb_count;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int unix_deferred_restore_buffers(void *data)
+{
+	struct dq_buffers *dq = (struct dq_buffers *)data;
+	struct ckpt_ctx *ctx = dq->ctx;
+	struct sock *sk;
+	struct sockaddr *addr = NULL;
+	unsigned int addrlen = 0;
+	int ret;
+
+	sk = ckpt_obj_fetch(ctx, dq->sk_objref, CKPT_OBJ_SOCK);
+	if (!sk) {
+		ckpt_err(ctx, -EINVAL, "%(O) missing sock\n", dq->sk_objref);
+		return -EINVAL;
+	}
+
+	if ((sk->sk_type == SOCK_DGRAM) && (unix_sk(sk)->addr != NULL)) {
+		addr = (struct sockaddr *)&unix_sk(sk)->addr->name;
+		addrlen = unix_sk(sk)->addr->len;
+	}
+
+	ret = unix_read_buffers(ctx, addr, addrlen);
+	ckpt_debug("read recv buffers: %i\n", ret);
+	if (ret < 0)
+		return ret;
+
+	ret = unix_read_buffers(ctx, addr, addrlen);
+	ckpt_debug("read send buffers: %i\n", ret);
+	if (ret > 0)
+		ret = -EINVAL; /* No send buffers for UNIX sockets */
+
+	return ret;
+}
+
+static int unix_defer_restore_buffers(struct ckpt_ctx *ctx, int sk_objref)
+{
+	struct dq_buffers dq;
+
+	dq.ctx = ctx;
+	dq.sk_objref = sk_objref;
+
+	/* NB: This is safe to do inside deferqueue_run() since it uses
+	 * list_for_each_safe()
+	 */
+	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
+			      unix_deferred_restore_buffers, NULL);
+}
+
+static struct unix_address *unix_makeaddr(struct sockaddr_un *sun_addr,
+					  unsigned len)
+{
+	struct unix_address *addr;
+
+	if (len > sizeof(struct sockaddr_un))
+		return ERR_PTR(-EINVAL);
+
+	addr = kmalloc(sizeof(*addr) + len, GFP_KERNEL);
+	if (!addr)
+		return ERR_PTR(-ENOMEM);
+
+	memcpy(addr->name, sun_addr, len);
+	addr->len = len;
+	atomic_set(&addr->refcnt, 1);
+
+	return addr;
+}
+
+static int unix_restore_connected(struct ckpt_ctx *ctx,
+				  struct ckpt_hdr_socket *h,
+				  struct ckpt_hdr_socket_unix *un,
+				  struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct sockaddr *addr = NULL;
+	unsigned long flags = h->sock.flags;
+	unsigned int addrlen = 0;
+	int dead = test_bit(SOCK_DEAD, &flags);
+	int ret = 0;
+
+
+	if (un->peer == 0) {
+		/* These get propagated to the msghdr, so only set them
+		 * if we're not connected to a peer, else we'll get an error
+		 * when we sendmsg()
+		 */
+		addr = (struct sockaddr *)&un->laddr;
+		addrlen = un->laddr_len;
+	}
+
+	sk->sk_peercred.pid = task_tgid_vnr(current);
+
+	if (may_setuid(ctx->realcred->user->user_ns, un->peercred_uid) &&
+	    may_setgid(un->peercred_gid)) {
+		sk->sk_peercred.uid = un->peercred_uid;
+		sk->sk_peercred.gid = un->peercred_gid;
+	} else {
+		ckpt_err(ctx, -EPERM, "peercred %i:%i would require setuid",
+			 un->peercred_uid, un->peercred_gid);
+		return -EPERM;
+	}
+
+	if (!dead && (un->peer > 0)) {
+		ret = unix_defer_join(ctx, un->this, un->peer);
+		ckpt_debug("unix_defer_join: %i\n", ret);
+	}
+
+	if (!dead && !ret)
+		ret = unix_defer_restore_buffers(ctx, un->this);
+
+	return ret;
+}
+
+static int unix_unlink(const char *name)
+{
+	struct path spath;
+	struct path ppath;
+	int ret;
+
+	ret = kern_path(name, 0, &spath);
+	if (ret)
+		return ret;
+
+	ret = kern_path(name, LOOKUP_PARENT, &ppath);
+	if (ret)
+		goto out_s;
+
+	if (!spath.dentry) {
+		ckpt_debug("No dentry found for %s\n", name);
+		ret = -ENOENT;
+		goto out_p;
+	}
+
+	if (!ppath.dentry || !ppath.dentry->d_inode) {
+		ckpt_debug("No inode for parent of %s\n", name);
+		ret = -ENOENT;
+		goto out_p;
+	}
+
+	ret = vfs_unlink(ppath.dentry->d_inode, spath.dentry);
+ out_p:
+	path_put(&ppath);
+ out_s:
+	path_put(&spath);
+
+	return ret;
+}
+
+/* Call bind() for socket, optionally changing (temporarily) to @path first
+ * if non-NULL
+ */
+static int unix_chdir_and_bind(struct socket *sock,
+			       const char *path,
+			       struct sockaddr *addr,
+			       unsigned long addrlen)
+{
+	struct sockaddr_un *un = (struct sockaddr_un *)addr;
+	struct path cur = { .mnt = NULL, .dentry = NULL };
+	struct path dir = { .mnt = NULL, .dentry = NULL };
+	int ret;
+
+	if (path) {
+		ckpt_debug("switching to cwd %s for unix bind", path);
+
+		ret = kern_path(path, 0, &dir);
+		if (ret)
+			return ret;
+
+		ret = inode_permission(dir.dentry->d_inode,
+				       MAY_EXEC | MAY_ACCESS);
+		if (ret)
+			goto out;
+
+		write_lock(&current->fs->lock);
+		cur = current->fs->pwd;
+		current->fs->pwd = dir;
+		write_unlock(&current->fs->lock);
+	}
+
+	ret = unix_unlink(un->sun_path);
+	ckpt_debug("unlink(%s): %i\n", un->sun_path, ret);
+	if ((ret == 0) || (ret == -ENOENT))
+		ret = sock_bind(sock, addr, addrlen);
+
+	if (path) {
+		write_lock(&current->fs->lock);
+		current->fs->pwd = cur;
+		write_unlock(&current->fs->lock);
+	}
+ out:
+	if (path)
+		path_put(&dir);
+
+	return ret;
+}
+
+static int unix_fakebind(struct socket *sock,
+			 struct sockaddr_un *addr, unsigned long len)
+{
+	struct unix_address *uaddr;
+
+	uaddr = unix_makeaddr(addr, len);
+	if (IS_ERR(uaddr))
+		return PTR_ERR(uaddr);
+
+	unix_sk(sock->sk)->addr = uaddr;
+
+	return 0;
+}
+
+static int unix_restore_bind(struct ckpt_hdr_socket *h,
+			     struct ckpt_hdr_socket_unix *un,
+			     struct socket *sock,
+			     const char *path)
+{
+	struct sockaddr *addr = (struct sockaddr *)&un->laddr;
+	unsigned long len = un->laddr_len;
+	unsigned long flags = h->sock.flags;
+	int dead = test_bit(SOCK_DEAD, &flags);
+
+	if (dead)
+		return unix_fakebind(sock, &un->laddr, len);
+	else if (!un->laddr.sun_path[0])
+		return sock_bind(sock, addr, len);
+	else if (!(un->flags & CKPT_UNIX_LINKED))
+		return unix_fakebind(sock, &un->laddr, len);
+	else
+		return unix_chdir_and_bind(sock, path, addr, len);
+}
+
+/* Some easy pre-flight checks before we get underway */
+static int unix_precheck(struct socket *sock, struct ckpt_hdr_socket *h)
+{
+	struct net *net = sock_net(sock->sk);
+	unsigned long sk_flags = h->sock.flags;
+
+	if ((h->socket.state == SS_CONNECTING) ||
+	    (h->socket.state == SS_DISCONNECTING) ||
+	    (h->socket.state == SS_FREE)) {
+		ckpt_debug("AF_UNIX socket can't be SS_(DIS)CONNECTING");
+		return -EINVAL;
+	}
+
+	/* AF_UNIX overloads the backlog setting to define the maximum
+	 * queue length for DGRAM sockets.  Make sure we don't let the
+	 * caller exceed that value on restart.
+	 */
+	if ((h->sock.type == SOCK_DGRAM) &&
+	    (h->sock.backlog > net->unx.sysctl_max_dgram_qlen)) {
+		ckpt_debug("DGRAM backlog of %i exceeds system max of %i\n",
+			   h->sock.backlog, net->unx.sysctl_max_dgram_qlen);
+		return -EINVAL;
+	}
+
+	if (test_bit(SOCK_USE_WRITE_QUEUE, &sk_flags)) {
+		ckpt_debug("AF_UNIX socket has SOCK_USE_WRITE_QUEUE set");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
+		 struct ckpt_hdr_socket *h)
+
+{
+	struct ckpt_hdr_socket_unix *un;
+	int ret = -EINVAL;
+	char *cwd = NULL;
+
+	ret = unix_precheck(sock, h);
+	if (ret)
+		return ret;
+
+	un = ckpt_read_obj_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
+	if (IS_ERR(un))
+		return PTR_ERR(un);
+
+	if (un->peer < 0)
+		goto out;
+
+	if (unix_need_cwd(&un->laddr, un->laddr_len)) {
+		cwd = ckpt_read_string(ctx, PATH_MAX);
+		if (IS_ERR(cwd)) {
+			ret = PTR_ERR(cwd);
+			goto out;
+		}
+	}
+
+	if ((h->sock.state != TCP_ESTABLISHED) &&
+	    !UNIX_ADDR_EMPTY(un->laddr_len)) {
+		ret = unix_restore_bind(h, un, sock, cwd);
+		if (ret)
+			goto out;
+	}
+
+	if ((h->sock.state == TCP_ESTABLISHED) || (h->sock.state == TCP_CLOSE))
+		ret = unix_restore_connected(ctx, h, un, sock);
+	else if (h->sock.state == TCP_LISTEN)
+		ret = sock->ops->listen(sock, h->sock.backlog);
+	else
+		ckpt_err(ctx, ret, "bad af_unix state %i\n", h->sock.state);
+
+ out:
+	ckpt_hdr_put(ctx, un);
+	kfree(cwd);
+	return ret;
+}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
