Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DA0DF6B0251
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 12:02:31 -0400 (EDT)
Date: Tue, 6 Jul 2010 11:02:04 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 6/7] hugetlb: hugepage migration core
In-Reply-To: <20100706033342.GA10626@spritzera.linux.bs1.fc.nec.co.jp>
Message-ID: <alpine.DEB.2.00.1007061100530.4938@router.home>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com> <20100705095927.GC8510@basil.fritz.box> <20100706033342.GA10626@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Jul 2010, Naoya Horiguchi wrote:

> Hmm, this chunk need to be fixed because I had too specific assumption.
> The list passed to migrate_pages() has only one page or one hugepage in
> page migration kicked by soft offline, but it's not the case in general case.
> Since hugepage is not linked to LRU list, we had better simply skip
> putback_lru_pages().

Maybe write a migrate_huge_page() function instead? The functionality is
materially different since we are not juggling things with the lru.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
