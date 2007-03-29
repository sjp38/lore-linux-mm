Message-ID: <460B29F6.8070405@yahoo.com.au>
Date: Thu, 29 Mar 2007 12:52:38 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] "Convert" hugetlbfs to use vm_ops->fault()
References: <20070328202713.4864.71864.stgit@localhost.localdomain>
In-Reply-To: <20070328202713.4864.71864.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
> Hi Andrew, I discovered that 2.6.21-rc5-mm1 was oopsing my box when running
> the libhugetlbfs test suite.  The trouble led me once again to shm stacked
> files ;-)  The stacked mmap function is labeling the lack of a ->fault()
> vm_op a BUG() which is probably a good idea.  It isn't really a problem for
> hugetlbfs though, since our faults are handled by an explicit hook in
> __handle_mm_fault().  Rather than removing the BUG(), just convert the
> hugetlbfs ->nopage() placeholder to a ->fault() one which helps us get one
> step closer to removing the nopage vm_op anyway.

Thanks Adam. I thought I'd done hugetlb... oh well.

> 
> Signed-off-by: Adam Litke <agl@us.ibm.com>

Acked-by: Nick Piggin <npiggin@suse.de>


-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
