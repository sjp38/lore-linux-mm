Date: Mon, 9 Oct 2000 20:10:17 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <20001010002520.B8709@athlon.random>
Message-ID: <Pine.LNX.4.21.0010092002580.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Peter Waltenberg <peterw@dascom.com.au>, Ingo Molnar <mingo@elte.hu>, MM mailing list <linux-mm@kvack.org>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Oct 2000, Andrea Arcangeli wrote:
> On Tue, Oct 10, 2000 at 07:10:13AM +1000, Peter Waltenberg wrote:

> > It's probably reasonable to not kill init, but the rest just don't matter.
> Killing init is a kernel bug.

And if people find this is a real problem with the OOM killer
I posted some days ago, I'll gladly add the extra code to make
sure init won't be killed.

But until I know it is a problem, I'd rather keep the (hardly
ever used) code small.

> > Without the OOM killer the machine would have locked up and you'd lose that 3
> 
> Grab 2.2.18pre15aa1 and try to lockup the machine if you can.

*grin*    (ok, I'll bite)

Are you /sure/ that kernel no longer kills syslogd,
knfsd or X (crashing the console) ?? ;)

> > At least with Rik's code you end up with a usable machine afterwards which is
> > a major improvement.
> 
> If current 2.4.x lockups during OOM that's because of bugs
> introduced during 2.[34].x.

And not accidentally introduced either. If you read back the
email exchanges between Linus and me regarding the new VM,
you'll see that there's a REASON I didn't have the OOM killer
from the beginning.

I was busy stabilising the new VM feature by feature, only
adding new features (like the OOM killer) after the previous
features had stabilised. The fact that Linus chose to merge
the new VM before I got around to integrating the OOM killer
is purely coincidental.

(in fact, the time Linus chose was quite a bad time for me
because I was just leaving for 2 weeks of conferences)

> The oom killer is completly irrelevant to the stability of the
> kernel, the oom killer only deals with the _selection_ of the
> task to kill. OOM detection is a completly orthogonal issue.

Indeed. And I think you'll have to agree that OOM detection in
2.4 is quite a bit more solid now than it was in 2.2 ...

(where the system simply bails out under too heavy memory
pressure, instead of testing if we are /really/ out of memory)

> If something the oom killer can introduce a lockup condition if
> there isn't a mechamism to fallback killing the current task
> (all the other tasks may be sleeping on a down-nfs-server in
> interruptible mode).

Indeed, this is another theoretical problem. What I'd like
to know, though, is if it matters enough in practice that
we really want the extra bloat in the kernel to deal with
all those theoretically possible corner cases...

(And I'm willing to bet that even when we have 100kB of
OOM killer heuristics in the kernel, there will /STILL/
be corner cases we don't catch)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
