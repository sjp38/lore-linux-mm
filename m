Message-ID: <48A30642.4060709@zytor.com>
Date: Wed, 13 Aug 2008 09:05:22 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: pthread_create() slow for many threads; also time to revisit
 64b context switch optimization?
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com> <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com> <20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <48A2FC17.9070302@redhat.com>
In-Reply-To: <48A2FC17.9070302@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Ulrich Drepper wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Ingo Molnar wrote:
>> i find it pretty unacceptable these days that we limit any aspect of 
>> pure 64-bit apps in any way to 4GB (or any other 32-bit-ish limit). 
> 
> Sure, but if we can pin-point the sub-archs for which it is the problem
> then a flag to optionally request it is even easier to handle.  You'd
> simply ignore the flag for anything but the P4 architecture.
> 
> I personally have no problem removing the whole thing because I have no
> such machine running anymore.  But there are people out there who have.
 >

This could also be done entirely in glibc (thus removing the dependency 
on the kernel): set the flag if and only if you detect a P4 CPU.  You 
don't even need to enumerate all the CPUs in the system (which would be 
more painful) if you make the CPUID test wide enough that it catches all 
compatible CPUs.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
