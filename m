Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5TEDNP5131818
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 14:13:23 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5TEDNfj2072766
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:13:23 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5TEDMbm015989
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:13:23 +0200
Message-Id: <20070629135530.912094590@de.ibm.com>
Date: Fri, 29 Jun 2007 15:55:30 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 0/5] Various mm improvements.
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

While working on 1K/2K page tables for s390 I noticed room for
improvement in regard to some common mm code:
 - unnecessary tlb flushing in unmap_vmas
 - ptep_establish has fallen into disuse
 - ptep_test_and_clear_dirty / ptep_clear_flush_dirty are not used either
 - the definitions of mm_struct and vm_area_struct should be moved to
   mm_types.h
 - page_mkclean_one is giving false positives

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
