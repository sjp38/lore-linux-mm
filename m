From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 1/1] hugetlbfs: handle pages higher order than MAX_ORDER
Date: Wed, 8 Oct 2008 23:29:59 +1100
References: <1223458431-12640-1-git-send-email-apw@shadowen.org> <1223458431-12640-2-git-send-email-apw@shadowen.org>
In-Reply-To: <1223458431-12640-2-git-send-email-apw@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810082329.59561.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wednesday 08 October 2008 20:33, Andy Whitcroft wrote:
> When working with hugepages, hugetlbfs assumes that those hugepages
> are smaller than MAX_ORDER.  Specifically it assumes that the mem_map
> is contigious and uses that to optimise access to the elements of the
> mem_map that represent the hugepage.  Gigantic pages (such as 16GB pages
> on powerpc) by definition are of greater order than MAX_ORDER (larger
> than MAX_ORDER_NR_PAGES in size).  This means that we can no longer make
> use of the buddy alloctor guarentees for the contiguity of the mem_map,
> which ensures that the mem_map is at least contigious for maximmally
> aligned areas of MAX_ORDER_NR_PAGES pages.
>
> This patch adds new mem_map accessors and iterator helpers which handle
> any discontiguity at MAX_ORDER_NR_PAGES boundaries.  It then uses these
> within copy_huge_page, clear_huge_page, and follow_hugetlb_page to allow
> these to handle gigantic pages.
>
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>

Seems good to me... but do you have to add lots of stuff into the end of
the for statements? Why not just at the end of the block?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
