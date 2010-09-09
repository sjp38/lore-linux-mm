Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 168696B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 06:33:12 -0400 (EDT)
Date: Thu, 9 Sep 2010 12:33:06 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/10] Hugepage migration (v5)
Message-ID: <20100909123306.32134d5e@basil.nowhere.org>
In-Reply-To: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed,  8 Sep 2010 10:19:31 +0900
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Hi,
> 
> This is the 5th version of "hugepage migration" set.
> 
> Changes from v4 (mostly refactoring):
> - remove unnecessary might_sleep() [3/10]
> - define migrate_huge_pages() from copy of migrate_pages() [4/10]
> - soft_offline_page() branches off to hugepage path. [8/10]

I went over this patchkit again and it all looks good to me.
I plan to merge it through my hwpoison tree.

As far as I understand all earlier comments have been addressed
with this revision, correct?

Thanks for your work, this is very good.

But I would like to have some Acks from Christoph for the
page migration changes and from Mel for the hugetlb changes
outside memory-failures.c. Are the patches ok for you two? 
Can I have your Acked-by or Reviewed-by? 

Any other comments would be welcome too.

I am considering to fast track 10/10 (the page-types fix). 

I think the other bug fixes in the series are only for bugs added
earlier in the series, correct?

Thanks,
-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
