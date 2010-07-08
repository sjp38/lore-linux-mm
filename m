Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 35FF46B006A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 02:59:12 -0400 (EDT)
Date: Thu, 8 Jul 2010 08:49:51 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 6/7] hugetlb: hugepage migration core
Message-ID: <20100708064951.GA15950@basil.fritz.box>
References: <20100707092719.GA3900@basil.fritz.box>
 <20100708054426.GA19906@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100708054426.GA19906@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> This page cache is located on non-hugepage, isn't it?

Yes.

> If so, buffered IO is handled in the same manner as done for non-hugepage.
> I think "hugepage under IO" is realized only in direct IO for now.
> 
> Direct IO is issued in page unit even if the target page is in hugepage,
> so locking each subpages separately looks natural for me than auditing
> head page.

Ok. Would need to make sure lock ordering is correctly handled all the time.

If there's any code that locks multiple pages "backwards" and the migration
code locks it forward there might be a problem. Maybe it's not a problem
though.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
