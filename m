Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8D7826B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 08:20:03 -0400 (EDT)
Date: Mon, 16 Aug 2010 07:19:58 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 0/9] Hugepage migration (v2)
In-Reply-To: <20100816091935.GB3388@spritzera.linux.bs1.fc.nec.co.jp>
Message-ID: <alpine.DEB.2.00.1008160707420.11420@router.home>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.DEB.2.00.1008110806070.673@router.home> <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp> <alpine.DEB.2.00.1008130744550.27542@router.home>
 <20100816091935.GB3388@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 2010, Naoya Horiguchi wrote:

> In my understanding, in current code "other processors increasing refcount
> during migration" can happen both in non-hugepage direct I/O and in hugepage
> direct I/O in the similar way (i.e. get_user_pages_fast() from dio_refill_pages()).
> So I think there is no specific problem to hugepage.
> Or am I missing your point?

With a single page there is the check of the refcount during migration
after all the references have been removed (at that point the page is no
longer mapped by any process and direct iO can no longer be
initiated without a page fault.

I see that you are running try_to_unmap() from unmap_and_move_huge_page().

I dont see a patch adding huge page support to try_to_unmap though. How
does this work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
