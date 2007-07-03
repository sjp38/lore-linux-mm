Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l63CADGD074732
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 12:10:13 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l63CACVf1777856
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 14:10:13 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l63CACMK019510
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 14:10:12 +0200
Message-Id: <20070703111822.418649776@de.ibm.com>
Date: Tue, 03 Jul 2007 13:18:22 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 0/5] some mm improvements + s390 tlb flush.
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, hugh@veritas.com, peterz@infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have updated my mm patch set. The diff:

 - The tlb gather restart patch has been changed as discussed with Hugh.
 - The ptep_establish patch now really removes all traces of the call.
 - The mm_struct / vm_area_struct move to mm_types.h has been test
   compiled on a number of architectures.
 - The page_mkclean_one patch has been dropped because it doesn't seem
   to have any effect.
 - There is a new patch to fix a theoretical architectural problem on
   s390. The patch is required for the 1K/2K page tables for KVM as well.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
