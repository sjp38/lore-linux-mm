Date: Tue, 2 May 2000 19:53:41 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <852568D3.005FC088.00@D51MTA07.pok.ibm.com>
Message-ID: <Pine.LNX.4.21.0005021938040.773-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: frankeh@us.ibm.com
Cc: riel@nl.linux.org, Roger Larsson <roger.larsson@norran.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000 frankeh@us.ibm.com wrote:

>The smart things that I see has to happen is to allow a set of processes to
>be attached to a set of memory pools and the OS basically enforcing
>allocation in those constraints. I brought this up before and I think
>Andrea proposed something similar. Allocation should take place in those

Yes, that's why I think we need to be able to know the state of the cache
in a single pg_data_t. If 99% of the pg_data_t is _freeable_ cache it
worth to shrink a bit from the cache of _such_ pg_data_t instead of
risking shrinking and then allocating the memory from a foregin pg_data_t
because we respect a global LRU). This can't hurt at all the common non
NUMA case since in the common case of 99% of IA32 boxes out there we have
_one_ only pg_data_t thus the lru keeps to be effectively system-global
for them.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
