Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C13EA6B0093
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 17:05:52 -0400 (EDT)
Date: Wed, 22 Sep 2010 16:05:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/10] hugetlb: add allocate function for hugepage
 migration
In-Reply-To: <1283908781-13810-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.00.1009221558000.32661@router.home>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 8 Sep 2010, Naoya Horiguchi wrote:

> We can't use existing hugepage allocation functions to allocate hugepage
> for page migration, because page migration can happen asynchronously with
> the running processes and page migration users should call the allocation
> function with physical addresses (not virtual addresses) as arguments.

Ummm... Some arches like IA64 need huge pages fixed at certain virtual
addresses in which only huge pages exist. A vma is needed in order to be
able to assign proper virtual address to the page.

How does that work with transparent huge pages anyways?

This looks like its going to break IA64 hugepage support for good. Maybe
thats okay given the reduced significance of IA64? Certainly would
simplify the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
