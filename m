Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 5F3356B0110
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:00:48 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so1836374pad.5
        for <linux-mm@kvack.org>; Wed, 29 May 2013 07:00:47 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 41/41] mm: kill global variable num_physpages
Date: Wed, 29 May 2013 21:57:59 +0800
Message-Id: <1369835879-23553-42-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <khlebnikov@openvz.org>

Now all references to num_physpages have been removed, so kill it.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/mm.h | 1 -
 mm/memory.c        | 2 --
 mm/nommu.c         | 2 --
 3 files changed, 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8e4f0ed..7e39aa1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -29,7 +29,6 @@ struct writeback_control;
 extern unsigned long max_mapnr;
 #endif
 
-extern unsigned long num_physpages;
 extern unsigned long totalram_pages;
 extern void * high_memory;
 extern int page_cluster;
diff --git a/mm/memory.c b/mm/memory.c
index 44bb67b..26fa5ad 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -82,7 +82,6 @@ EXPORT_SYMBOL(max_mapnr);
 EXPORT_SYMBOL(mem_map);
 #endif
 
-unsigned long num_physpages;
 /*
  * A number of key systems in x86 including ioremap() rely on the assumption
  * that high_memory defines the upper bound on direct map memory, then end
@@ -92,7 +91,6 @@ unsigned long num_physpages;
  */
 void * high_memory;
 
-EXPORT_SYMBOL(num_physpages);
 EXPORT_SYMBOL(high_memory);
 
 /*
diff --git a/mm/nommu.c b/mm/nommu.c
index 886e07c..0c42c9e 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -56,7 +56,6 @@
 void *high_memory;
 struct page *mem_map;
 unsigned long max_mapnr;
-unsigned long num_physpages;
 unsigned long highest_memmap_pfn;
 struct percpu_counter vm_committed_as;
 int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
@@ -85,7 +84,6 @@ unsigned long vm_memory_committed(void)
 EXPORT_SYMBOL_GPL(vm_memory_committed);
 
 EXPORT_SYMBOL(mem_map);
-EXPORT_SYMBOL(num_physpages);
 
 /* list of mapped, potentially shareable regions */
 static struct kmem_cache *vm_region_jar;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
