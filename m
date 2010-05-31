Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0283B6B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 05:30:13 -0400 (EDT)
Date: Mon, 31 May 2010 11:30:09 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/8] HWPOISON for hugepage (v6)
Message-ID: <20100531093009.GA10766@basil.fritz.box>
References: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 2010 at 09:29:14AM +0900, Naoya Horiguchi wrote:
> Hi,
> 
> Here is a "HWPOISON for hugepage" patchset which reflects
> Mel's comments on hugepage rmapping code.
> Only patch 1/8 and 2/8 are changed since the previous post.
> 
> Mel, could you please restart reviewing and testing?

Thanks everyone, I merged this patch series in the hwpoison
tree now, aimed for 2.6.36. It should appear in linux-next
shortly.

Question is how to proceed now: the next steps would
be early kill support and soft offline/migration support for
hugetlb too. Horiguchi-san, is this something you're interested
in working on?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
