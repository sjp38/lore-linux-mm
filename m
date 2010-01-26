Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C10626B009C
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 14:15:21 -0500 (EST)
Date: Tue, 26 Jan 2010 19:15:06 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 09 of 31] no paravirt version of pmd ops
Message-ID: <20100126191506.GN16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <3ab5d5b2bc21dbbdbf0a.1264513924@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <3ab5d5b2bc21dbbdbf0a.1264513924@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:52:04PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> No paravirt version of set_pmd_at/pmd_update/pmd_update_defer.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -33,6 +33,7 @@ extern struct list_head pgd_list;
>  #else  /* !CONFIG_PARAVIRT */
>  #define set_pte(ptep, pte)		native_set_pte(ptep, pte)
>  #define set_pte_at(mm, addr, ptep, pte)	native_set_pte_at(mm, addr, ptep, pte)
> +#define set_pmd_at(mm, addr, pmdp, pmd)	native_set_pmd_at(mm, addr, pmdp, pmd)
>  
>  #define set_pte_atomic(ptep, pte)					\
>  	native_set_pte_atomic(ptep, pte)
> @@ -57,6 +58,8 @@ extern struct list_head pgd_list;
>  
>  #define pte_update(mm, addr, ptep)              do { } while (0)
>  #define pte_update_defer(mm, addr, ptep)        do { } while (0)
> +#define pmd_update(mm, addr, ptep)              do { } while (0)
> +#define pmd_update_defer(mm, addr, ptep)        do { } while (0)
>  
>  #define pgd_val(x)	native_pgd_val(x)
>  #define __pgd(x)	native_make_pgd(x)
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
