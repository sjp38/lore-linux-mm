Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 912EE6B004A
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 00:21:51 -0400 (EDT)
Date: Fri, 24 Sep 2010 12:24:15 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 03/10] hugetlb: redefine hugepage copy functions
Message-ID: <20100924032415.GA26639@spritzera.linux.bs1.fc.nec.co.jp>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1283908781-13810-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1009231114030.32567@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009231114030.32567@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 23, 2010 at 11:21:25AM -0500, Christoph Lameter wrote:
> On Wed, 8 Sep 2010, Naoya Horiguchi wrote:
> 
> > This patch modifies hugepage copy functions to have only destination
> > and source hugepages as arguments for later use.
> > The old ones are renamed from copy_{gigantic,huge}_page() to
> > copy_user_{gigantic,huge}_page().
> > This naming convention is consistent with that between copy_highpage()
> > and copy_user_highpage().
> 
> Looking at copy_user_highpage(): The vma parameter does not seem to be
> used anywhere anymore? The vaddr is used on arches that have virtual
> caching.
> 
> Maybe removing the vma parameter would allow to simplify the hugetlb
> code?

That's right.
I'll do this cleanup (although it may be aside from this patchset.)

> Reviewed-by: Christoph Lameter <cl@linux.com>

Thank you.

- Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
