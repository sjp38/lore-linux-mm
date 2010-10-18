Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 71D096B00DA
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 17:56:17 -0400 (EDT)
Date: Mon, 18 Oct 2010 23:55:44 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
In-Reply-To: <20101018123750.ef7d6d48.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1010182342490.6815@localhost6.localdomain6>
References: <20101013144044.GS30667@csn.ul.ie> <20101013175205.21187.qmail@kosh.dhis.org> <20101018113331.GB30667@csn.ul.ie> <20101018123750.ef7d6d48.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, pacman@kosh.dhis.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, Helmut Grohne <helmut@subdivi.de>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Oct 2010, Andrew Morton wrote:

> On Mon, 18 Oct 2010 12:33:31 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > A bit but I still don't know why it would cause corruption. Maybe this is still
> > a caching issue but the difference in timing between list_add and list_add_tail
> > is enough to hide the bug. It's also possible there are some registers
> > ioremapped after the memmap array and reading them is causing some
> > problem.
> > 
> > Andrew, what is the right thing to do here? We could flail around looking
> > for explanations as to why the bug causes a user buffer corruption but never
> > get an answer or do we go with this patch, preferably before 2.6.36 releases?
> 
> Well, you've spotted a bug so I'd say we fix it asap.
> 
> It's a bit of a shame that we lose the only known way of reproducing a
> different bug, but presumably that will come back and bite someone else
> one day, and we'll fix it then :(

I might be completely one off as usual, but this thing reminds me of a
bug I stared at yesterday night:

    http://permalink.gmane.org/gmane.linux.kernel/1049605

Reporter Cc'ed

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
