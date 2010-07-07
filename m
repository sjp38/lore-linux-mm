Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 43D0A6B0246
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 02:46:44 -0400 (EDT)
Date: Wed, 7 Jul 2010 15:44:44 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 6/7] hugetlb: hugepage migration core
Message-ID: <20100707064444.GB21962@spritzera.linux.bs1.fc.nec.co.jp>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100705095927.GC8510@basil.fritz.box>
 <20100706033342.GA10626@spritzera.linux.bs1.fc.nec.co.jp>
 <alpine.DEB.2.00.1007061100530.4938@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007061100530.4938@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 06, 2010 at 11:02:04AM -0500, Christoph Lameter wrote:
> On Tue, 6 Jul 2010, Naoya Horiguchi wrote:
> 
> > Hmm, this chunk need to be fixed because I had too specific assumption.
> > The list passed to migrate_pages() has only one page or one hugepage in
> > page migration kicked by soft offline, but it's not the case in general case.
> > Since hugepage is not linked to LRU list, we had better simply skip
> > putback_lru_pages().
> 
> Maybe write a migrate_huge_page() function instead? The functionality is
> materially different since we are not juggling things with the lru.

OK. I'll try to devide functions for hugepage in the next turn.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
