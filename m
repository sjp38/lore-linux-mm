Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 44FBE6B0036
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 22:31:09 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so1948425pbc.16
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 19:31:08 -0700 (PDT)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id vo7si2664938pab.57.2014.03.13.19.31.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 19:31:08 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so1954500pbb.31
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 19:31:08 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH] Change mm debug routines back to EXPORT_SYMBOL
Date: Thu, 13 Mar 2014 19:30:46 -0700
Message-Id: <1394764246-19936-2-git-send-email-jhubbard@nvidia.com>
In-Reply-To: <1394764246-19936-1-git-send-email-jhubbard@nvidia.com>
References: <1394764246-19936-1-git-send-email-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

A new dump_page() routine was recently added, and marked
EXPORT_SYMBOL_GPL. This routine was also added to the
VM_BUG_ON_PAGE() macro, and so the end result is that non-GPL
code can no longer call get_page() and a few other routines.

This trivial patch simply changes dump_page() to be
EXPORT_SYMBOL.

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3bac76a..7a92925 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6564,4 +6564,4 @@ void dump_page(struct page *page, char *reason)
 {
 	dump_page_badflags(page, reason, 0);
 }
-EXPORT_SYMBOL_GPL(dump_page);
+EXPORT_SYMBOL(dump_page);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
