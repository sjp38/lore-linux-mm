Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 331956B025B
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:39:57 -0500 (EST)
Received: by pfbg73 with SMTP id g73so47992054pfb.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:39:57 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id o82si19872446pfa.139.2015.12.10.03.39.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:39:56 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 7/7] Documentation: cgroup: add memory.swap.{current,max} description
Date: Thu, 10 Dec 2015 14:39:20 +0300
Message-ID: <24930f544e7e98a23a17c9adcacb9397b1b8cae7.1449742561.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1449742560.git.vdavydov@virtuozzo.com>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 Documentation/cgroup.txt | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/Documentation/cgroup.txt b/Documentation/cgroup.txt
index 31d1f7bf12a1..21c6c013c339 100644
--- a/Documentation/cgroup.txt
+++ b/Documentation/cgroup.txt
@@ -819,6 +819,22 @@ PAGE_SIZE multiple when read back.
 		the cgroup.  This may not exactly match the number of
 		processes killed but should generally be close.
 
+  memory.swap.current
+
+	A read-only single value file which exists on non-root
+	cgroups.
+
+	The total amount of swap currently being used by the cgroup
+	and its descendants.
+
+  memory.swap.max
+
+	A read-write single value file which exists on non-root
+	cgroups.  The default is "max".
+
+	Swap usage hard limit.  If a cgroup's swap usage reaches this
+	limit, anonymous meomry of the cgroup will not be swapped out.
+
 
 5-2-2. General Usage
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
