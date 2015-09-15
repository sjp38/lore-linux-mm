Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f54.google.com (mail-vk0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7816B025D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:09:07 -0400 (EDT)
Received: by vkhf67 with SMTP id f67so80435639vkh.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:09:07 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id w3si12522723laj.40.2015.09.15.07.09.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:09:06 -0700 (PDT)
Received: by lanb10 with SMTP id b10so107796999lan.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:09:06 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 06/10] mm/util: Use offset_in_page macro
Date: Tue, 15 Sep 2015 20:08:11 +0600
Message-Id: <1442326091-7438-1-git-send-email-kuleshovmail@gmail.com>
In-Reply-To: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
References: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

The <linux/mm.h> provides offset_in_page() macro. Let's use already
predefined macro instead of (addr & ~PAGE_MASK).

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/util.c b/mm/util.c
index 68ff8a5..9af1c12 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -309,7 +309,7 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 {
 	if (unlikely(offset + PAGE_ALIGN(len) < offset))
 		return -EINVAL;
-	if (unlikely(offset & ~PAGE_MASK))
+	if (unlikely(offset_in_page(offset)))
 		return -EINVAL;
 
 	return vm_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
