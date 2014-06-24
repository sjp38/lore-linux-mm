Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 35FF96B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 01:50:25 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id rr13so6777746pbb.4
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 22:50:24 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id qm6si24827914pac.8.2014.06.23.22.50.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 22:50:24 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so6832453pad.0
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 22:50:23 -0700 (PDT)
Message-ID: <53A9116B.9030004@gmail.com>
Date: Tue, 24 Jun 2014 13:49:31 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: update the description for madvise_remove
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <ak@linux.intel.com>, Vladimir Cernov <gg.kaspersky@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Currently, we have more filesystems supporting fallocate, e.g
ext4/btrfs. Remove the outdated comment for madvise_remove.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/madvise.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index a402f8f..0938b30 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -292,9 +292,6 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 /*
  * Application wants to free up the pages and associated backing store.
  * This is effectively punching a hole into the middle of a file.
- *
- * NOTE: Currently, only shmfs/tmpfs is supported for this operation.
- * Other filesystems return -ENOSYS.
  */
 static long madvise_remove(struct vm_area_struct *vma,
                                struct vm_area_struct **prev,
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
