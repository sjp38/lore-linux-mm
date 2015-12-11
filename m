Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 854C66B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:54:28 -0500 (EST)
Received: by wmec201 with SMTP id c201so84757220wme.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:54:28 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w187si7200037wmg.6.2015.12.11.11.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 11:54:27 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/4] net: tcp_memcontrol: simplify linkage between socket and page counter fix
Date: Fri, 11 Dec 2015 14:54:10 -0500
Message-Id: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Fixlet for the same-named patch currently in mmots. The forward decl
is no longer necessary when the socket directly points to the memcg.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/net/sock.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 0db770f..0835627 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -229,7 +229,6 @@ struct sock_common {
 	/* public: */
 };
 
-struct cg_proto;
 /**
   *	struct sock - network layer representation of sockets
   *	@__sk_common: shared layout with inet_timewait_sock
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
