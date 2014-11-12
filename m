Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 300CE6B00E3
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 17:33:49 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id q108so9639891qgd.35
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 14:33:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t102si28641465qgd.127.2014.11.12.14.33.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Nov 2014 14:33:47 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 2/3] hugetlb: alloc_bootmem_huge_page(): use IS_ALIGNED()
Date: Wed, 12 Nov 2014 17:33:12 -0500
Message-Id: <1415831593-9020-3-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com>
References: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, rientjes@google.com, riel@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, davidlohr@hp.com

No reason to duplicate the code of an existing macro.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---
 mm/hugetlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9fd7227..a10fd57 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1457,7 +1457,7 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
 	return 0;
 
 found:
-	BUG_ON((unsigned long)virt_to_phys(m) & (huge_page_size(h) - 1));
+	BUG_ON(!IS_ALIGNED(virt_to_phys(m), huge_page_size(h)));
 	/* Put them into a private list first because mem_map is not up yet */
 	list_add(&m->list, &huge_boot_pages);
 	m->hstate = h;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
