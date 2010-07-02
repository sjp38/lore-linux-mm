Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7DACC6B01B6
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 04:31:47 -0400 (EDT)
Date: Fri, 2 Jul 2010 10:31:43 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/7] hugetlb: add missing unlock in avoidcopy path in
 hugetlb_cow()
Message-ID: <20100702083143.GC12221@basil.fritz.box>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278049646-29769-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 02:47:20PM +0900, Naoya Horiguchi wrote:
> This patch fixes possible deadlock in hugepage lock_page()
> by adding missing unlock_page().
> 
> libhugetlbfs test will hit this bug when the next patch in this
> patchset ("hugetlb, HWPOISON: move PG_HWPoison bit check") is applied.

This looks like a general bug fix that should be merged ASAP? 

Or do you think this cannot be hit at all without the other patches?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
