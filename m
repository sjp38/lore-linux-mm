Date: Fri, 12 May 2000 14:15:22 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005121839370.3348-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0005121414270.28943-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 12 May 2000, Ingo Molnar wrote:
> On Fri, 12 May 2000, Rik van Riel wrote:
> 
> > But we *can* split the HIGHMEM zone into a bunch of smaller
> > ones without affecting performance. Just set zone->pages_min
> > and zone->pages_low to 0 and zone->pages_high to some smallish
> > value. Then we can teach the allocator to skip the zone if:
> > 1) no obscenely large amount of free pages
> > 2) zone is locked by somebody else (TryLock(zone->lock))
> 
> whats the point of this splitup? (i suspect there is a point, i
> just cannot see it now. thanks.)

There's not much point in doing so. This is basically
just a reply to Andrea's "but you can't do _this_ with
the current approach" remark ;)

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
