Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C904C6B0047
	for <linux-mm@kvack.org>; Thu, 23 Sep 2010 04:49:35 -0400 (EDT)
Date: Thu, 23 Sep 2010 09:49:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/10] hugetlb: add allocate function for hugepage
	migration
Message-ID: <20100923084919.GA5185@csn.ul.ie>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-3-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.DEB.2.00.1009221558000.32661@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009221558000.32661@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Sep 22, 2010 at 04:05:47PM -0500, Christoph Lameter wrote:
> On Wed, 8 Sep 2010, Naoya Horiguchi wrote:
> 
> > We can't use existing hugepage allocation functions to allocate hugepage
> > for page migration, because page migration can happen asynchronously with
> > the running processes and page migration users should call the allocation
> > function with physical addresses (not virtual addresses) as arguments.
> 
> Ummm... Some arches like IA64 need huge pages fixed at certain virtual
> addresses in which only huge pages exist. A vma is needed in order to be
> able to assign proper virtual address to the page.
> 

Are you sure about this case? The virtual address of the page being migrated
should not changed, only the physical address.

> How does that work with transparent huge pages anyways?
> 

IA-64 doesn't support transparent huge pages. Even if it did, this
change is about hugetlbfs, not transparent huge page support.

> This looks like its going to break IA64 hugepage support for good.

How?

> Maybe
> thats okay given the reduced significance of IA64? Certainly would
> simplify the code.
> 

Currently I'm not seeing how IA-64 gets broken.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
