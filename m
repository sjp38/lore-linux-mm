Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 875016B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 07:14:32 -0400 (EDT)
Date: Mon, 20 Sep 2010 12:14:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/10] Hugepage migration (v5)
Message-ID: <20100920111417.GK1998@csn.ul.ie>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <20100909123306.32134d5e@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100909123306.32134d5e@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 09, 2010 at 12:33:06PM +0200, Andi Kleen wrote:
> On Wed,  8 Sep 2010 10:19:31 +0900
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > Hi,
> > 
> > This is the 5th version of "hugepage migration" set.
> > 
> > Changes from v4 (mostly refactoring):
> > - remove unnecessary might_sleep() [3/10]
> > - define migrate_huge_pages() from copy of migrate_pages() [4/10]
> > - soft_offline_page() branches off to hugepage path. [8/10]
> 
> I went over this patchkit again and it all looks good to me.
> I plan to merge it through my hwpoison tree.
> 
> As far as I understand all earlier comments have been addressed
> with this revision, correct?
> 
> Thanks for your work, this is very good.
> 
> But I would like to have some Acks from Christoph for the
> page migration changes and from Mel for the hugetlb changes
> outside memory-failures.c. Are the patches ok for you two? 
> Can I have your Acked-by or Reviewed-by? 
> 

Sorry for taking so long to get back. I was snowed under by other work.
I've reviewed the bulk of the hugetlb changes that affect common paths.
There are a few small queries there but they are very minor. Once covered,
feel free to add by Acked-by. I didn't get the chance to actually test the
patches but they look ok.

> Any other comments would be welcome too.
> 
> I am considering to fast track 10/10 (the page-types fix). 
> 
> I think the other bug fixes in the series are only for bugs added
> earlier in the series, correct?
> 

That is what it looked like to me.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
