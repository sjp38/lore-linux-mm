Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA25853
	for <Linux-MM@kvack.org>; Thu, 1 Oct 1998 05:05:48 -0400
Date: Thu, 1 Oct 1998 09:20:18 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Linux memory problem with TIS  firewall
In-Reply-To: <01BDEC86.186F1DB0@gate.altersys.com>
Message-ID: <Pine.LNX.3.96.981001091630.21204E-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Genevieve Aubut <gaubut@altersys.com>
Cc: "'Linux-MM@kvack.org'" <Linux-MM@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Sep 1998, Genevieve Aubut wrote:

> We have installed a TIS firewall on a Red Hat Linux (Kernel version
> 2.0.34) computer. 
> 
> Since we installed it, the computer crashes once or twice a day with
> this error: 
> 	
> 	- Unable to handle kernel paging request at virtual address "xxx" for example e03b653c
> 	and displays a list of addresses  and stack contents  as well as :
> 	
> 	- Process http-gw  (pid: ....)

Could you please send us the ksymoops output of such an
event? That would give us some more detail to work with...

> and at the end the message:
> 
> 	- kfree of non-kmalloced memory ....
> 
> The computer is a Pentium MMX 166 with 32 Mb of memory.  
> The hard disk contains a swap partition of 400 Mb in a 2.8 Gb.

How much of that swap is actually used? If there's a
memory leak somewhere (the firewall package eg.) and
it fills up the memory in a certain time things might
go wrong.

OTOH, I have heard some rumours of more memory leaks
being fixed in kernel 2.0.36.

> The only application running is the TIS firewall.  We downloaded 
> the most recent version from your ftp site last week.

??? Most recent version of what? Kernel 2.0.34 is certainly
not the most recent one... The TIS firewall is not something
we know of...

Linux is not a company, so there's not really a 'we' and
certainly no 'our ftp site' :)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
