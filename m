Date: Thu, 22 Jun 2000 12:31:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] RSS guarantees and limits
In-Reply-To: <85256906.005108A2.00@D51MTA03.pok.ibm.com>
Message-ID: <Pine.LNX.4.21.0006221156230.10785-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: frankeh@us.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2000 frankeh@us.ibm.com wrote:

> Seems like a good idea, for ensuring some decent response time.
> This seems similar to what WinNT is doing.

There's a big difference here. I plan on making the RSS limit system
such that most applications should be somewhere between their limit
and their guarantee when the system is under "normal" levels of
memory pressure.

That is, I want to keep global page replacement the primary page
replacement strategy and only use the RSS guarantees and limits to
guide global page replacement and limit the system from impact by
memory hogs.

> Do you envision that the "RSS guarantees" decay over time. I am
> concerned that some daemons hanging out there and which might be
> executed very rarely (e.g. inetd) might hug to much memory
> (cummulatively speaking).  I think NT at some point pages the
> entire working set for such apps.

This is what I want to avoid. Of course if a task is really
sleeping it should of course be completely removed from
memory, but a _periodic_ task like top or atd may as well be
protected a bit if memory pressure is low enough.

I know I will have to adjust my rough draft quite a bit to
achieve the wanted effects...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
