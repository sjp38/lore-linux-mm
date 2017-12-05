Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 886056B0069
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 09:34:24 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id m6so231892wrf.1
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 06:34:24 -0800 (PST)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id z37si181489wrc.232.2017.12.05.06.34.23
        for <linux-mm@kvack.org>;
        Tue, 05 Dec 2017 06:34:23 -0800 (PST)
Date: Tue, 5 Dec 2017 15:34:22 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH] mm: memory_hotplug: Remove unnecesary check from
 register_page_bootmem_info_section()
Message-ID: <20171205143422.GA31458@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, akpm@linux-foundation.org, vbabka@suse.cz

When we call register_page_bootmem_info_section() having CONFIG_SPARSEMEM_VMEMMAP enabled,
we check if the pfn is valid.
This check is redundant as we already checked this in register_page_bootmem_info_node()
before calling register_page_bootmem_info_section(), so let's get rid of it.

Signed-off-by: Oscar Salvador <osalvador@techadventures.net>
---
 mm/memory_hotplug.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d0856ab2f28d..7452a53b027f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -200,9 +200,6 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 	struct mem_section *ms;
 	struct page *page, *memmap;
 
-	if (!pfn_valid(start_pfn))
-		return;
-
 	section_nr = pfn_to_section_nr(start_pfn);
 	ms = __nr_to_section(section_nr);
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
