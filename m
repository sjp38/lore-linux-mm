Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BDB298D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 22:35:58 -0400 (EDT)
Received: by iyh42 with SMTP id 42so724778iyh.14
        for <linux-mm@kvack.org>; Mon, 11 Apr 2011 19:35:56 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH RESEND 1/4] memcg: mark init_section_page_cgroup() properly
Date: Tue, 12 Apr 2011 11:35:34 +0900
Message-Id: <1302575737-6401-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

The commit ca371c0d7e23 ("memcg: fix page_cgroup fatal error
in FLATMEM") removes call to alloc_bootmem() in the function
so that it can be marked as __meminit to reduce memory usage
when MEMORY_HOTPLUG=n.

Also as new helper function alloc_page_cgroup() is called only
in the function, it should be marked too.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>
---
I kept Acked-by's because it seemed like a trivial change, no?

 mm/page_cgroup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 99055010cece..81205c52735c 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -130,7 +130,7 @@ struct page *lookup_cgroup_page(struct page_cgroup *pc)
 	return page;
 }
 
-static void *__init_refok alloc_page_cgroup(size_t size, int nid)
+static void *__meminit alloc_page_cgroup(size_t size, int nid)
 {
 	void *addr = NULL;
 
@@ -162,7 +162,7 @@ static void free_page_cgroup(void *addr)
 }
 #endif
 
-static int __init_refok init_section_page_cgroup(unsigned long pfn)
+static int __meminit init_section_page_cgroup(unsigned long pfn)
 {
 	struct page_cgroup *base, *pc;
 	struct mem_section *section;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
