Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68F9F8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 01:36:24 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 2-v6so10988286plc.11
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 22:36:24 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c19-v6si20646945pfc.18.2018.09.10.22.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 22:36:23 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH 1/9] mm: do not add anon pages to LRU
Date: Tue, 11 Sep 2018 13:36:08 +0800
Message-Id: <20180911053616.6894-2-aaron.lu@intel.com>
In-Reply-To: <20180911053616.6894-1-aaron.lu@intel.com>
References: <20180911053616.6894-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Yosef Lev <levyossi@icloud.com>, Jesper Dangaard Brouer <brouer@redhat.com>

For the sake of testing purpose, do not add anon pages to LRU to
avoid LRU lock so we can test zone lock exclusively.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..080641255b8b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3208,7 +3208,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, vmf->address, false);
 	mem_cgroup_commit_charge(page, memcg, false, false);
-	lru_cache_add_active_or_unevictable(page, vma);
+	//lru_cache_add_active_or_unevictable(page, vma);
 setpte:
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);
 
-- 
2.17.1
