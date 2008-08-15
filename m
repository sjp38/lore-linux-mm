Date: Fri, 15 Aug 2008 21:00:34 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pthread_create() slow for many threads; also time to revisit
	64b context switch optimization?
Message-ID: <20080815190034.GA15356@elte.hu>
References: <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <48A2FC17.9070302@redhat.com> <20080813154043.GA11886@elte.hu> <48A303EE.8070002@redhat.com> <20080813160218.GB18037@elte.hu> <20080815155457.GA5210@shareable.org> <48A5B943.1010607@gmail.com> <20080815171913.GB23600@elte.hu> <a36005b50808151023s7baffae5w8e163046209ce9dc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a36005b50808151023s7baffae5w8e163046209ce9dc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@gmail.com>
Cc: Jamie Lokier <jamie@shareable.org>, Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Ulrich Drepper <drepper@gmail.com> wrote:

> On Fri, Aug 15, 2008 at 10:19 AM, Ingo Molnar <mingo@elte.hu> wrote:
> > ( also, just to make sure: all Linux kernel versions will ignore such
> >  extra flags, so you can just update glibc to use this flag
> >  unconditionally, correct? )
> 
> As soon as the patch hits Linus' tree I can change the code.

it's upstream now:

| commit cd98a04a59e2f94fa64d5bf1e26498d27427d5e7
| Author: Ingo Molnar <mingo@elte.hu>
| Date:   Wed Aug 13 18:02:18 2008 +0200
|
|     x86: add MAP_STACK mmap flag

thanks everyone,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
