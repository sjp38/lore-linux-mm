Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 991C16B0038
	for <linux-mm@kvack.org>; Fri,  1 May 2015 05:23:35 -0400 (EDT)
Received: by wizk4 with SMTP id k4so47450226wiz.1
        for <linux-mm@kvack.org>; Fri, 01 May 2015 02:23:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h17si7067301wiw.28.2015.05.01.02.23.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 May 2015 02:23:34 -0700 (PDT)
Date: Fri, 1 May 2015 10:23:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: meminit: Reduce number of times pageblocks are set
 during struct page init -fix
Message-ID: <20150501092330.GD2449@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <1430231830-7702-13-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1430231830-7702-13-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


The patch "mm: meminit: Reduce number of times pageblocks are
set during struct page init" is setting a pageblock before
the page is initialised. This is a fix for the mmotm patch
mm-meminit-reduce-number-of-times-pageblocks-are-set-during-struct-page-init.patch

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 19aac687963c..544edb3b8da2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4497,8 +4497,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		if (!(pfn & (pageblock_nr_pages - 1))) {
 			struct page *page = pfn_to_page(pfn);
 
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 			__init_single_page(page, pfn, zone, nid);
+			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 		} else {
 			__init_single_pfn(pfn, zone, nid);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
