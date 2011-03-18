Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC00E8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 08:54:32 -0400 (EDT)
Received: by iyf13 with SMTP id 13so5447379iyf.14
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 05:54:31 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 1/3] memcg: mark init_section_page_cgroup() properly
Date: Fri, 18 Mar 2011 21:54:13 +0900
Message-Id: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

The commit ca371c0d7e23 ("memcg: fix page_cgroup fatal error
in FLATMEM") removes call to alloc_bootmem() in the function
so that it can be marked as __meminit to reduce memory usage
when MEMORY_HOTPLUG=n.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_cgroup.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 5bffada7cde1..2d1a0fa01d7b 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -105,8 +105,7 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 	return section->page_cgroup + pfn;
 }
 
-/* __alloc_bootmem...() is protected by !slab_available() */
-static int __init_refok init_section_page_cgroup(unsigned long pfn)
+static int __meminit init_section_page_cgroup(unsigned long pfn)
 {
 	struct mem_section *section = __pfn_to_section(pfn);
 	struct page_cgroup *base, *pc;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
