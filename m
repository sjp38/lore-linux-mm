Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DB01A6B01B5
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 05:08:57 -0400 (EDT)
Date: Fri, 2 Jul 2010 11:08:54 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/7] hugetlb: add allocate function for hugepage
 migration
Message-ID: <20100702090854.GD12221@basil.fritz.box>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278049646-29769-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 02:47:22PM +0900, Naoya Horiguchi wrote:
> We can't use existing hugepage allocation functions to allocate hugepage
> for page migration, because page migration can happen asynchronously with
> the running processes and page migration users should call the allocation
> function with physical addresses (not virtual addresses) as arguments.

I looked through this patch and didn't see anything bad. Some more
eyes familiar with hugepages would be good though.

Since there are now so many different allocation functions some
comments on when they should be used may be useful too

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
