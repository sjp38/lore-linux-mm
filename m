Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA15360
	for <linux-mm@kvack.org>; Fri, 19 Dec 1997 06:30:42 -0500
Date: Fri, 19 Dec 1997 12:24:16 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: ideas for a swapping daemon
In-Reply-To: <Pine.LNX.3.96.971218205013.1610B-100000@ladybug.org.il>
Message-ID: <Pine.LNX.3.91.971219121900.14931A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Moshe Zadka <moshez@math.huji.ac.il>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Dec 1997, Moshe Zadka wrote:

> Seems like a good idea. But experience with vhand
> shows that what we should be most careful about is 
> waking the swapping daemon too often, consuming 
> resources. So, if anyone is writing it (I might
> start by patching kswapd's routines to allow 
> "forcing"), please keep an easily configurable
> parameter (perhaps run-time adjusted through proc-fs)
> controlling how often it is woken up, for easier
> determining of the heuristics.

The kswapd part I can do in several hours too, the real
issue is scheduling... If we have the scheduling part
correct, the kswapd part is only optional...

We should start by adding SLEEP_TIME and IN_CORE time
entries to the task_struct. Then we have to write a
mechanism to wake up the daemon to decide to swap which
program.

Only then are the extra lines to kswapd functional
(otherwise, the system will be paging in the process we
just swapped out :-)

What we need first is a generally agreed upon algorithm
on how to decide:
- when to swap (tunable)
- what to swap (tunable?)
- how agressive we should be (tunable)
- how long programs can be swapped out/in (tunable)

Even though most of the above is tunable, we still need
to agree on the algoritms and design the program...
When the design is finished, we can have the daemon up and
running in a few days.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
