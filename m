Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id AF86C6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 14:01:57 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id b14so96467335wmb.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 11:01:57 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w20si5866656wmw.101.2016.01.21.11.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 11:01:55 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] net: sock: remove dead cgroup methods from struct proto
Date: Thu, 21 Jan 2016 14:01:11 -0500
Message-Id: <1453402871-2548-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The cgroup methods are no longer used after baac50b ("net:
tcp_memcontrol: simplify linkage between socket and page counter").
The hunk to delete them was included in the original patch but must
have gotten lost during conflict resolution on the way upstream.

Fixes: baac50b ("net: tcp_memcontrol: simplify linkage between socket and page counter")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/net/sock.h | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index b9e7b3d..f5ea148 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1036,18 +1036,6 @@ struct proto {
 #ifdef SOCK_REFCNT_DEBUG
 	atomic_t		socks;
 #endif
-#ifdef CONFIG_MEMCG_KMEM
-	/*
-	 * cgroup specific init/deinit functions. Called once for all
-	 * protocols that implement it, from cgroups populate function.
-	 * This function has to setup any files the protocol want to
-	 * appear in the kmem cgroup filesystem.
-	 */
-	int			(*init_cgroup)(struct mem_cgroup *memcg,
-					       struct cgroup_subsys *ss);
-	void			(*destroy_cgroup)(struct mem_cgroup *memcg);
-	struct cg_proto		*(*proto_cgroup)(struct mem_cgroup *memcg);
-#endif
 	int			(*diag_destroy)(struct sock *sk, int err);
 };
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
