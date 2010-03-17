Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB4E620038
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:23:55 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 78/96] c/r: add support for connected INET sockets (v5)
Date: Wed, 17 Mar 2010 12:09:06 -0400
Message-Id: <1268842164-5590-79-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-78-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Dan Smith <danms@us.ibm.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Dan Smith <danms@us.ibm.com>

This patch adds basic support for C/R of open INET sockets.  I think that
all the important bits of the TCP and ICSK socket structures is saved,
but I think there is still some additional IPv6 stuff that needs to be
handled.

With this patch applied, the following script can be used to demonstrate
the functionality:

  https://lists.linux-foundation.org/pipermail/containers/2009-October/021239.html

It shows that this enables migration of a sendmail process with open
connections from one machine to another without dropping.

We probably need comments from the netdev people about the quality of
sanity checking we do on the values in the ckpt_hdr_socket_inet
structure on restart.

Note that this still doesn't address lingering sockets yet.

Changelog [v19-rc3]:
  - Rebase to kernel 2.6.33 (add 'inet_' prefix to some sk fields)
  - Relax tcp.window_clamp value in INET restore
Changelog [v19-rc2]:
  - Restore gso_type fields on sockets and buffers, so that they're
    properly handled on incoming path. Use the proper value from the
    socket (instead of storing that per-buffer) to avoid needing to
    detect (e.g.) the user restore a UDP buffer into a TCP socket.
Changes in v5:
 - Change ckpt_write_err() to ckpt_err()
Changes in v4:
 - Use the new socket buffer restore functions introduced in the
   previous patch
 - Move listen_sockets list under the restart items in ckpt_ctx
 - Rename RESTART_SOCK_LISTENONLY to RESTART_CONN_RESET
Changes in v3:
 - Prevent restart from allowing a bind on a <1024 port unless the
   user is granted that capability
 - Add some sanity checking in the inet_precheck() function to make sure
   the values read from the checkpoint image are within acceptable ranges
 - Check the result of sock_restore_header_info() and fail if needed
Changes in v2:
 - Restore saddr, rcv_saddr, daddr, sport, and dport from the sockaddr
   structure instead of saving them separately
 - Fix 'sock' naming in sock_cptrst()
 - Don't take the queue lock before skb_queue_tail() since it is
   done for us
 - Allow "listen only" restore behavior if RESTART_SOCK_LISTENONLY
   flag is specified on sys_restart()
 - Pull the implementation of the list of listening sockets back into
   this patch
 - Fix dangling printk
 - Add some comments around the parent/child restore logic

Cc: netdev@vger.kernel.org
Signed-off-by: Dan Smith <danms@us.ibm.com>
Acked-by: Oren Laadan <orenl@librato.com>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/sys.c                 |    4 +
 include/linux/checkpoint.h       |    7 +-
 include/linux/checkpoint_hdr.h   |   95 ++++++++++
 include/linux/checkpoint_types.h |    1 +
 net/checkpoint.c                 |   19 +-
 net/ipv4/checkpoint.c            |  373 +++++++++++++++++++++++++++++++++++++-
 6 files changed, 481 insertions(+), 18 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 02b12a3..62f49ad 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -236,6 +236,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 
 	kfree(ctx->pids_arr);
 
+	sock_listening_list_free(&ctx->listen_sockets);
+
 	kfree(ctx);
 }
 
@@ -269,6 +271,8 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 
 	mutex_init(&ctx->msg_mutex);
 
+	INIT_LIST_HEAD(&ctx->listen_sockets);
+
 	err = -EBADF;
 	ctx->file = fget(fd);
 	if (!ctx->file)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e0f4bd1..57b8fd0 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -19,6 +19,7 @@
 #define RESTART_TASKSELF	0x1
 #define RESTART_FROZEN		0x2
 #define RESTART_GHOST		0x4
+#define RESTART_CONN_RESET      0x10
 
 /* misc user visible */
 #define CHECKPOINT_FD_NONE	-1
@@ -57,7 +58,8 @@ extern long do_sys_restart(pid_t pid, int fd,
 #define RESTART_USER_FLAGS  \
 	(RESTART_TASKSELF | \
 	 RESTART_FROZEN | \
-	 RESTART_GHOST)
+	 RESTART_GHOST | \
+	 RESTART_CONN_RESET)
 
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
@@ -103,7 +105,8 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 			      struct socket *socket,
 			      struct sockaddr *loc, unsigned *loc_len,
 			      struct sockaddr *rem, unsigned *rem_len);
