Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id A3DD76B0073
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 12:33:22 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id u10so818185lbd.36
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 09:33:21 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ji9si1563897lbc.48.2014.06.24.09.33.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jun 2014 09:33:20 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/3] page-cgroup: get rid of NR_PCG_FLAGS
Date: Tue, 24 Jun 2014 20:33:05 +0400
Message-ID: <26252c1699103f7efe51b224dd61bdb74e31f255.1403626729.git.vdavydov@parallels.com>
In-Reply-To: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
References: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

It's not used anywhere today, so let's remove it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/page_cgroup.h |    6 ------
 kernel/bounds.c             |    2 --
 2 files changed, 8 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 23863edb95ff..fb60e4a466c0 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -6,12 +6,8 @@ enum {
 	PCG_USED,	/* This page is charged to a memcg */
 	PCG_MEM,	/* This page holds a memory charge */
 	PCG_MEMSW,	/* This page holds a memory+swap charge */
-	__NR_PCG_FLAGS,
 };
 
-#ifndef __GENERATING_BOUNDS_H
-#include <generated/bounds.h>
-
 struct pglist_data;
 
 #ifdef CONFIG_MEMCG
@@ -107,6 +103,4 @@ static inline void swap_cgroup_swapoff(int type)
 
 #endif /* CONFIG_MEMCG_SWAP */
 
-#endif /* !__GENERATING_BOUNDS_H */
-
 #endif /* __LINUX_PAGE_CGROUP_H */
diff --git a/kernel/bounds.c b/kernel/bounds.c
index 9fd4246b04b8..e1d1d1952bfa 100644
--- a/kernel/bounds.c
+++ b/kernel/bounds.c
@@ -9,7 +9,6 @@
 #include <linux/page-flags.h>
 #include <linux/mmzone.h>
 #include <linux/kbuild.h>
-#include <linux/page_cgroup.h>
 #include <linux/log2.h>
 #include <linux/spinlock_types.h>
 
@@ -18,7 +17,6 @@ void foo(void)
 	/* The enum constants to put into include/generated/bounds.h */
 	DEFINE(NR_PAGEFLAGS, __NR_PAGEFLAGS);
 	DEFINE(MAX_NR_ZONES, __MAX_NR_ZONES);
-	DEFINE(NR_PCG_FLAGS, __NR_PCG_FLAGS);
 #ifdef CONFIG_SMP
 	DEFINE(NR_CPUS_BITS, ilog2(CONFIG_NR_CPUS));
 #endif
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
