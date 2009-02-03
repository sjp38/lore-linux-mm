Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6D9795F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 20:57:56 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator
Date: Tue, 3 Feb 2009 12:53:26 +1100
References: <20090114155923.GC1616@wotan.suse.de> <20090123155307.GB14517@wotan.suse.de> <alpine.DEB.1.10.0901261225240.1908@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0901261225240.1908@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902031253.28078.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 27 January 2009 04:28:03 Christoph Lameter wrote:
> n Fri, 23 Jan 2009, Nick Piggin wrote:
> > According to memory policies, a task's memory policy is supposed to
> > apply to its slab allocations too.
>
> It does apply to slab allocations. The question is whether it has to apply
> to every object allocation or to every page allocation of the slab
> allocators.

Quite obviously it should. Behaviour of a slab allocation on behalf of
some task constrained within a given node should not depend on the task
which has previously run on this CPU and made some allocations. Surely
you can see this behaviour is not nice.


> > > Memory policies are applied in a fuzzy way anyways. A context switch
> > > can result in page allocation action that changes the expected
> > > interleave pattern. Page populations in an address space depend on the
> > > task policy. So the exact policy applied to a page depends on the task.
> > > This isnt an exact thing.
> >
> > There are other memory policies than just interleave though.
>
> Which have similar issues since memory policy application is depending on
> a task policy and on memory migration that has been applied to an address
> range.

What similar issues? If a task ask to have slab allocations constrained
to node 0, then SLUB hands out objects from other nodes, then that's bad.


> > But that is wrong. The lists obviously have high water marks that
> > get trimmed down. Periodic trimming as I keep saying basically is
> > alrady so infrequent that it is irrelevant (millions of objects
> > per cpu can be allocated anyway between existing trimming interval)
>
> Trimming through water marks and allocating memory from the page allocator
> is going to be very frequent if you continually allocate on one processor
> and free on another.

Um yes, that's the point. But you previously claimed that it would just
grow unconstrained. Which is obviously wrong. So I don't understand what
your point is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
