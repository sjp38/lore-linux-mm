Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B1ED06B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 01:41:52 -0400 (EDT)
Received: by pacan13 with SMTP id an13so153014956pac.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 22:41:52 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id a8si9201308pdl.110.2015.07.22.22.41.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 22:41:51 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm, page_isolation: make set/unset_migratetype_isolate()
 file-local
Date: Thu, 23 Jul 2015 05:40:04 +0000
Message-ID: <1437630002-25936-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Nowaday, set/unset_migratetype_isolate() is defined and used only in
mm/page_isolation, so let's limit the scope within the file.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/page-isolation.h | 5 -----
 mm/page_isolation.c            | 5 +++--
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git v4.2-rc2.orig/include/linux/page-isolation.h v4.2-rc2/include/li=
nux/page-isolation.h
index 2dc1e1697b45..047d64706f2a 100644
--- v4.2-rc2.orig/include/linux/page-isolation.h
+++ v4.2-rc2/include/linux/page-isolation.h
@@ -65,11 +65,6 @@ undo_isolate_page_range(unsigned long start_pfn, unsigne=
d long end_pfn,
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 			bool skip_hwpoisoned_pages);
=20
-/*
- * Internal functions. Changes pageblock's migrate type.
- */
-int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)=
;
-void unset_migratetype_isolate(struct page *page, unsigned migratetype);
 struct page *alloc_migrate_target(struct page *page, unsigned long private=
,
 				int **resultp);
=20
diff --git v4.2-rc2.orig/mm/page_isolation.c v4.2-rc2/mm/page_isolation.c
index 32fdc1df05e5..4568fd58f70a 100644
--- v4.2-rc2.orig/mm/page_isolation.c
+++ v4.2-rc2/mm/page_isolation.c
@@ -9,7 +9,8 @@
 #include <linux/hugetlb.h>
 #include "internal.h"
=20
-int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
+static int set_migratetype_isolate(struct page *page,
+				bool skip_hwpoisoned_pages)
 {
 	struct zone *zone;
 	unsigned long flags, pfn;
@@ -72,7 +73,7 @@ int set_migratetype_isolate(struct page *page, bool skip_=
hwpoisoned_pages)
 	return ret;
 }
=20
-void unset_migratetype_isolate(struct page *page, unsigned migratetype)
+static void unset_migratetype_isolate(struct page *page, unsigned migratet=
ype)
 {
 	struct zone *zone;
 	unsigned long flags, nr_pages;
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
