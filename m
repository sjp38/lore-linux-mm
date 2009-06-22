Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B5F9C6B0055
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 05:36:44 -0400 (EDT)
Date: Mon, 22 Jun 2009 17:37:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 11/15] HWPOISON: The high level memory error handler in
	the VM v8
Message-ID: <20090622093725.GB11541@localhost>
References: <20090620031608.624240019@intel.com> <20090620031626.106150781@intel.com> <20090621085721.GD8218@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090621085721.GD8218@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "npiggin@suse.de" <npiggin@suse.de>, "chris.mason@oracle.com" <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 21, 2009 at 04:57:21PM +0800, Andi Kleen wrote:
> > v8:
> > check for page_mapped_in_vma() on anon pages (Hugh, Fengguang)
> 
> This change was no good as discussed earlier.

My understanding is, we don't do page_mapped_in_vma() for file pages.
But for anon pages, this check can avoid killing possibly good tasks.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
