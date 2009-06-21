Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C3A866B0055
	for <linux-mm@kvack.org>; Sun, 21 Jun 2009 04:47:11 -0400 (EDT)
Date: Sun, 21 Jun 2009 10:57:21 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 11/15] HWPOISON: The high level memory error handler in the VM v8
Message-ID: <20090621085721.GD8218@one.firstfloor.org>
References: <20090620031608.624240019@intel.com> <20090620031626.106150781@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090620031626.106150781@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, hugh.dickins@tiscali.co.uk, npiggin@suse.de, chris.mason@oracle.com, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> v8:
> check for page_mapped_in_vma() on anon pages (Hugh, Fengguang)

This change was no good as discussed earlier.

> test and use page->mapping instead of page_mapping() (Fengguang)
> cleanup some early kill comments (Fengguang)

This stuff belongs into the manpage. I haven't written it yet,
but will. I don't think kernel source comments is the right place.

> introduce invalidate_inode_page() and don't remove dirty/writeback pages
> from page cache (Nick, Fengguang)

I'm still dubious this is a good idea, it means potentially a lot 
of pages not covered.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
