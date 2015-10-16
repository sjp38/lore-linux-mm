Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id E773C82F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 18:51:37 -0400 (EDT)
Received: by obbda8 with SMTP id da8so102032729obb.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:51:37 -0700 (PDT)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id m130si11441248oif.92.2015.10.16.15.51.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 15:51:37 -0700 (PDT)
Received: by obcqt19 with SMTP id qt19so23875671obc.3
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:51:37 -0700 (PDT)
Date: Fri, 16 Oct 2015 15:51:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm] mm: use unsigned int for page order fix 2
Message-ID: <alpine.LSU.2.11.1510161546430.31102@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Some configs now end up with MAX_ORDER and pageblock_order having
different types: silence compiler warning in __free_one_page().

Signed-off-by: Hugh Dickins <hughd@google.com>

--- mmotm/mm/page_alloc.c	2015-10-15 15:26:59.855572338 -0700
+++ linux/mm/page_alloc.c	2015-10-16 11:54:20.847027790 -0700
@@ -679,7 +679,7 @@ static inline void __free_one_page(struc
 		 * pageblock. Without this, pageblock isolation
 		 * could cause incorrect freepage accounting.
 		 */
-		max_order = min(MAX_ORDER, pageblock_order + 1);
+		max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 	} else {
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
