Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B44456B004A
	for <linux-mm@kvack.org>; Thu, 23 Sep 2010 12:21:27 -0400 (EDT)
Date: Thu, 23 Sep 2010 11:21:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 03/10] hugetlb: redefine hugepage copy functions
In-Reply-To: <1283908781-13810-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.00.1009231114030.32567@router.home>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283908781-13810-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Sep 2010, Naoya Horiguchi wrote:

> This patch modifies hugepage copy functions to have only destination
> and source hugepages as arguments for later use.
> The old ones are renamed from copy_{gigantic,huge}_page() to
> copy_user_{gigantic,huge}_page().
> This naming convention is consistent with that between copy_highpage()
> and copy_user_highpage().

Looking at copy_user_highpage(): The vma parameter does not seem to be
used anywhere anymore? The vaddr is used on arches that have virtual
caching.

Maybe removing the vma parameter would allow to simplify the hugetlb
code?

Reviewed-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