-extern struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx);
+extern struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx, struct sock *sk);
+extern void sock_listening_list_free(struct list_head *head);
 
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index cf36fe1..1a6343a 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -15,6 +15,7 @@
 #include <linux/socket.h>
 #include <linux/un.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #else
 #include <sys/types.h>
 #include <linux/types.h>
@@ -576,6 +577,100 @@ struct ckpt_hdr_socket_unix {
 
 struct ckpt_hdr_socket_inet {
 	struct ckpt_hdr h;
+	__u32 daddr;
+	__u32 rcv_saddr;
+	__u32 saddr;
+	__u16 dport;
+	__u16 num;
+	__u16 sport;
+	__s16 uc_ttl;
+	__u16 cmsg_flags;
+
+	struct {
+		__u64 timeout;
+		__u32 ato;
+		__u32 lrcvtime;
+		__u16 last_seg_size;
+		__u16 rcv_mss;
+		__u8 pending;
+		__u8 quick;
+		__u8 pingpong;
+		__u8 blocked;
+	} icsk_ack __attribute__ ((aligned(8)));
+
+	/* FIXME: Skipped opt, tos, multicast, cork settings */
+
+	struct {
+		__u32 rcv_nxt;
+		__u32 copied_seq;
+		__u32 rcv_wup;
+		__u32 snd_nxt;
+		__u32 snd_una;
+		__u32 snd_sml;
+		__u32 rcv_tstamp;
+		__u32 lsndtime;
+
+		__u32 snd_wl1;
+		__u32 snd_wnd;
+		__u32 max_window;
+		__u32 mss_cache;
+		__u32 window_clamp;
+		__u32 rcv_ssthresh;
+		__u32 frto_highmark;
+
+		__u32 srtt;
+		__u32 mdev;
+		__u32 mdev_max;
+		__u32 rttvar;
+		__u32 rtt_seq;
+
+		__u32 packets_out;
+		__u32 retrans_out;
+
+		__u32 snd_up;
+		__u32 rcv_wnd;
+		__u32 write_seq;
+		__u32 pushed_seq;
+		__u32 lost_out;
+		__u32 sacked_out;
+		__u32 fackets_out;
+		__u32 tso_deferred;
+		__u32 bytes_acked;
+
+		__s32 lost_cnt_hint;
+		__u32 retransmit_high;
+
+		__u32 lost_retrans_low;
+
+		__u32 prior_ssthresh;
+		__u32 high_seq;
+
+		__u32 retrans_stamp;
+		__u32 undo_marker;
+		__s32 undo_retrans;
+		__u32 total_retrans;
+
+		__u32 urg_seq;
+		__u32 keepalive_time;
+		__u32 keepalive_intvl;
+
+		__u16 urg_data;
+		__u16 advmss;
+		__u8 frto_counter;
+		__u8 nonagle;
+
+		__u8 ecn_flags;
+		__u8 reordering;
+
+		__u8 keepalive_probes;
+	} tcp __attribute__ ((aligned(8)));
+
+	struct {
+		struct in6_addr saddr;
+		struct in6_addr rcv_saddr;
+		struct in6_addr daddr;
+	} inet6 __attribute__ ((aligned(8)));
+
 	__u32 laddr_len;
 	__u32 raddr_len;
 	struct sockaddr_in laddr;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 6edcaea..75e198f 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -79,6 +79,7 @@ struct ckpt_ctx {
 	wait_queue_head_t waitq;	/* waitqueue for restarting tasks */
 	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
+	struct list_head listen_sockets;/* listening parent sockets */
 
 	struct ckpt_stats stats;	/* statistics */
 
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 6fe7aa2..0eb8860 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -116,9 +116,9 @@ static void sock_record_header_info(struct sk_buff *skb,
 	h->nr_frags = skb_shinfo(skb)->nr_frags;
 }
 
-int sock_restore_header_info(struct ckpt_ctx *ctx,
-			     struct sk_buff *skb,
-			     struct ckpt_hdr_socket_buffer *h)
+static int sock_restore_header_info(struct ckpt_ctx *ctx,
+				    struct sock *sk, struct sk_buff *skb,
+				    struct ckpt_hdr_socket_buffer *h)
 {
 	if (h->mac_header + h->mac_len != h->network_header) {
 		ckpt_err(ctx, -EINVAL,
@@ -172,6 +172,8 @@ int sock_restore_header_info(struct ckpt_ctx *ctx,
 	skb->data = skb->head + h->data_offset;
 	skb->len = h->skb_len;
 
+	skb_shinfo(skb)->gso_type = sk->sk_gso_type;
+
 	return 0;
 }
 
@@ -217,7 +219,7 @@ static int sock_restore_skb_frag(struct ckpt_ctx *ctx,
 	return ret;
 }
 
-struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx)
+struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx, struct sock *sk)
 {
 	struct ckpt_hdr_socket_buffer *h;
 	struct sk_buff *skb = NULL;
@@ -270,7 +272,7 @@ struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx)
 		goto out;
 	}
 
-	sock_restore_header_info(ctx, skb, h);
+	sock_restore_header_info(ctx, sk, skb, h);
  out:
 	ckpt_hdr_put(ctx, h);
 	if (ret < 0) {
@@ -936,10 +938,9 @@ struct sock *do_sock_restore(struct ckpt_ctx *ctx)
 		goto err;
 
 	if ((h->sock_common.family == AF_INET) &&
-	    (h->sock.state != TCP_LISTEN)) {
-		/* Temporary hack to enable restore of TCP_LISTEN sockets
-		 * while forcing anything else to a closed state
-		 */
+	    (h->sock.state != TCP_LISTEN) &&
+	    (ctx->uflags & RESTART_CONN_RESET)) {
+		ckpt_debug("Forcing open socket closed\n");
 		sock->sk->sk_state = TCP_CLOSE;
 		sock->state = SS_UNCONNECTED;
 	}
diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
index 1982119..b4024e7 100644
--- a/net/ipv4/checkpoint.c
+++ b/net/ipv4/checkpoint.c
@@ -17,6 +17,7 @@
 #include <linux/deferqueue.h>
 #include <net/tcp_states.h>
 #include <net/tcp.h>
+#include <net/ipv6.h>
 
 struct dq_sock {
 	struct ckpt_ctx *ctx;
@@ -28,6 +29,248 @@ struct dq_buffers {
 	struct sock *sk;
 };
 
+struct listen_item {
+	struct sock *sk;
+	struct list_head list;
+};
+
+void sock_listening_list_free(struct list_head *head)
+{
+	struct listen_item *item, *tmp;
+
+	list_for_each_entry_safe(item, tmp, head, list) {
+		list_del(&item->list);
+		kfree(item);
+	}
+}
+
+static int sock_listening_list_add(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct listen_item *item;
+
+	item = kmalloc(sizeof(*item), GFP_KERNEL);
+	if (!item)
+		return -ENOMEM;
+
+	item->sk = sk;
+	list_add(&item->list, &ctx->listen_sockets);
+
+	return 0;
+}
+
+static struct sock *sock_get_parent(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct listen_item *item;
+
+	list_for_each_entry(item, &ctx->listen_sockets, list) {
+		if (inet_sk(sk)->inet_sport == inet_sk(item->sk)->inet_sport)
+			return item->sk;
+	}
+
+	return NULL;
+}
+
+static int sock_hash_parent(void *data)
+{
+	struct dq_sock *dq = (struct dq_sock *)data;
+	struct sock *parent;
+
+	ckpt_debug("INET post-restart hash\n");
+
+	dq->sk->sk_prot->hash(dq->sk);
+
+	/* If there is a listening socket with the same source port,
+	 * then become a child of that socket [we are the result of an
+	 * accept()].  Otherwise hash ourselves directly in [we are
+	 * the result of a connect()]
+	 */
+
+	parent = sock_get_parent(dq->ctx, dq->sk);
+	if (parent) {
+		inet_sk(dq->sk)->inet_num = ntohs(inet_sk(dq->sk)->inet_sport);
+		local_bh_disable();
+		__inet_inherit_port(parent, dq->sk);
+		local_bh_enable();
+	} else {
+		inet_sk(dq->sk)->inet_num = 0;
+		inet_hash_connect(&tcp_death_row, dq->sk);
+		inet_sk(dq->sk)->inet_num = ntohs(inet_sk(dq->sk)->inet_sport);
+	}
+
+	return 0;
+}
+
+static int sock_defer_hash(struct ckpt_ctx *ctx, struct sock *sock)
+{
+	struct dq_sock dq;
+
+	dq.sk = sock;
+	dq.ctx = ctx;
+
+	return deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
+			      sock_hash_parent, NULL);
+}
+
+static int sock_inet_tcp_cptrst(struct ckpt_ctx *ctx,
+				struct tcp_sock *sk,
+				struct ckpt_hdr_socket_inet *hh,
+				int op)
+{
+	CKPT_COPY(op, hh->tcp.rcv_nxt, sk->rcv_nxt);
+	CKPT_COPY(op, hh->tcp.copied_seq, sk->copied_seq);
+	CKPT_COPY(op, hh->tcp.rcv_wup, sk->rcv_wup);
+	CKPT_COPY(op, hh->tcp.snd_nxt, sk->snd_nxt);
+	CKPT_COPY(op, hh->tcp.snd_una, sk->snd_una);
+	CKPT_COPY(op, hh->tcp.snd_sml, sk->snd_sml);
+	CKPT_COPY(op, hh->tcp.rcv_tstamp, sk->rcv_tstamp);
+	CKPT_COPY(op, hh->tcp.lsndtime, sk->lsndtime);
+
+	CKPT_COPY(op, hh->tcp.snd_wl1, sk->snd_wl1);
+	CKPT_COPY(op, hh->tcp.snd_wnd, sk->snd_wnd);
+	CKPT_COPY(op, hh->tcp.max_window, sk->max_window);
+	CKPT_COPY(op, hh->tcp.mss_cache, sk->mss_cache);
+	CKPT_COPY(op, hh->tcp.window_clamp, sk->window_clamp);
+	CKPT_COPY(op, hh->tcp.rcv_ssthresh, sk->rcv_ssthresh);
+	CKPT_COPY(op, hh->tcp.frto_highmark, sk->frto_highmark);
+	CKPT_COPY(op, hh->tcp.advmss, sk->advmss);
+	CKPT_COPY(op, hh->tcp.frto_counter, sk->frto_counter);
+	CKPT_COPY(op, hh->tcp.nonagle, sk->nonagle);
+
+	CKPT_COPY(op, hh->tcp.srtt, sk->srtt);
+	CKPT_COPY(op, hh->tcp.mdev, sk->mdev);
+	CKPT_COPY(op, hh->tcp.mdev_max, sk->mdev_max);
+	CKPT_COPY(op, hh->tcp.rttvar, sk->rttvar);
+	CKPT_COPY(op, hh->tcp.rtt_seq, sk->rtt_seq);
+
+	CKPT_COPY(op, hh->tcp.packets_out, sk->packets_out);
+	CKPT_COPY(op, hh->tcp.retrans_out, sk->retrans_out);
+
+	CKPT_COPY(op, hh->tcp.urg_data, sk->urg_data);
+	CKPT_COPY(op, hh->tcp.ecn_flags, sk->ecn_flags);
+	CKPT_COPY(op, hh->tcp.reordering, sk->reordering);
+	CKPT_COPY(op, hh->tcp.snd_up, sk->snd_up);
+
+	CKPT_COPY(op, hh->tcp.keepalive_probes, sk->keepalive_probes);
+
+	CKPT_COPY(op, hh->tcp.rcv_wnd, sk->rcv_wnd);
+	CKPT_COPY(op, hh->tcp.write_seq, sk->write_seq);
+	CKPT_COPY(op, hh->tcp.pushed_seq, sk->pushed_seq);
+	CKPT_COPY(op, hh->tcp.lost_out, sk->lost_out);
+	CKPT_COPY(op, hh->tcp.sacked_out, sk->sacked_out);
+	CKPT_COPY(op, hh->tcp.fackets_out, sk->fackets_out);
+	CKPT_COPY(op, hh->tcp.tso_deferred, sk->tso_deferred);
+	CKPT_COPY(op, hh->tcp.bytes_acked, sk->bytes_acked);
+
+	CKPT_COPY(op, hh->tcp.lost_cnt_hint, sk->lost_cnt_hint);
+	CKPT_COPY(op, hh->tcp.retransmit_high, sk->retransmit_high);
+
+	CKPT_COPY(op, hh->tcp.lost_retrans_low, sk->lost_retrans_low);
+
+	CKPT_COPY(op, hh->tcp.prior_ssthresh, sk->prior_ssthresh);
+	CKPT_COPY(op, hh->tcp.high_seq, sk->high_seq);
+
+	CKPT_COPY(op, hh->tcp.retrans_stamp, sk->retrans_stamp);
+	CKPT_COPY(op, hh->tcp.undo_marker, sk->undo_marker);
+	CKPT_COPY(op, hh->tcp.undo_retrans, sk->undo_retrans);
+	CKPT_COPY(op, hh->tcp.total_retrans, sk->total_retrans);
+
+	CKPT_COPY(op, hh->tcp.urg_seq, sk->urg_seq);
+	CKPT_COPY(op, hh->tcp.keepalive_time, sk->keepalive_time);
+	CKPT_COPY(op, hh->tcp.keepalive_intvl, sk->keepalive_intvl);
+
+	if (!skb_queue_empty(&sk->ucopy.prequeue))
+		printk(KERN_ERR "PREQUEUE!\n");
+
+	return 0;
+}
+
+static int sock_inet_restore_connection(struct sock *sk,
+					struct ckpt_hdr_socket_inet *hh)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	int tcp_gso = sk->sk_family == AF_INET ? SKB_GSO_TCPV4 : SKB_GSO_TCPV6;
+
+	inet->inet_daddr = hh->raddr.sin_addr.s_addr;
+	inet->inet_saddr = hh->laddr.sin_addr.s_addr;
+	inet->inet_rcv_saddr = inet->inet_saddr;
+
+	inet->inet_dport = hh->raddr.sin_port;
+	inet->inet_sport = hh->laddr.sin_port;
+
+	if (sk->sk_protocol == IPPROTO_TCP)
+		sk->sk_gso_type = tcp_gso;
+	else if (sk->sk_protocol == IPPROTO_UDP)
+		sk->sk_gso_type = SKB_GSO_UDP;
+	else {
+		ckpt_debug("Unsupported socket type while setting GSO\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int sock_inet_cptrst(struct ckpt_ctx *ctx,
+			    struct sock *sk,
+			    struct ckpt_hdr_socket_inet *hh,
+			    int op)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	int ret;
+
+	if (op == CKPT_CPT) {
+		CKPT_COPY(op, hh->daddr, inet->inet_daddr);
+		CKPT_COPY(op, hh->rcv_saddr, inet->inet_rcv_saddr);
+		CKPT_COPY(op, hh->dport, inet->inet_dport);
+		CKPT_COPY(op, hh->saddr, inet->inet_saddr);
+		CKPT_COPY(op, hh->sport, inet->inet_sport);
+	} else {
+		ret = sock_inet_restore_connection(sk, hh);
+		if (ret)
+			return ret;
+	}
+
+	CKPT_COPY(op, hh->num, inet->inet_num);
+	CKPT_COPY(op, hh->uc_ttl, inet->uc_ttl);
+	CKPT_COPY(op, hh->cmsg_flags, inet->cmsg_flags);
+
+	CKPT_COPY(op, hh->icsk_ack.pending, icsk->icsk_ack.pending);
+	CKPT_COPY(op, hh->icsk_ack.quick, icsk->icsk_ack.quick);
+	CKPT_COPY(op, hh->icsk_ack.pingpong, icsk->icsk_ack.pingpong);
+	CKPT_COPY(op, hh->icsk_ack.blocked, icsk->icsk_ack.blocked);
+	CKPT_COPY(op, hh->icsk_ack.ato, icsk->icsk_ack.ato);
+	CKPT_COPY(op, hh->icsk_ack.timeout, icsk->icsk_ack.timeout);
+	CKPT_COPY(op, hh->icsk_ack.lrcvtime, icsk->icsk_ack.lrcvtime);
+	CKPT_COPY(op,
+		  hh->icsk_ack.last_seg_size, icsk->icsk_ack.last_seg_size);
+	CKPT_COPY(op, hh->icsk_ack.rcv_mss, icsk->icsk_ack.rcv_mss);
+
+	if (sk->sk_protocol == IPPROTO_TCP)
+		ret = sock_inet_tcp_cptrst(ctx, tcp_sk(sk), hh, op);
+	else if (sk->sk_protocol == IPPROTO_UDP)
+		ret = 0;
+	else {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret, "unknown socket protocol %d",
+			 sk->sk_protocol);
+	}
+
+	if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *inet6 = inet6_sk(sk);
+		if (op == CKPT_CPT) {
+			ipv6_addr_copy(&hh->inet6.saddr, &inet6->saddr);
+			ipv6_addr_copy(&hh->inet6.rcv_saddr, &inet6->rcv_saddr);
+			ipv6_addr_copy(&hh->inet6.daddr, &inet6->daddr);
+		} else {
+			ipv6_addr_copy(&inet6->saddr, &hh->inet6.saddr);
+			ipv6_addr_copy(&inet6->rcv_saddr, &hh->inet6.rcv_saddr);
+			ipv6_addr_copy(&inet6->daddr, &hh->inet6.daddr);
+		}
+	}
+
+	return ret;
+}
+
 int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 {
 	struct ckpt_hdr_socket_inet *in;
@@ -43,6 +286,10 @@ int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 	if (ret)
 		goto out;
 
+	ret = sock_inet_cptrst(ctx, sock->sk, in, CKPT_CPT);
+	if (ret < 0)
+		goto out;
+
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) in);
  out:
 	ckpt_hdr_put(ctx, in);
@@ -55,11 +302,13 @@ int inet_collect(struct ckpt_ctx *ctx, struct socket *sock)
 	return ckpt_obj_collect(ctx, sock->sk, CKPT_OBJ_SOCK);
 }
 
