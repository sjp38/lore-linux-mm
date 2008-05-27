Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RJvFOg009084
	for <linux-mm@kvack.org>; Tue, 27 May 2008 15:57:15 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RJt1xk162356
	for <linux-mm@kvack.org>; Tue, 27 May 2008 15:55:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RJt0nP014939
	for <linux-mm@kvack.org>; Tue, 27 May 2008 15:55:01 -0400
Subject: Re: [patch 01/23] hugetlb: fix lockdep error
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143452.193337000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143452.193337000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 19:55:00 +0000
Message-Id: <1211918100.12036.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> plain text document attachment (hugetlb-copy-lockdep.patch)
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Adam Litke <agl@us.ibm.com>

> ---
>  mm/hugetlb.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -785,7 +785,7 @@ int copy_hugetlb_page_range(struct mm_st
>  			continue;
> 
>  		spin_lock(&dst->page_table_lock);
> -		spin_lock(&src->page_table_lock);
> +		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
>  		if (!huge_pte_none(huge_ptep_get(src_pte))) {
>  			if (cow)
>  				huge_ptep_set_wrprotect(src, addr, src_pte);
> 
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
