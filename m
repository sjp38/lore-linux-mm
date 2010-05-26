Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9252F6B01BA
	for <linux-mm@kvack.org>; Wed, 26 May 2010 05:58:09 -0400 (EDT)
Date: Wed, 26 May 2010 11:58:05 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
Message-ID: <20100526095805.GB24615@basil.fritz.box>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20100513152737.GE27949@csn.ul.ie> <20100514074641.GD10000@spritzerA.linux.bs1.fc.nec.co.jp> <20100514095449.GB21481@csn.ul.ie> <20100524071516.GC11008@spritzerA.linux.bs1.fc.nec.co.jp> <20100525105957.GD29038@csn.ul.ie> <20100526065156.GC7128@spritzerA.linux.bs1.fc.nec.co.jp> <20100526091958.GA24615@basil.fritz.box> <20100526094442.GK29038@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526094442.GK29038@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andi Kleen <andi@firstfloor.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 10:44:43AM +0100, Mel Gorman wrote:
> On Wed, May 26, 2010 at 11:19:58AM +0200, Andi Kleen wrote:
> > 
> > Mel, other than this nit are you happy with these changes now?
> > 
> 
> Pretty much but I also want to test the series myself to be sure I haven't
> missed something in review.

Thanks. I'll wait a bit more and if there is no negative reviews
I'll start queueing it in the hwpoison tree.

I should add this is probably only the first step, "early kill" support
and soft offline might need some more mm changes.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
