Received: from localhost (bcrl@localhost)
	by kvack.org (8.8.7/8.8.7) with SMTP id LAA10404
	for <linux-mm@kvack.org>; Thu, 18 Dec 1997 11:22:10 -0500
Date: Thu, 18 Dec 1997 11:22:10 -0500 (U)
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: procps-1.2.2
Message-ID: <Pine.LNX.3.95.971218112131.10225D-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Date: Thu, 18 Dec 1997 15:19:03 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
X-Sender: riel@mirkwood.dummy.home
Reply-To: H.H.vanRiel@fys.ruu.nl
To: "Albert D. Cahalan" <acahalan@cs.uml.edu>
cc: linux-kernel@vger.rutgers.edu, linux-mm <linux-mm@kvack.org>
Subject: Re: procps-1.2.2
In-Reply-To: <199712180727.CAA21551@saturn.cs.uml.edu>
Message-ID: <Pine.LNX.3.91.971218151007.15652B-100000@mirkwood.dummy.home>
Approved: ObHack@localhost
Organization: none
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Thu, 18 Dec 1997, Albert D. Cahalan wrote:

> ObKernel:   :-)
> 
> The kernel does not seem to supply info for these fields:
> 
> CP/CPU short-term cpu usage factor (for scheduling)
> CURSIG current signal
> SESS   session pointer
> JOBC   job control count; count of processes qualifying PGID for job control
> SL     sleep time (in seconds; 127 = infinity)
> RE     core residency time (in seconds; 127 = infinity)
> 
> Have I missed something? These are needed for full BSD behavior.

I really think we should work on (at least) the last two,
as they are essential for the implementation of true swapping
and true background tasks. There's been some discussion on
this on linux-mm too, and it seems to be neccesary.

CP/CPU isn't neccesary for Linux, and could return a value
derived from p->counter. OTOH, if we imlement it correctly,
we could make a better sheduler.

CURRSIG seems to be a bit like WCHAN, but I might be wrong...

SESS and JOBC I really don't see any use for, but I'm sure
someone else will :)

SL could be implemented very easily, we just add a sleep_time
value to the task struct, and assign to it the jiffies value
at which we called remove_from_runqueu().

RE can be implemented when we implement the swapping daemon
(Pavel: this would be a good time to implement memory priorities
as well).

If we could agree on some algorithm for the swapping daemon to
decide when and what to swap, I'm willing to implement it...
F-ups in a swapping daemon thread (will follow shortly). 

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
