Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA8776B01F2
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 22:41:35 -0400 (EDT)
Date: Tue, 17 Aug 2010 11:37:19 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/9] Hugepage migration (v2)
Message-ID: <20100817023719.GC12736@spritzera.linux.bs1.fc.nec.co.jp>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1008110806070.673@router.home>
 <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
 <alpine.DEB.2.00.1008130744550.27542@router.home>
 <20100816091935.GB3388@spritzera.linux.bs1.fc.nec.co.jp>
 <alpine.DEB.2.00.1008160707420.11420@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008160707420.11420@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 16, 2010 at 07:19:58AM -0500, Christoph Lameter wrote:
> On Mon, 16 Aug 2010, Naoya Horiguchi wrote:
> 
> > In my understanding, in current code "other processors increasing refcount
> > during migration" can happen both in non-hugepage direct I/O and in hugepage
> > direct I/O in the similar way (i.e. get_user_pages_fast() from dio_refill_pages()).
> > So I think there is no specific problem to hugepage.
> > Or am I missing your point?
> 
> With a single page there is the check of the refcount during migration
> after all the references have been removed (at that point the page is no
> longer mapped by any process and direct iO can no longer be
> initiated without a page fault.

The same checking mechanism works for hugeapge.

> 
> I see that you are running try_to_unmap() from unmap_and_move_huge_page().

Yes, that's right.

> 
> I dont see a patch adding huge page support to try_to_unmap though. How
> does this work?

I previously posted "hugetlb, rmap: add reverse mapping for hugepage" patch
which enables try_to_unmap() to work on hugepage by enabling to handle
anon_vma and mapcount for hugepage. For details refer to the following commit:

  commit 0fe6e20b9c4c53b3e97096ee73a0857f60aad43f
  Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
  Date:   Fri May 28 09:29:16 2010 +0900
  hugetlb, rmap: add reverse mapping for hugepage

(Current "Hugepage migration" patchset is based on 2.6.35-rc3.
So I'll rebase it onto the latest release in the next post.)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
