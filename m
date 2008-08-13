Date: Wed, 13 Aug 2008 11:16:35 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: pthread_create() slow for many threads; also time to revisit
 64b context switch optimization?
Message-ID: <20080813111635.657febc0@infradead.org>
In-Reply-To: <48A3222D.2060809@redhat.com>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com>
	<af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com>
	<20080813104445.GA24632@elte.hu>
	<20080813063533.444c650d@infradead.org>
	<48A2EE07.3040003@redhat.com>
	<20080813142529.GB21129@elte.hu>
	<48A2F157.7000303@redhat.com>
	<20080813151007.GA8780@elte.hu>
	<48A2FC17.9070302@redhat.com>
	<20080813154043.GA11886@elte.hu>
	<48A303EE.8070002@redhat.com>
	<alpine.LFD.1.10.0808131007530.3462@nehalem.linux-foundation.org>
	<48A3222D.2060809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Aug 2008 11:04:29 -0700
Ulrich Drepper <drepper@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Linus Torvalds wrote:
> > Ulrich, I don't understand why you worry more about a _potential_
> > (and fairly unlikely) complaint, than about a real one today.
> 
> Of course I care.  All I try to do is to prevent going from one
> extreme (all focus on P4s) to the other (ignore P4s completely).

(fwiw as far as I know this is only about early 64 bit P4s, not later
generations)
> 
> Even ignoring this one case here, I think it's in any case useful for
> userlevel to tell the kernel that an anonymous memory region is needed
> for a stack.  This might allow better optimizations and/or security
> implementations.

yeah maybe we should also tell it we expect it to be used downwards.
Oh wait.. MAP_GROWSDOWN ?

-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
