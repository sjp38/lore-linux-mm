Date: Thu, 18 May 2000 18:58:00 -0700 (PDT)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005121839370.3348-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0005181848360.3896-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

[ sorry for the late reply ]

On Fri, 12 May 2000, Ingo Molnar wrote:

>On Fri, 12 May 2000, Rik van Riel wrote:
>
>> But we *can* split the HIGHMEM zone into a bunch of smaller
>> ones without affecting performance. Just set zone->pages_min
>> and zone->pages_low to 0 and zone->pages_high to some smallish
>> value. Then we can teach the allocator to skip the zone if:
>> 1) no obscenely large amount of free pages
>> 2) zone is locked by somebody else (TryLock(zone->lock))
>
>whats the point of this splitup? (i suspect there is a point, i just
>cannot see it now. thanks.)

I quote email from Rik of 25 Apr 2000 23:10:56 on linux-mm:

-- Message-ID: <Pine.LNX.4.21.0004252240280.14340-100000@duckman.conectiva> --
We can do this just fine. Splitting a box into a dozen more
zones than what we have currently should work just fine,
except for (as you say) higher cpu use by kwapd.

If I get my balancing patch right, most of that disadvantage
should be gone as well. Maybe we *do* want to do this on
bigger SMP boxes so each processor can start out with a
separate zone and check the other zone later to avoid lock
contention?
--------------------------------------------------------------

I still strongly think that the current zone strict mem balancing design
is very broken (and I also think to be right since I believe to see
the whole picture) but I don't think I can explain my arguments
better and/or more extensively of how I just did in linux-mm some week ago.

If you see anything wrong in my reasoning please let me know. The interesting
thread was "Re: 2.3.x mem balancing" (the start were off list) in linux-mm.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
