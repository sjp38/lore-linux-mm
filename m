Received: from northrelay02.pok.ibm.com (northrelay02.pok.ibm.com [9.117.200.22])
	by e3.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id LAA18236
	for <linux-mm@kvack.org>; Thu, 22 Jun 2000 11:46:58 -0400
From: frankeh@us.ibm.com
Received: from D51MTA03.pok.ibm.com (d51mta03.pok.ibm.com [9.117.200.31])
	by northrelay02.pok.ibm.com (8.8.8m3/NCO v4.9) with SMTP id LAA219374
	for <linux-mm@kvack.org>; Thu, 22 Jun 2000 11:48:49 -0400
Message-ID: <85256906.0056DB76.00@D51MTA03.pok.ibm.com>
Date: Thu, 22 Jun 2000 11:49:51 -0400
Subject: Re: [RFC] RSS guarantees and limits
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I assume that in the <workstation> scenario, where there are limited number
of processes, your approach will work just fine.

In a server scenario where you might have lots of processes (with limited
resource requirements) this might have different effects
This inevidably will happen when we move Linux to NUMA or large scale SMP
systems and we apply images like that to webhosting.

Do you think that the resulting RSS guarantees (function of
<mem_size/2*process_count>) will  be sufficient ? Or is your assumption,
that for this kind of server apps with lots of running processes, you
better don't overextent your memory and start paging (acceptable
assumption)..



-- Hubertus


Rik van Riel <riel@conectiva.com.br> on 06/22/2000 12:01:18 PM

To:   Hubertus Franke/Watson/IBM@IBMUS
cc:   linux-mm@kvack.org
Subject:  Re: [RFC] RSS guarantees and limits



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
http://www.conectiva.com/          http://www.surriel.com/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
