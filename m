Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7776B0088
	for <linux-mm@kvack.org>; Thu, 28 May 2009 03:02:41 -0400 (EDT)
Date: Thu, 28 May 2009 00:00:47 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090528070047.GC29711@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu> <20090522113809.GB13971@oblivion.subreption.com> <20090523124944.GA23042@elte.hu> <4A187BDE.5070601@redhat.com> <20090527223421.GA9503@elte.hu> <20090528072702.796622b6@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528072702.796622b6@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On 07:27 Thu 28 May     , Alan Cox wrote:
> > > As for being swapped out - I do not believe that kernel stacks can 
> > > ever be swapped out in Linux.
> > 
> > yes, i referred to that as an undesirable option - because it slows 
> > down pthread_create() quite substantially.
> > 
> > This needs before/after pthread_create() benchmark results.
> 
> kernel stacks can end up places you don't expect on hypervisor based
> systems.
> 
> In most respects the benchmarks are pretty irrelevant - wiping stuff has
> a performance cost, but its the sort of thing you only want to do when
> you have a security requirement that needs it. At that point the
> performance is secondary.
> 
> Alan

Right, besides I believe Ingo is confused about the nature of the patch.
It looks like he believes it's about userland memory sanitization, when
that isn't what is being done here.

If he still believe this has anything to do with it directly, or can
introduce a performance impact on pthread_create() (remember we are
sanitizing on release only...), I'll be pleased to provide benchmark
results that prove it wrong (or right, if it was the case).

Any existent benchmark tests available that I can modify to suit our
needs here, or I'll need to waste some time on writing them from scratch?

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
