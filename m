Message-ID: <XFMail.20001010085923.peterw@mulga.surf.ap.tivoli.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
In-Reply-To: <20001010002520.B8709@athlon.random>
Date: Tue, 10 Oct 2000 08:59:23 +1000 (EST)
From: Peter Waltenberg <peterw@dascom.com.au>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Peter Waltenberg <peterw@dascom.com.au>
List-ID: <linux-mm.kvack.org>

On 09-Oct-2000 Andrea Arcangeli wrote:
> On Tue, Oct 10, 2000 at 07:10:13AM +1000, Peter Waltenberg wrote:
>> People seem to be forgetting (again), that Rik's code is *REALLY* an
> 
> Please explain why you think "people" is forgetting that. At least from my
> part
> I wasn't forgetting that and so far I didn't read any email that made me to
> think others are forgetting that.

I didn't mail the whole kernel list originally, maybe I should have. This
discussion has happened before. The OOM code can never be perfect, I beleive
this can be proven mathematically. In that case, it should at least be simple.

We've seen suggestion after suggestion recently for making the heuristics more
and more complex to cope with corner cases. That isn't going to help, it just
makes it's behaviour less predictable. 

THAT is what I was commenting on.

Without some last resort "kill user processes" code, the kernel hangs under
memory pressure. It'd be nicer if it didn't, but eventually thats what happens.

Having some last resort kernel process which will attempt to keep the kernel
usable is a good idea, and it seems to work, at least on my testing.

Frankly, when it gets to the point where my machine will crash anyway, I don't
really care if the OOM killer gets it wrong now and then. It's still better
than it not being there.

I realize that the MM people are making efforts to ensure that the kernel will
keep running under insane pressure, and maybe you'll produce a kernel now and
then that doesn't die, BUT, I don't think you can ensure that's the case with
every kernel produced. Something will slip through, and again we'll have the
possibility of hangs.

Having a SIMPLE OOM handler in the kernel is a very usefull fallback, it's a
last resort, and if it gets it right 9 times out of 10, it's added another "9"
to the reliability figures.


>> It's probably reasonable to not kill init, but the rest just don't matter.
> 
> Killing init is a kernel bug.
> 
>> Without the OOM killer the machine would have locked up and you'd lose that
>> 3
> 
> Grab 2.2.18pre15aa1 and try to lockup the machine if you can.
> 
>> At least with Rik's code you end up with a usable machine afterwards which
>> is
>> a major improvement.
> 
> If current 2.4.x lockups during OOM that's because of bugs introduced during
> 2.[34].x. The oom killer is completly irrelevant to the stability of the
> kernel,

But not the the stability of the system. I agree, it's better if the OOM killer
never gets used, but the majority of kernels released ARE killable with memory
pressure.

> the oom killer only deals with the _selection_ of the task to kill. OOM
> detection is a completly orthogonal issue.
> 
> If something the oom killer can introduce a lockup condition if there isn't
> a mechamism to fallback killing the current task (all the other tasks
> may be sleeping on a down-nfs-server in interruptible mode).

That probably doesn't matter, the machine would be dead otherwise anyway. WITH
the OOM killer it has some chance of recovering, without it none. It'd be nicer
if that didn't occur, but OOM handling is still an improvement.

> Andrea

Peter
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
