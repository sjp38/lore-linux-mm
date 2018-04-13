Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFFD56B002C
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:33:47 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id j80so5404869ywg.1
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:33:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 80si7293628qkg.344.2018.04.13.06.33.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:33:46 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 8/8] mm: export more functions used to online/offline memory
Date: Fri, 13 Apr 2018 15:33:42 +0200
Message-Id: <20180413133344.3672-1-david@redhat.com>
In-Reply-To: <20180413131632.1413-1-david@redhat.com>
References: <20180413131632.1413-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, open list <linux-kernel@vger.kernel.org>

Kernel modules that want to control how/when memory is onlined/offlined
need these functions.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ac14ea772792..3c374d308cf4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -979,6 +979,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	memory_notify(MEM_CANCEL_ONLINE, &arg);
 	return ret;
 }
+EXPORT_SYMBOL(online_pages);
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 static void reset_node_present_pages(pg_data_t *pgdat)
@@ -1296,6 +1297,7 @@ bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 	/* All pageblocks in the memory block are likely to be hot-removable */
 	return true;
 }
+EXPORT_SYMBOL(is_mem_section_removable);
 
 /*
  * Confirm all pages in a range [start, end) belong to the same zone.
@@ -1752,6 +1754,7 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
 	return __offline_pages(start_pfn, start_pfn + nr_pages);
 }
+EXPORT_SYMBOL(offline_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /**
@@ -1802,6 +1805,7 @@ int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 
 	return 0;
 }
+EXPORT_SYMBOL(walk_memory_range);
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
-- 
2.14.3
