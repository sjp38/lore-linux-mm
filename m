Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 019AF6B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 04:10:02 -0500 (EST)
Received: by iody8 with SMTP id y8so179269085iod.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 01:10:01 -0800 (PST)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id d2si9429419igx.86.2015.11.09.01.10.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 01:10:01 -0800 (PST)
Received: by iofh3 with SMTP id h3so12111410iof.3
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 01:10:01 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] hugetlb: trivial comment fix
Date: Mon,  9 Nov 2015 18:09:56 +0900
Message-Id: <1447060196-1803-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20151106064743.GA30023@hori1.linux.bs1.fc.nec.co.jp>
References: <20151106064743.GA30023@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Recently alloc_buddy_huge_page was renamed to __alloc_buddy_huge_page, so
let's sync comments.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git mmotm-2015-10-21-14-41/mm/hugetlb.c mmotm-2015-10-21-14-41_patched/mm/hugetlb.c
index 9e63f1a..1721c9d 100644
--- mmotm-2015-10-21-14-41/mm/hugetlb.c
+++ mmotm-2015-10-21-14-41_patched/mm/hugetlb.c
@@ -2133,7 +2133,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * First take pages out of surplus state.  Then make up the
 	 * remaining difference by allocating fresh huge pages.
 	 *
-	 * We might race with alloc_buddy_huge_page() here and be unable
+	 * We might race with __alloc_buddy_huge_page() here and be unable
 	 * to convert a surplus huge page to a normal huge page. That is
 	 * not critical, though, it just means the overall size of the
 	 * pool might be one hugepage larger than it needs to be, but
@@ -2175,7 +2175,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * By placing pages into the surplus state independent of the
 	 * overcommit value, we are allowing the surplus pool size to
 	 * exceed overcommit. There are few sane options here. Since
-	 * alloc_buddy_huge_page() is checking the global counter,
+	 * __alloc_buddy_huge_page() is checking the global counter,
 	 * though, we'll note that we're not allowed to exceed surplus
 	 * and won't grow the pool anywhere else. Not until one of the
 	 * sysctls are changed, or the surplus pages go out of use.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
