Date: Tue, 10 Oct 2000 00:25:20 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010002520.B8709@athlon.random>
References: <Pine.LNX.4.21.0010092256070.9803-100000@elte.hu> <XFMail.20001010071013.peterw@mulga.surf.ap.tivoli.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <XFMail.20001010071013.peterw@mulga.surf.ap.tivoli.com>; from peterw@dascom.com.au on Tue, Oct 10, 2000 at 07:10:13AM +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Waltenberg <peterw@dascom.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, MM mailing list <linux-mm@kvack.org>, Byron Stanoszek <gandalf@winds.org>, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2000 at 07:10:13AM +1000, Peter Waltenberg wrote:
> People seem to be forgetting (again), that Rik's code is *REALLY* an

Please explain why you think "people" is forgetting that. At least from my part
I wasn't forgetting that and so far I didn't read any email that made me to
think others are forgetting that.

> It's probably reasonable to not kill init, but the rest just don't matter.

Killing init is a kernel bug.

> Without the OOM killer the machine would have locked up and you'd lose that 3

Grab 2.2.18pre15aa1 and try to lockup the machine if you can.

> At least with Rik's code you end up with a usable machine afterwards which is
> a major improvement.

If current 2.4.x lockups during OOM that's because of bugs introduced during
2.[34].x. The oom killer is completly irrelevant to the stability of the kernel,
the oom killer only deals with the _selection_ of the task to kill. OOM
detection is a completly orthogonal issue.

If something the oom killer can introduce a lockup condition if there isn't
a mechamism to fallback killing the current task (all the other tasks
may be sleeping on a down-nfs-server in interruptible mode).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
