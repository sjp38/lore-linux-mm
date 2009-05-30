Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 795F26B00BA
	for <linux-mm@kvack.org>; Sat, 30 May 2009 06:39:07 -0400 (EDT)
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090530054856.GG29711@oblivion.subreption.com>
References: <20090522073436.GA3612@elte.hu>
	 <20090522113809.GB13971@oblivion.subreption.com>
	 <20090522143914.2019dd47@lxorguk.ukuu.org.uk>
	 <20090522180351.GC13971@oblivion.subreption.com>
	 <20090522192158.28fe412e@lxorguk.ukuu.org.uk>
	 <20090522234031.GH13971@oblivion.subreption.com>
	 <20090523090910.3d6c2e85@lxorguk.ukuu.org.uk>
	 <20090523085653.0ad217f8@infradead.org> <1243539361.6645.80.camel@laptop>
	 <20090529073217.08eb20e1@infradead.org>
	 <20090530054856.GG29711@oblivion.subreption.com>
Content-Type: text/plain
Date: Sat, 30 May 2009 12:39:33 +0200
Message-Id: <1243679973.6645.131.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Fri, 2009-05-29 at 22:48 -0700, Larry H. wrote:
> On 07:32 Fri 29 May     , Arjan van de Ven wrote:
> > On Thu, 28 May 2009 21:36:01 +0200
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > > ... and if we zero on free, we don't need to zero on allocate.
> > > > While this is a little controversial, it does mean that at least
> > > > part of the cost is just time-shifted, which means it'll not be TOO
> > > > bad hopefully...
> > > 
> > > zero on allocate has the advantage of cache hotness, we're going to
> > > use the memory, why else allocate it.
> 
> Because zero on allocate kills the very purpose of this patch and it has
> obvious security implications. Like races (in information leak
> scenarios, that is). What happens in-between the release of the page and
> the new allocation that yields the same page? What happens if no further
> allocations happen in a while (that can return the old page again)?
> That's the idea.

I don't get it, these are in-kernel data leaks, you need to be able to
run kernel code to exploit these, if someone can run kernel code, you've
lost anyhow.

Why waste time on this?

> > So if you zero on free, the next allocation will reuse the zeroed page.
> > And due to LIFO that is not too far out "often", which makes it likely
> > the page is still in L2 cache.
> 
> Thanks for pointing this out clearly, Arjan.

Thing is, the time between allocation and use is typically orders of
magnitude less than between free and use. 


Really, get a life, go fix real bugs. Don't make our kernel slower for
wanking rights.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
