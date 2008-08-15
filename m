Date: Fri, 15 Aug 2008 18:03:38 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pthread_create() slow for many threads; also time to revisit
	64b context switch optimization?
Message-ID: <20080815160338.GI27955@elte.hu>
References: <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <48A2FC17.9070302@redhat.com> <20080813154043.GA11886@elte.hu> <48A303EE.8070002@redhat.com> <20080813160218.GB18037@elte.hu> <20080815155457.GA5210@shareable.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080815155457.GA5210@shareable.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Ulrich Drepper <drepper@redhat.com>, Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Jamie Lokier <jamie@shareable.org> wrote:

> > how about this then?
> 
> > +#define MAP_64BIT_STACK 0x20000         /* give out 32bit addresses on old CPUs */
> 
> I think the flag makes sense but it's name is confusing - 64BIT for a 
> flag which means "maybe request 32-bit stack"!  Suggest:
> 
> +#define MAP_STACK       0x20000         /* 31bit or 64bit address for stack, */
> +                                        /* whichever is faster on this CPU */

ok. I've applied the patch below to tip/x86/urgent.

> Also, is this _only_ useful for thread stacks, or are there other 
> memory allocations where 31-bitness affects execution speed on old 
> P4s?

just about anything i guess - but since those CPUs do not really matter 
anymore in terms of bleeding-edge performance, what we care about is the 
intended current use of this flag: thread stacks.

	Ingo

-------------------->
