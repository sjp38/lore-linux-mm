Date: Mon, 15 May 2000 09:01:03 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <852568E0.0056F0BB.00@raylex-gh01.eo.ray.com>
Message-ID: <Pine.LNX.4.10.10005150858060.3588-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson.RTS@raytheon.com
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>


On Mon, 15 May 2000 Mark_H_Johnson.RTS@raytheon.com wrote:
> 
> I guess I have a "philosophy question" - one where I can't quite understand the
> situation that we are in.
>   What is the problem that killing processes is curing?
> I understand that the code that [has been/still is?] killing processes is doing
> so because there is no "free physical memory" - right now. Yet we have had code
> to do a schedule() instead of killing the job, and gave the system the chance to
> "fix" the lack of free physical memory problem (e.g., by writing dirty pages to
> a mapped file or swap space on disk). From what I read from Juan's message
> below, I guess this code has been lost or replaced by something more hostile to
> user applications.

This is actually how Linux _used_ to work, a long long time ago. It is
very simple, and it actually worked very well indeed.

Until somebody _really_ starts to eat up memory, at which point it results
in a machine that is completely dead to the world, doing nothing but
swapping pages in and out again.

The "wait until memory is free" approach works very well under many loads,
it's just that it has some rather unfortunate pathological behaviour that
is completely unacceptable. At some point you just have to say "Enough!",
and start killing something.

The bug, of course, is that wehave been quite a bit too eager to do so;)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
