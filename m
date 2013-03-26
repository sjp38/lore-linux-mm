Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 8623B6B0138
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 12:04:32 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id ma3so4830922pbc.39
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 09:04:31 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v3, part4 39/39] mm: kill global variable num_physpages
Date: Tue, 26 Mar 2013 23:54:58 +0800
Message-Id: <1364313298-17336-40-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
References: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <khlebnikov@openvz.org>

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
Hi all,
	Sorry for my mistake that my previous patch series has been screwed up.
So I regenerate a third version and also set up a git tree at:
	git://github.com/jiangliu/linux.git mem_init
	Any help to review and test are welcomed!

	Regards!
	Gerry
---
 include/linux/mm.h |    1 -
 mm/memory.c        |    2 --
 mm/nommu.c         |    2 --
 3 files changed, 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c225a4f..a49afbf 100644
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
index 705473a..ecc771d 100644
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
index 4eb25a8..ac23388 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -55,7 +55,6 @@
 void *high_memory;
 struct page *mem_map;
 unsigned long max_mapnr;
-unsigned long num_physpages;
 unsigned long highest_memmap_pfn;
 struct percpu_counter vm_committed_as;
 int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
@@ -82,7 +81,6 @@ unsigned long vm_memory_committed(void)
 EXPORT_SYMBOL_GPL(vm_memory_committed);
 
 EXPORT_SYMBOL(mem_map);
-EXPORT_SYMBOL(num_physpages);
 
 /* list of mapped, potentially shareable regions */
 static struct kmem_cache *vm_region_jar;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
