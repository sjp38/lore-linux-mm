Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 25B396B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 21:52:11 -0400 (EDT)
Received: by pacgg7 with SMTP id gg7so69087641pac.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 18:52:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id z7si5256002pas.78.2015.04.01.18.52.09
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 18:52:10 -0700 (PDT)
Date: Thu, 2 Apr 2015 09:51:14 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH mmotm] set_page_huge_active() can be static
Message-ID: <20150402015114.GA32212@lkp-sb04>
References: <201504020952.5zwySb4V%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201504020952.5zwySb4V%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Luiz Capitulino <lcapitulino@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 hugetlb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b527a7a..e837e0b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -937,13 +937,13 @@ bool page_huge_active(struct page *page)
 }
 
 /* never called for tail page */
-void set_page_huge_active(struct page *page)
+static void set_page_huge_active(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
 	SetPagePrivate(&page[1]);
 }
 
-void clear_page_huge_active(struct page *page)
+static void clear_page_huge_active(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
 	ClearPagePrivate(&page[1]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
