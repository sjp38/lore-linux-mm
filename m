Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id EF2516B0253
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 20:24:29 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id x125so2786580pfb.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 17:24:29 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id ll4si5498538pab.207.2016.01.26.17.24.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 17:24:29 -0800 (PST)
Received: by mail-pa0-x242.google.com with SMTP id pv5so8523996pac.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 17:24:29 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm/madvise: update comment on sys_madvise()
Date: Wed, 27 Jan 2016 10:24:25 +0900
Message-Id: <1453857865-13650-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jason Baron <jbaron@redhat.com>, Chen Gong <gong.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Some new MADV_* advices are not documented in sys_madvise() comment.
So let's update it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/madvise.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git v4.4-mmotm-2016-01-20-16-10/mm/madvise.c v4.4-mmotm-2016-01-20-16-10_patched/mm/madvise.c
index 6a77114..c897b15 100644
--- v4.4-mmotm-2016-01-20-16-10/mm/madvise.c
+++ v4.4-mmotm-2016-01-20-16-10_patched/mm/madvise.c
@@ -639,14 +639,26 @@ madvise_behavior_valid(int behavior)
  *		some pages ahead.
  *  MADV_DONTNEED - the application is finished with the given range,
  *		so the kernel can free resources associated with it.
+ *  MADV_FREE - the application marks pages in the given range as lasyfree,
+ *		where actual purges are postponed until memory pressure happens.
  *  MADV_REMOVE - the application wants to free up the given range of
  *		pages and associated backing store.
  *  MADV_DONTFORK - omit this area from child's address space when forking:
  *		typically, to avoid COWing pages pinned by get_user_pages().
  *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
+ *  MADV_HWPOISON - trigger memory error handler as if the given memory range
+ *		were corrupted by unrecoverable hardware memory failure.
+ *  MADV_SOFT_OFFLINE - try to soft-offline the given range of memory.
  *  MADV_MERGEABLE - the application recommends that KSM try to merge pages in
  *		this area with pages of identical content from other such areas.
  *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages with others.
+ *  MADV_HUGEPAGE - the application wants to allocate transparent hugepages to
+ *		load the content of the given memory range.
+ *  MADV_NOHUGEPAGE - cancel MADV_HUGEPAGE: no longer allocate transparent
+ *		hugepages.
+ *  MADV_DONTDUMP - the application wants to prevent pages in the given range
+ *		from being included in its core dump.
+ *  MADV_DODUMP - cancel MADV_DONTDUMP: no longer exclude from core dump.
  *
  * return values:
  *  zero    - success
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
