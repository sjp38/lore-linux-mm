Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m75Fhj6K028548
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 11:43:45 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m75FhZhw210306
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 11:43:35 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m75FhZFv026914
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 11:43:35 -0400
Subject: Re: [PATCH] hugetlb: call arch_prepare_hugepage() for surplus pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1217950147.5032.15.camel@localhost.localdomain>
References: <1217950147.5032.15.camel@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 05 Aug 2008 10:43:34 -0500
Message-Id: <1217951014.13182.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-05 at 17:29 +0200, Gerald Schaefer wrote:
> From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> 
> The s390 software large page emulation implements shared page tables
> by using page->index of the first tail page from a compound large page
> to store page table information. This is set up in arch_prepare_hugepage(),
> which is called from alloc_fresh_huge_page_node().
> 
> A similar call to arch_prepare_hugepage() is missing for surplus large
> pages that are allocated in alloc_buddy_huge_page(), which breaks the
> software emulation mode for (surplus) large pages on s390. This patch
> adds the missing call to arch_prepare_hugepage(). It will have no effect
> on other architectures where arch_prepare_hugepage() is a nop.
> 
> Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

Seems fine.

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
