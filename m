Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id EA2AD6B0039
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 07:12:55 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y13so3078827pdi.37
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:12:55 -0800 (PST)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id ez5si4872377pab.77.2014.02.07.04.12.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 04:12:54 -0800 (PST)
Received: by mail-pd0-f171.google.com with SMTP id g10so3078382pdj.2
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:12:53 -0800 (PST)
Date: Fri, 7 Feb 2014 17:42:49 +0530
From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 8/9] mm: Mark function as static in nobootmem.c
Message-ID: <bc0e22c79ac3af48f50a81ddb5e449018685ac4d.1391167128.git.rashika.kheria@gmail.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jiang Liu <jiang.liu@huawei.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, josh@joshtriplett.org

Mark function as static in nobootmem.c because it is not used outside
this file.

This eliminates the following warning in mm/nobootmem.c:
mm/nobootmem.c:324:15: warning: no previous prototype for a??___alloc_bootmem_nodea?? [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---

The symbol '___alloc_bootmem_node' has also been defined in
mm/bootmem.c. Both the implementations are almost similar and hence
should be unified.

 mm/nobootmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 2c254d3..a3724a1 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -321,7 +321,7 @@ void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
 }
 
-void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
+static void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 				    unsigned long align, unsigned long goal,
 				    unsigned long limit)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