-static int inet_read_buffer(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+static int inet_read_buffer(struct ckpt_ctx *ctx,
+			    struct sk_buff_head *queue,
+			    struct sock *sk)
 {
 	struct sk_buff *skb = NULL;
 
-	skb = sock_restore_skb(ctx);
+	skb = sock_restore_skb(ctx, sk);
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
 
@@ -67,7 +316,9 @@ static int inet_read_buffer(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
 	return skb->len;
 }
 
-static int inet_read_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
+static int inet_read_buffers(struct ckpt_ctx *ctx,
+			     struct sk_buff_head *queue,
+			     struct sock *sk)
 {
 	struct ckpt_hdr_socket_queue *h;
 	int ret = 0;
@@ -78,7 +329,7 @@ static int inet_read_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
 		return PTR_ERR(h);
 
 	for (i = 0; i < h->skb_count; i++) {
-		ret = inet_read_buffer(ctx, queue);
+		ret = inet_read_buffer(ctx, queue, sk);
 		ckpt_debug("read inet buffer %i: %i", i, ret);
 		if (ret < 0)
 			goto out;
@@ -106,12 +357,12 @@ static int inet_deferred_restore_buffers(void *data)
 	struct sock *sk = dq->sk;
 	int ret;
 
-	ret = inet_read_buffers(ctx, &sk->sk_receive_queue);
+	ret = inet_read_buffers(ctx, &sk->sk_receive_queue, sk);
 	ckpt_debug("(R) inet_read_buffers: %i\n", ret);
 	if (ret < 0)
 		return ret;
 
-	ret = inet_read_buffers(ctx, &sk->sk_write_queue);
+	ret = inet_read_buffers(ctx, &sk->sk_write_queue, sk);
 	ckpt_debug("(W) inet_read_buffers: %i\n", ret);
 
 	return ret;
@@ -130,6 +381,19 @@ static int inet_defer_restore_buffers(struct ckpt_ctx *ctx, struct sock *sk)
 
 static int inet_precheck(struct socket *sock, struct ckpt_hdr_socket_inet *in)
 {
+	__u8 icsk_ack_mask = ICSK_ACK_SCHED | ICSK_ACK_TIMER |
+		ICSK_ACK_PUSHED | ICSK_ACK_PUSHED2;
+	__u16 urg_mask = TCP_URG_VALID | TCP_URG_NOTYET | TCP_URG_READ;
+	__u8 nonagle_mask = TCP_NAGLE_OFF | TCP_NAGLE_CORK | TCP_NAGLE_PUSH;
+	__u8 ecn_mask = TCP_ECN_OK | TCP_ECN_QUEUE_CWR | TCP_ECN_DEMAND_CWR;
+
+	if ((htons(in->laddr.sin_port) < PROT_SOCK) &&
+	    !capable(CAP_NET_BIND_SERVICE)) {
+		ckpt_debug("unable to bind to port %hu\n",
+			   htons(in->laddr.sin_port));
+		return -EINVAL;
+	}
+
 	if (in->laddr_len > sizeof(struct sockaddr_in)) {
 		ckpt_debug("laddr_len is too big\n");
 		return -EINVAL;
@@ -140,6 +404,75 @@ static int inet_precheck(struct socket *sock, struct ckpt_hdr_socket_inet *in)
 		return -EINVAL;
 	}
 
+	/* Set ato to the default */
+	in->icsk_ack.ato = TCP_ATO_MIN;
+
+	/* No quick acks are scheduled after a restart */
+	in->icsk_ack.quick = 0;
+
+	if (in->icsk_ack.pending & ~icsk_ack_mask) {
+		ckpt_debug("invalid pending flags 0x%x\n",
+			   in->icsk_ack.pending & ~icsk_ack_mask);
+		return -EINVAL;
+	}
+
+	if (in->icsk_ack.pingpong > 1) {
+		ckpt_debug("invalid icsk_ack.pingpong value\n");
+		return -EINVAL;
+	}
+
+	if (in->icsk_ack.blocked > 1) {
+		ckpt_debug("invalid icsk_ack.blocked value\n");
+		return -EINVAL;
+	}
+
+	/* do_tcp_setsockopt() quietly makes this coercion */
+	if (in->tcp.window_clamp < (SOCK_MIN_RCVBUF / 2))
+		in->tcp.window_clamp = SOCK_MIN_RCVBUF / 2;
+	else
+		in->tcp.window_clamp = min(in->tcp.window_clamp, 65535U);
+
+	if (in->tcp.rcv_ssthresh > (4U * in->tcp.advmss))
+		in->tcp.rcv_ssthresh = 4U * in->tcp.advmss;
+
+	/* These will all be recalculated on the next call to
+	 * tcp_rtt_estimator()
+	 */
+	in->tcp.srtt = in->tcp.mdev = in->tcp.mdev_max = 0;
+	in->tcp.rttvar = in->tcp.rtt_seq = 0;
+
+	/* Might want to set packets_out to zero ? */
+
+	if (in->tcp.rcv_wnd > MAX_TCP_WINDOW)
+		in->tcp.rcv_wnd = MAX_TCP_WINDOW;
+
+	if (in->tcp.keepalive_intvl > MAX_TCP_KEEPINTVL) {
+		ckpt_debug("keepalive_intvl %i out of range\n",
+			   in->tcp.keepalive_intvl);
+		return -EINVAL;
+	}
+
+	if (in->tcp.keepalive_probes > MAX_TCP_KEEPCNT) {
+		ckpt_debug("Invalid keepalive_probes value %i\n",
+			   in->tcp.keepalive_probes);
+		return -EINVAL;
+	}
+
+	if (in->tcp.urg_data & ~urg_mask) {
+		ckpt_debug("Invalid urg_data value\n");
+		return -EINVAL;
+	}
+
+	if (in->tcp.nonagle & ~nonagle_mask) {
+		ckpt_debug("Invalid nonagle value\n");
+		return -EINVAL;
+	}
+
+	if (in->tcp.ecn_flags & ~ecn_mask) {
+		ckpt_debug("Invalid ecn_flags value\n");
+		return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -177,8 +510,35 @@ int inet_restore(struct ckpt_ctx *ctx,
 			ckpt_debug("inet listen: %i\n", ret);
 			if (ret < 0)
 				goto out;
+
+			/* We are a listening socket, so add ourselves
+			 * to the list of parent sockets.  This will
+			 * allow our children to find us later and
+			 * link up
+			 */
+
+			ret = sock_listening_list_add(ctx, sock->sk);
+			if (ret < 0)
+				goto out;
 		}
 	} else {
+		ret = sock_inet_cptrst(ctx, sock->sk, in, CKPT_RST);
+		if (ret)
+			goto out;
+
+		if ((h->sock.state == TCP_ESTABLISHED) &&
+		    (h->sock.protocol == IPPROTO_TCP)) {
+			/* A connected socket that was spawned from an
+			 * accept() needs to be hashed with its parent
+			 * listening socket in order to receive
+			 * traffic on the original port.  Since we may
+			 * not have restarted the parent yet, we defer
+			 * this until later when we know we have all
+			 * the listening sockets accounted for.
+			 */
+			ret = sock_defer_hash(ctx, sock->sk);
+		}
+
 		if (!sock_flag(sock->sk, SOCK_DEAD))
 			ret = inet_defer_restore_buffers(ctx, sock->sk);
 	}
@@ -187,4 +547,3 @@ int inet_restore(struct ckpt_ctx *ctx,
 
 	return ret;
 }
-
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
