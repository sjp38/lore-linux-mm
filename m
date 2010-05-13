Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7746B0236
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:14:21 -0400 (EDT)
Date: Thu, 13 May 2010 18:14:15 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
Message-ID: <20100513161415.GC28226@basil.fritz.box>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20100513152737.GE27949@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513152737.GE27949@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> I think what you're getting with this is the ability to unmap MAP_PRIVATE pages
> from one process but if there are multiple processes, the second process could
> still end up referencing the poisoned MAP_PRIVATE page. Is this accurate? Even
> if it is, I guess it's still an improvement over what currently happens.

The only real requirement is that all PTEs pointing to that page 
get replaced by poisoned PTEs.

(that's essentially always "late kill" mode)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
