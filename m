Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C132C6B01AE
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 01:19:29 -0400 (EDT)
Date: Wed, 24 Mar 2010 14:18:45 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] [BUGFIX] pagemap: fix pfn calculation for hugepage
Message-ID: <20100324051845.GA9017@spritzerA.linux.bs1.fc.nec.co.jp>
References: <1268979996-12297-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20100319161023.d6a4ea8d.kamezawa.hiroyu@jp.fujitsu.com> <20100319162732.58633847.kamezawa.hiroyu@jp.fujitsu.com> <20100319171310.7d82f8eb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100319171310.7d82f8eb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 19, 2010 at 05:13:10PM +0900, KAMEZAWA Hiroyuki wrote:
...
> > 
> > But, this means hugeltb_entry() is not called per hugetlb entry...isn't it ?
> > 
> > Why hugetlb_entry() cannot be called per hugeltb entry ? Don't we need a code
> > for a case as pmd_size != hugetlb_size in walk_page_range() for generic fix ?
> > 
> 
> How about this style ? This is an idea-level patch. not tested at all.
> (I have no test enviroment for multiple hugepage size.)
> 
> feel free to reuse fragments from this patch.
>

So the point is calling hugetlb_entry() for each huge page, right?

It looks good.
I've rewritten my patch based on your idea and make sure it works.
Is it ok to add your Signed-off-by?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
