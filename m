Date: Sun, 15 Apr 2001 02:05:59 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
In-Reply-To: <m1ofu0t18b.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.21.0104150205210.14442-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On 14 Apr 2001, Eric W. Biederman wrote:

> > Thrashing when we still have swap free is an entirely different
> > matter, which I want to solve with load control code. That is,
> > when the load gets too high, we temporarily suspend processes
> > to bring the load down to more acceptable levels.
> 
> That's not bad but when it starts coming to policy, the policy
> decisions are much more safely made in user space rather than the
> kernel.  And we just allow the kernel to completely swap-out suspended
> processes. 

You're soooo full of crap.  Next we know you'll be proposing
to move the scheduler and the pageout code to userspace.

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
