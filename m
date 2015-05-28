Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 432BA6B0073
	for <linux-mm@kvack.org>; Thu, 28 May 2015 07:58:29 -0400 (EDT)
Received: by wifw1 with SMTP id w1so58987955wif.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 04:58:28 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id ib4si3519114wjb.47.2015.05.28.04.52.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 28 May 2015 04:53:25 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Thu, 28 May 2015 12:52:56 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3A2A1219005E
	for <linux-mm@kvack.org>; Thu, 28 May 2015 12:52:34 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4SBqs1b23789586
	for <linux-mm@kvack.org>; Thu, 28 May 2015 11:52:54 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4SBqle1008642
	for <linux-mm@kvack.org>; Thu, 28 May 2015 05:52:53 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 2/5] mm/hugetlb: remove unused arch hook prepare/release_hugepage
Date: Thu, 28 May 2015 13:52:34 +0200
Message-Id: <1432813957-46874-3-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@ezchip.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nathan Lynch <nathan_lynch@mentor.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andy Lutomirski <luto@amacapital.net>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Paolo Bonzini <pbonzini@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

With s390 dropping support for emulated hugepages, the last user of
arch_prepare_hugepage and arch_release_hugepage is gone.

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 290984b..a97958e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -917,7 +917,6 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 		destroy_compound_gigantic_page(page, huge_page_order(h));
 		free_gigantic_page(page, huge_page_order(h));
 	} else {
-		arch_release_hugepage(page);
 		__free_pages(page, huge_page_order(h));
 	}
 }
@@ -1102,10 +1101,6 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 						__GFP_REPEAT|__GFP_NOWARN,
 		huge_page_order(h));
 	if (page) {
-		if (arch_prepare_hugepage(page)) {
-			__free_pages(page, huge_page_order(h));
-			return NULL;
-		}
 		prep_new_huge_page(h, page, nid);
 	}
 
@@ -1257,11 +1252,6 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 			htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
 			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
 
-	if (page && arch_prepare_hugepage(page)) {
-		__free_pages(page, huge_page_order(h));
-		page = NULL;
-	}
-
 	spin_lock(&hugetlb_lock);
 	if (page) {
 		INIT_LIST_HEAD(&page->lru);
-- 
2.3.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
