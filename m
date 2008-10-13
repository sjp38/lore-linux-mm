Date: Mon, 13 Oct 2008 14:36:08 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 1/1] hugetlbfs: handle pages higher order than MAX_ORDER
Message-ID: <20081013133608.GD15657@brain>
References: <1223458431-12640-1-git-send-email-apw@shadowen.org> <1223458431-12640-2-git-send-email-apw@shadowen.org> <200810082329.59561.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200810082329.59561.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 08, 2008 at 11:29:59PM +1100, Nick Piggin wrote:
> On Wednesday 08 October 2008 20:33, Andy Whitcroft wrote:
> > When working with hugepages, hugetlbfs assumes that those hugepages
> > are smaller than MAX_ORDER.  Specifically it assumes that the mem_map
> > is contigious and uses that to optimise access to the elements of the
> > mem_map that represent the hugepage.  Gigantic pages (such as 16GB pages
> > on powerpc) by definition are of greater order than MAX_ORDER (larger
> > than MAX_ORDER_NR_PAGES in size).  This means that we can no longer make
> > use of the buddy alloctor guarentees for the contiguity of the mem_map,
> > which ensures that the mem_map is at least contigious for maximmally
> > aligned areas of MAX_ORDER_NR_PAGES pages.
> >
> > This patch adds new mem_map accessors and iterator helpers which handle
> > any discontiguity at MAX_ORDER_NR_PAGES boundaries.  It then uses these
> > within copy_huge_page, clear_huge_page, and follow_hugetlb_page to allow
> > these to handle gigantic pages.
> >
> > Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> 
> Seems good to me... but do you have to add lots of stuff into the end of
> the for statements? Why not just at the end of the block?

Yes there is no particular requirement for it to be there.  In the latest
discussion patch (in separate email) is has the long ones moved out.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
