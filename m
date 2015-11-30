Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7146B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 13:29:44 -0500 (EST)
Received: by wmec201 with SMTP id c201so169759314wme.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 10:29:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v191si30525360wmd.52.2015.11.30.10.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 10:29:42 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] MAINTAINERS: make Vladimir co-maintainer of the memory controller
Date: Mon, 30 Nov 2015 13:29:30 -0500
Message-Id: <1448908170-2990-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Vladimir architected and authored much of the current state of the
memcg's slab memory accounting and tracking. Make sure he gets CC'd
on bug reports ;-)

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index ea17512..f97f17f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2973,6 +2973,7 @@ F:	kernel/cpuset.c
 CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)
 M:	Johannes Weiner <hannes@cmpxchg.org>
 M:	Michal Hocko <mhocko@kernel.org>
+M:	Vladimir Davydov <vdavydov@virtuozzo.com>
 L:	cgroups@vger.kernel.org
 L:	linux-mm@kvack.org
 S:	Maintained
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
