Message-ID: <391071E3.C3398C52@sgi.com>
Date: Wed, 03 May 2000 11:37:23 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <Pine.LNX.4.10.10005031110200.6180-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Wed, 3 May 2000, Kanoj Sarcar wrote:
> >
> > At no point between the time try_to_swap_out() is running, will is_page_shared()
> > wrongly indicate the page is _not shared_, when it is really shared (as you
> > say, it is pessimistic).
> 

> 
> _Something_ obviously triggers on the x86, though.

IMHO, that's the right attitude. I really like the idea of
having the page locked if its state is being fiddled with.
I know, we don't fully understand the problem, in the sense
that no one has been able to construct a sample execution
which will hit the bug. But so what? Since the bug is elusive,
even if one comes up with a scenario, no saying that _that_
is what happened during the particular manifestation.

	[ ... ]

> 
> We fixed one such bug in NFS. Maybe there are more lurking? How much
> memory do the machines have that have problems?
> 

I don't use NFS on my test systems. So, that couldn't have
been a problem. I had about 64MB of memory in the system.

BTW, I've been running the test (some tar & diff) for
several hours now on the same system. The system is staying up fine.

regards,

ananth.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
