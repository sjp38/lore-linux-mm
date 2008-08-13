Date: Wed, 13 Aug 2008 06:35:33 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: pthread_create() slow for many threads; also time to revisit
 64b context switch optimization?
Message-ID: <20080813063533.444c650d@infradead.org>
In-Reply-To: <20080813104445.GA24632@elte.hu>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com>
	<af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com>
	<20080813104445.GA24632@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Pardo <pardo@google.com>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Ulrich Drepper <drepper@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Aug 2008 12:44:45 +0200
Ingo Molnar <mingo@elte.hu> wrote:


> There are various other options to solve the (severe!) performance 
> breakdown:
> 
> 1- glibc could start not using MAP_32BIT for 64-bit thread stacks
> (the boxes where context-switching is slow probably do not matter all
> that much anymore - they were very slow at everything 64-bit anyway)
> 
>      Pros: easiest solution.
>      Cons: slows down the affected machines and needs a new glibc.
> 
> 
> i'd go for 1) or 2).

I would go for 1) clearly; it's the cleanest thing going forward for
sure.



-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
