Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1D49C6B01B7
	for <linux-mm@kvack.org>; Wed, 26 May 2010 05:45:04 -0400 (EDT)
Date: Wed, 26 May 2010 10:44:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
Message-ID: <20100526094442.GK29038@csn.ul.ie>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20100513152737.GE27949@csn.ul.ie> <20100514074641.GD10000@spritzerA.linux.bs1.fc.nec.co.jp> <20100514095449.GB21481@csn.ul.ie> <20100524071516.GC11008@spritzerA.linux.bs1.fc.nec.co.jp> <20100525105957.GD29038@csn.ul.ie> <20100526065156.GC7128@spritzerA.linux.bs1.fc.nec.co.jp> <20100526091958.GA24615@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100526091958.GA24615@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 11:19:58AM +0200, Andi Kleen wrote:
> 
> Mel, other than this nit are you happy with these changes now?
> 

Pretty much but I also want to test the series myself to be sure I haven't
missed something in review.

> > > It adds another header dependency which is bad but moving hugetlb stuff
> > > into mm.h seems bad too.
> > 
> > I have another choice to move the definition of is_vm_hugetlb_page() into
> > mm/hugetlb.c and introduce declaration of this function to pagemap.h,
> > but this needed a bit ugly #ifdefs and I didn't like it.
> > If putting hugetlb code in mm.h is worse, I'll take the second choice
> > in the next post.
> 
> You could always create a new include file hugetlb-inlines.h
> 

That would be another option. It'd need to be figured out what should
move from hugetlb.h to hugetlb-inlines.h in the future but ultimately it
would still be tidier than moving hugetlb stuff to mm.h (at least to
me).

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
