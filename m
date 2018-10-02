Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id E047F6B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 23:01:19 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id e15-v6so387591oie.16
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 20:01:19 -0700 (PDT)
Received: from m12-14.163.com (m12-14.163.com. [220.181.12.14])
        by mx.google.com with ESMTP id a133-v6si1783051oih.126.2018.10.01.20.01.17
        for <linux-mm@kvack.org>;
        Mon, 01 Oct 2018 20:01:18 -0700 (PDT)
From: jun qian <hangdianqj@163.com>
Subject: [PATCH] mm:slab: Adjust the print format for the slabinfo
Date: Mon,  1 Oct 2018 19:59:39 -0700
Message-Id: <20181002025939.115804-1-hangdianqj@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jun qian <hangdianqj@163.com>, Barry song <21cnbao@gmail.com>

Header and the corresponding information is not aligned,
adjust the printing format helps us to understand the slabinfo better.

Signed-off-by: jun qian <hangdianqj@163.com>
Cc: Barry song <21cnbao@gmail.com>
---
 mm/slab_common.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index fea3376f9816..07a324cbbfb6 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1263,9 +1263,13 @@ static void print_slabinfo_header(struct seq_file *m)
 #else
 	seq_puts(m, "slabinfo - version: 2.1\n");
 #endif
-	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>");
-	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
-	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
+	seq_printf(m, "%-22s %-14s %-11s %-10s %-13s %-14s",
+		  "# name", "<active_objs>", "<num_objs>", "<objsize>",
+		  "<objperslab>", "<pagesperslab>");
+	seq_printf(m, " : %-9s %-8s %-13s %-14s",
+		  "tunables", "<limit>", "<batchcount>", "<sharedfactor>");
+	seq_printf(m, " : %-9s %-15s %-12s %-16s",
+		  "slabdata", "<active_slabs>", "<num_slabs>", "<sharedavail>");
 #ifdef CONFIG_DEBUG_SLAB
 	seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> <error> <maxfreeable> <nodeallocs> <remotefrees> <alienoverflow>");
 	seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
@@ -1319,13 +1323,13 @@ static void cache_show(struct kmem_cache *s, struct seq_file *m)
 
 	memcg_accumulate_slabinfo(s, &sinfo);
 
-	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
+	seq_printf(m, "%-22s %-14lu %-11lu %-10u %-13u %-14d",
 		   cache_name(s), sinfo.active_objs, sinfo.num_objs, s->size,
 		   sinfo.objects_per_slab, (1 << sinfo.cache_order));
 
-	seq_printf(m, " : tunables %4u %4u %4u",
+	seq_printf(m, " : %-9s %-8u %-13u %-14u", "tunables",
 		   sinfo.limit, sinfo.batchcount, sinfo.shared);
-	seq_printf(m, " : slabdata %6lu %6lu %6lu",
+	seq_printf(m, " : %-9s %-15lu %-12lu %-16lu", "slabdata",
 		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail);
 	slabinfo_show_stats(m, s);
 	seq_putc(m, '\n');
-- 
2.17.1
