Date: Mon, 25 Sep 2000 16:43:44 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VM
In-Reply-To: <20000925163909.O22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251640330.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> At least Linus's point is that doing perfect accounting (at least on
> the userspace allocation side) may cause you to waste resources,
> failing even if you could still run and I tend to agree with him.
> We're lazy on that side and that's global win in most cases.

well, as i said, i agree that being lazy on the user-space side (which is
by far the biggest RAM allocator in a typical system) makes sense - and we
can handle it cleanly.

Being lazy on the kernel-space side is the default behavior for us kernel
hackers :-) but i dont think it's the right thing in the long term.

> We are finegrined with page granularity, not with the mmap
> granularity. The point is that not all the mmapped regions are going
> to be pagedin. Think a program that only after 1 hour did all the
> calculations that allocated all the memory it requested with malloc.  
> Before the hour passes the unused memory can still be used for other
> things and that's what the user also expects when he runs `free`.

i think you've completely missed the fact that i made exactly this point
in my previous mail.

	'user-space laziness': correct
	'kernel-space laziness': dangerous

i talked about GFP_KERNEL, not GFP_USER. Even in the case of GFP_USER i
believe the right place to oom is via a signal, not in the gfp() case.
(because oom situation in the gfp() case is a completely random and
statistical event, which might have no connection at all to the behavior
of that given process.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
