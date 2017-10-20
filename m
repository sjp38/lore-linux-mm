Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 974D86B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 15:11:00 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q4so11924989oic.12
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 12:11:00 -0700 (PDT)
Received: from gateway34.websitewelcome.com (gateway34.websitewelcome.com. [192.185.148.194])
        by mx.google.com with ESMTPS id f128si508614oic.459.2017.10.20.12.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 12:10:59 -0700 (PDT)
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
	by gateway34.websitewelcome.com (Postfix) with ESMTP id A38AD2F1FAE
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 14:10:59 -0500 (CDT)
Date: Fri, 20 Oct 2017 14:10:58 -0500
From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] mm: shmem: mark expected switch fall-through
Message-ID: <20171020191058.GA24427@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Gustavo A. R. Silva" <garsilva@embeddedor.com>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 mm/shmem.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 9a981f0..fc6f3fd 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -4098,6 +4098,7 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
 			if (i_size >= HPAGE_PMD_SIZE &&
 					i_size >> PAGE_SHIFT >= off)
 				return true;
+			/* fall through */
 		case SHMEM_HUGE_ADVISE:
 			/* TODO: implement fadvise() hints */
 			return (vma->vm_flags & VM_HUGEPAGE);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
