Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C15556B005C
	for <linux-mm@kvack.org>; Thu, 28 May 2009 05:08:43 -0400 (EDT)
Date: Thu, 28 May 2009 11:08:36 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090528090836.GB6715@elte.hu>
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu> <20090522113809.GB13971@oblivion.subreption.com> <20090523124944.GA23042@elte.hu> <4A187BDE.5070601@redhat.com> <20090527223421.GA9503@elte.hu> <20090528072702.796622b6@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528072702.796622b6@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@redhat.com>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > > As for being swapped out - I do not believe that kernel stacks can 
> > > ever be swapped out in Linux.
> > 
> > yes, i referred to that as an undesirable option - because it slows 
> > down pthread_create() quite substantially.
> > 
> > This needs before/after pthread_create() benchmark results.
> 
> kernel stacks can end up places you don't expect on hypervisor 
> based systems.
> 
> In most respects the benchmarks are pretty irrelevant - wiping 
> stuff has a performance cost, but its the sort of thing you only 
> want to do when you have a security requirement that needs it. At 
> that point the performance is secondary.

Bechmarks, of course, are not irrelevant _at all_.

So i'm asking for this "clear kernel stacks on freeing" aspect to be 
benchmarked thoroughly, as i expect it to have a negative impact - 
otherwise i'm NAK-ing this. Please Cc: me to measurements results.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
