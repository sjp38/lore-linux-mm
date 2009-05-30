Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC376B00BB
	for <linux-mm@kvack.org>; Sat, 30 May 2009 06:45:19 -0400 (EDT)
Date: Sat, 30 May 2009 03:43:39 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530104339.GA6535@oblivion.subreption.com>
References: <20090522143914.2019dd47@lxorguk.ukuu.org.uk> <20090522180351.GC13971@oblivion.subreption.com> <20090522192158.28fe412e@lxorguk.ukuu.org.uk> <20090522234031.GH13971@oblivion.subreption.com> <20090523090910.3d6c2e85@lxorguk.ukuu.org.uk> <20090523085653.0ad217f8@infradead.org> <1243539361.6645.80.camel@laptop> <20090529073217.08eb20e1@infradead.org> <20090530054856.GG29711@oblivion.subreption.com> <1243679973.6645.131.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1243679973.6645.131.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On 12:39 Sat 30 May     , Peter Zijlstra wrote:
> > Because zero on allocate kills the very purpose of this patch and it has
> > obvious security implications. Like races (in information leak
> > scenarios, that is). What happens in-between the release of the page and
> > the new allocation that yields the same page? What happens if no further
> > allocations happen in a while (that can return the old page again)?
> > That's the idea.
> 
> I don't get it, these are in-kernel data leaks, you need to be able to
> run kernel code to exploit these, if someone can run kernel code, you've
> lost anyhow.
> 
> Why waste time on this?

If there were any hesitations about your lack of understanding in
security matters, you just cleared them all with the above statements.

> > > So if you zero on free, the next allocation will reuse the zeroed page.
> > > And due to LIFO that is not too far out "often", which makes it likely
> > > the page is still in L2 cache.
> > 
> > Thanks for pointing this out clearly, Arjan.
> 
> Thing is, the time between allocation and use is typically orders of
> magnitude less than between free and use. 
> 
> 
> Really, get a life, go fix real bugs. Don't make our kernel slower for
> wanking rights.

This is exactly the positive attitude, sound and mature response I was
expecting from you. Thank you.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
