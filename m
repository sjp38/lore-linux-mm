Date: Wed, 30 Aug 2000 13:42:32 +0200 (CEST)
From: Marco Colombo <marco@esi.it>
Subject: Re: Question: memory management and QoS
In-Reply-To: <39ACCD6F.37EAA614@tuke.sk>
Message-ID: <Pine.LNX.4.10.10008301307330.4238-100000@NOC.ESI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Astalos <astalos@tuke.sk>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Aug 2000, Jan Astalos wrote:

> Andrey Savochkin wrote:
> [snip]
> 
> > > As a user, I won't bear _any_ overcommits at all. Once service is paid, I expect
> > > guarantied level of quality. In the case of VM, all the memory I paid for.
> > > For all of my processes.
> > 
> > It means that you pay orders of magnitude more for it.
> 
> If I got it right you are speaking about disk space. About sum of disk quotas
> "orders of magnitude" higher than actual available disk space, right ?
> You will sell users more disk space than you have for the price of your
> actual space (and you'll hope that they won't use whole disk).
> 
> But you must get the disk space when users will need it (QoS), so in disk shortage,
> you'll need to buy next one. You'll then send an additional bill to them ?

Well, IMHO it's a matter of numbers. If you're going to use 1/2 of the
system resources, you may afford the cost of a whole dedicated system.
No quotas, no users, no problems.
If you're going to use 1/1000 of them (so we're speaking of a huge system)
you may consider that, on average, no all users will be using their 
resources, and it makes a lot of sense to overcommit.
If all citizens in a big town want to use their phone at the same time,
most of them won't get the service. But it almost never happens.
The bigger the numbers involved, the safer to overcommit. It allows the
service provider to lower costs a lot. I think no one is selling a 
phone line that is garanteed to *always* work (it works only for p-o-p links,
i.e. leased lines). It would cost too much, and, in practice, give no real
advantage... 
That's the whole idea behind time(and resource)-sharing systems...
Otherwise, that 1/1000 of the huge system will cost *much* more than
a personal workstation with better performances. And also you'll see
other users, paying 1/100 of what you're paying, get almost the same
service (the system almost never fails to fulfill their requests).

And you're not selling "more disk space than you have". You're selling
10MB and the user gets up to 10MB. Shortage *almost* never happens,
so you *almost* always provide the service...

.TM.
-- 
      ____/  ____/   /
     /      /       /			Marco Colombo
    ___/  ___  /   /		      Technical Manager
   /          /   /			 ESI s.r.l.
 _____/ _____/  _/		       Colombo@ESI.it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
