Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B603A6B01C3
	for <linux-mm@kvack.org>; Mon, 31 May 2010 06:18:52 -0400 (EDT)
Date: Mon, 31 May 2010 19:17:46 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/8] HWPOISON for hugepage (v6)
Message-ID: <20100531101746.GB5370@spritzera.linux.bs1.fc.nec.co.jp>
References: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100531093009.GA10766@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100531093009.GA10766@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, May 31, 2010 at 11:30:09AM +0200, Andi Kleen wrote:
> On Fri, May 28, 2010 at 09:29:14AM +0900, Naoya Horiguchi wrote:
> > Hi,
> > 
> > Here is a "HWPOISON for hugepage" patchset which reflects
> > Mel's comments on hugepage rmapping code.
> > Only patch 1/8 and 2/8 are changed since the previous post.
> > 
> > Mel, could you please restart reviewing and testing?
> 
> Thanks everyone, I merged this patch series in the hwpoison
> tree now, aimed for 2.6.36. It should appear in linux-next
> shortly.

Thank you.

> Question is how to proceed now: the next steps would
> be early kill support

Does early kill for hugetlb work with this patchset, doesn't it?
Do you mean something else?

> and soft offline/migration support for
> hugetlb too. Horiguchi-san, is this something you're interested
> in working on?

Yes, it is.
I'll do it with pleasure :)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
