Received: from pc367.hq.eso.org (pc367.hq.eso.org [134.171.13.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA07144
	for <linux-mm@kvack.org>; Wed, 19 Aug 1998 13:18:54 -0400
Date: Wed, 19 Aug 1998 17:17:41 +0000 (   )
From: Nicolas Devillard <ndevilla@mygale.org>
Subject: Re: memory overcommitment
In-Reply-To: <199808191207.NAA00885@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.4.02.9808191639510.7138-100000@pc367.hq.eso.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>



On Wed, 19 Aug 1998, Stephen C. Tweedie wrote:
> 
> Then initialise the memory after malloc; you know the pages are there by
> that stage. 

That is no solution. Futhermore, if other processes are also touching
overcommitted memory, the initialization might just crash the machine.
What I'm saying is: if malloc() does not tell me it has a tough life
finding free memory, and just returns space generously, I have no way to
know it by myself (at least: no safe way).
What about a system call just before a series of malloc() to tell the OS
you are actually going to use this allocated memory?
This could even be set as a default for machines used as number-crunchers,
you will need lots of RAM and disk space on these anyway.

> There are also lots of programs which allocate a gig of memory and only
> use a tiny fraction of it.  We don't want them all to suddenly start
> failing.  You can't have it both ways!

Hard to believe there is no way to have both. Simply because a memory
allocation done by a forking Netscape is not the same as one done by a
developper in need of memory to process data. At least give a developper a
chance to ensure the promised memory is really there! :-)

> Umm, killing inetd?  sendmaild?  init??!!

Killing processes does not look like a solution. My feeling is: you are
entering an endless world full of nightmares if you want to implement an
intelligent daemon trying to figure out how to kill user processes.
Everyone has different requirements about how to do that, and you will
have a hard time putting this up in a simple way for the sysadmin to set
it up correctly (if there is any way to do that). Looks like a dead-end.

Let me try to put up user requirements on that one: 

- when I get allocated memory, I must be sure that it is really
  allocated and not faked, because I am 100% sure that I will use it.
  Because I know that in advance, it should not be too hard to
  communicate it to the OS by any system call or resource parameter you
  wish.
- if no more memory is available, I would like to get a message or a
  signal or whatever, telling me (politely :-) that I'm too greedy. This
  way, I know what to do: kill all netscapes, xemacs, even X if I really
  need memory, or buy more RAM, make more swap, etc. I do not fell that
  kind of decision should not be taken on the fly by any automatic
  procedure (especially to buy some RAM, I like to go by myself :-).

Cheers
Nicolas

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
