Message-Id: <200008080048.RAA13326@eng2.sequent.com>
Reply-To: Gerrit.Huizenga@us.ibm.com
From: Gerrit.Huizenga@us.ibm.com
Subject: Re: RFC: design for new VM 
In-reply-to: Your message of Mon, 07 Aug 2000 18:59:37 -0330.
             <87256934.0078DADB.00@d53mta03h.boulder.ibm.com>
Date: Mon, 07 Aug 2000 17:48:09 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: chucklever@bigfoot.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

> On Mon, 7 Aug 2000, Rik van Riel wrote:
> The idea is that the memory_pressure variable indicates how
> much page stealing is going on (on average) so every time
> kswapd wakes up it knows how much pages to steal. That way
> it should (if we're "lucky") free enough pages to get us
> along until the next time kswapd wakes up.
 
 Seems like you could signal kswapd when either the page fault
 rate increases or the rate of (memory allocations / memory
 frees) hits a tuneable? ratio (I hate relying on luck, simply
 because so much luck is bad ;-)

> About NUMA scalability: we'll have different memory pools
> per NUMA node. So if you have a 32-node, 64GB NUMA machine,
> it'll partly function like 32 independant 2GB machines.
 
 One lesson we learned early on is that anything you can
 possibly do on a per-CPU basis helps both SMP and NUMA
 activity.  This includes memory management, scheduling,
 TCP performance counters, any kind of system counters, etc.
 Once you have the basic SMP hierarchy in place, adding a NUMA
 hierarchy (or more than one for architectures that need it)
 is much easier.

 Also, is there a kswapd per pool?  Or does one kswapd oversee
 all of the pools (in the NUMA world, that is)?

gerrit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
