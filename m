Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 16D2C6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 04:28:20 -0400 (EDT)
Date: Thu, 26 Aug 2010 17:25:22 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/8] hugetlb: rename hugepage allocation functions
Message-ID: <20100826082522.GW21389@spritzera.linux.bs1.fc.nec.co.jp>
References: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1282694127-14609-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100825012131.GC7283@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100825012131.GC7283@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 25, 2010 at 09:21:31AM +0800, Wu Fengguang wrote:
> On Wed, Aug 25, 2010 at 07:55:22AM +0800, Naoya Horiguchi wrote:
> > The function name alloc_huge_page_no_vma_node() has verbose suffix "_no_vma".
> > This patch makes existing alloc_huge_page() and it's family have "_vma" instead,
> > which makes it easier to read.
> > 
...
> > @@ -919,7 +919,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
> >  retry:
> >     spin_unlock(&hugetlb_lock);
> >     for (i = 0; i < needed; i++) {
> > -           page = alloc_buddy_huge_page(h, NULL, 0);
> > +           page = alloc_buddy_huge_page_vma(h, NULL, 0);
> 
> alloc_buddy_huge_page() doesn't make use of @vma at all, so the
> parameters can be removed.

OK.

> It looks cleaner to fold the
> alloc_huge_page_no_vma_node=>alloc_huge_page_node renames into the
> previous patch, from there split out the code refactor chunks into
> a standalone patch, and then include this cleanup patch.

When we unify alloc_buddy_huge_page() as commented for patch 2/8,
_vma suffix is not necessary any more. Your suggestion to drop
unused arguments sounds reasonable,
so I merge the attached patch into patch 2/8.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
