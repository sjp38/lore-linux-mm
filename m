Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 181A66B0236
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 13:54:20 -0400 (EDT)
Date: Fri, 26 Mar 2010 18:54:06 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 37 of 41] add x86 32bit support
Message-ID: <20100326175406.GA28898@cmpxchg.org>
References: <patchbomb.1269622804@v2.random> <2a644b64b34162f323c5.1269622841@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2a644b64b34162f323c5.1269622841@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 06:00:41PM +0100, Andrea Arcangeli wrote:
> diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
> --- a/arch/x86/include/asm/pgtable-3level.h
> +++ b/arch/x86/include/asm/pgtable-3level.h
> @@ -104,6 +104,29 @@ static inline pte_t native_ptep_get_and_
>  #define native_ptep_get_and_clear(xp) native_local_ptep_get_and_clear(xp)
>  #endif
>  
> +#ifdef CONFIG_SMP
> +union split_pmd {
> +	struct {
> +		u32 pmd_low;
> +		u32 pmd_high;
> +	};
> +	pmd_t pmd;
> +};
> +static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
> +{
> +	union split_pmd res, *orig = (union pmd_parts *)pmdp;

Oh, shoot, the cast needs to be renamed to (union split_pmd *) as well.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
