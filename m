Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6B0FA6B0078
	for <linux-mm@kvack.org>; Thu, 23 Sep 2010 12:02:17 -0400 (EDT)
Date: Thu, 23 Sep 2010 11:02:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/10] hugetlb: add allocate function for hugepage
 migration
In-Reply-To: <20100923084919.GA5185@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009231100440.32567@router.home>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-3-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.DEB.2.00.1009221558000.32661@router.home> <20100923084919.GA5185@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 23 Sep 2010, Mel Gorman wrote:

> Are you sure about this case? The virtual address of the page being migrated
> should not changed, only the physical address.

Right. I see that he just extracts a portion of the function. Semantics
of the alloc functions are indeed preserved.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
