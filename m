Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l117H4qx6815804
	for <linux-mm@kvack.org>; Thu, 1 Feb 2007 06:17:05 -0100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0VJIbdm238488
	for <linux-mm@kvack.org>; Thu, 1 Feb 2007 06:18:37 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0VJF7NV007634
	for <linux-mm@kvack.org>; Thu, 1 Feb 2007 06:15:07 +1100
Message-ID: <45C0EAB7.5040903@in.ibm.com>
Date: Thu, 01 Feb 2007 00:45:03 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] not to disturb page LRU state when unmapping memory range
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com> <1170246396.9516.39.camel@twins>
In-Reply-To: <1170246396.9516.39.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ken Chen <kenchen@google.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
[snip]

> It preserves the information, but not more.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
> diff --git a/mm/memory.c b/mm/memory.c
> index ef09f0a..b1f9129 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -678,7 +678,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  				if (pte_dirty(ptent))
>  					set_page_dirty(page);
>  				if (pte_young(ptent))
> -					mark_page_accessed(page);
> +					SetPageReferenced(page);
>  				file_rss--;
>  			}
>  			page_remove_rmap(page, vma);

Does it make sense to do this only for shared mapped pages?

if (pte_young(ptent) && (page_mapcount(page) > 1))
	SetPageReferenced(page);


	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
