Date: Thu, 15 Nov 2007 02:59:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix boot problem with iSeries lacking hugepage support
Message-Id: <20071115025940.ca1994a0.akpm@linux-foundation.org>
In-Reply-To: <20071115105237.GD5128@skynet.ie>
References: <20071115101322.GA5128@skynet.ie>
	<20071115023943.a54b0464.akpm@linux-foundation.org>
	<20071115105237.GD5128@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linuxppc-dev@ozlabs.org, sfr@canb.auug.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Nov 2007 10:52:38 +0000 mel@skynet.ie (Mel Gorman) wrote:

> > Shouldn't this have been HUGETLB_PAGE_ORDER?
> > 
> 
> As a #define, possibly but as a static inline - definitly not.
> 
> In this context, the define is not used because set_pageblock_order()
> is a no-op when CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is unset.
> pageblock_default_order() is only defined for symmetry as set_pageblock_order()
> is defined in both contexts. However, as a #define it might make more sense
> to a casual reader to see HUGETLB_PAGE_ORDER even if it has no effect. I
> can send a version of the patch that does this with a comment explaining
> what is going on with set_pageblock_order() if you like.
> 
> However, in a follow-up fix, you make pageblock_default_order() a static
> inline. If it tries to return HUGETLB_PAGE_ORDER, it will fail to compile
> when CONFIG_HUGETLB_PAGE is not set.
> 
> Which would you prefer?

Don't care really.  Something which is fixed up ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
