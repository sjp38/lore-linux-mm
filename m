Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id BA4FE6B005C
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:47:58 -0500 (EST)
Date: Wed, 21 Dec 2011 07:47:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: +
 mm-hugetlb-fix-pgoff-computation-when-unmapping-page-from-vma-fix.patch
 added to -mm tree
Message-ID: <20111221064750.GA27137@tiehlicka.suse.cz>
References: <20111220231716.94B8D5C0050@hpza9.eem.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111220231716.94B8D5C0050@hpza9.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, aarcange@redhat.com, dhillf@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, linux-mm@kvack.org

On Tue 20-12-11 15:17:15, Andrew Morton wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-hugetlb-fix-pgoff-computation-when-unmapping-page-from-vma-fix
> 
> use vma_hugecache_offset() directly, per Michal
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Hillf Danton <dhillf@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/hugetlb.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN mm/hugetlb.c~mm-hugetlb-fix-pgoff-computation-when-unmapping-page-from-vma-fix mm/hugetlb.c
> --- a/mm/hugetlb.c~mm-hugetlb-fix-pgoff-computation-when-unmapping-page-from-vma-fix
> +++ a/mm/hugetlb.c
> @@ -2315,7 +2315,7 @@ static int unmap_ref_private(struct mm_s
>  	 * from page cache lookup which is in HPAGE_SIZE units.
>  	 */
>  	address = address & huge_page_mask(h);
> -	pgoff = linear_hugepage_index(vma, address);
> +	pgoff = vma_hugecache_offset(hstate, vma, address);

You wanted
+	pgoff = vma_hugecache_offset(h, vma, address);

right?

>  	mapping = (struct address_space *)page_private(page);
>  
>  	/*
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
