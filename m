Date: Fri, 15 Aug 2008 19:19:13 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pthread_create() slow for many threads; also time to revisit
	64b context switch optimization?
Message-ID: <20080815171913.GB23600@elte.hu>
References: <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <48A2FC17.9070302@redhat.com> <20080813154043.GA11886@elte.hu> <48A303EE.8070002@redhat.com> <20080813160218.GB18037@elte.hu> <20080815155457.GA5210@shareable.org> <48A5B943.1010607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48A5B943.1010607@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@gmail.com>
Cc: Jamie Lokier <jamie@shareable.org>, Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Ulrich Drepper <drepper@gmail.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Jamie Lokier wrote:
> > Suggest:
> > 
> > +#define MAP_STACK       0x20000         /* 31bit or 64bit address for stack, */
> > +                                        /* whichever is faster on this CPU */
> 
> I agree.  Except for the comment.
> 
> 
> > Also, is this _only_ useful for thread stacks, or are there other
> > memory allocations where 31-bitness affects execution speed on old P4s?
> 
> Actually, I would define the flag as "do whatever is best assuming the
> allocation is used for stacks".
> 
> For instance, minimally the /proc/*/maps output could show "[user
> stack]" or something like this.  For security, perhaps, setting of
> PROC_EXEC can be prevented.

makes sense. Updated patch below. I've also added your Acked-by. Queued 
it up in tip/x86/urgent, for v2.6.27 merging.

( also, just to make sure: all Linux kernel versions will ignore such 
  extra flags, so you can just update glibc to use this flag 
  unconditionally, correct? )

	Ingo

--------------------------->
