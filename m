Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA09967
	for <linux-mm@kvack.org>; Tue, 9 Dec 1997 06:22:14 -0500
Date: Tue, 9 Dec 1997 11:58:17 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: VM ideas (was: Re: TTY changes to 2.1.65)
In-Reply-To: <wd867ozt0eo.fsf@parafoudre.irisa.fr>
Message-ID: <Pine.LNX.3.91.971209115446.690C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Mentre <David.Mentre@irisa.fr>
Cc: Joerg Rade <jr@petz.han.de>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 9 Dec 1997, David Mentre wrote:

>  The interesting point of Joerg is that he see the TLB mecanism as a
> more general mecanism than just to solve swapping problems.

OK...

>  As I'm a little involved in Distributed Shared Memories (with a PhD ;),
> I couldn't let such an opportunity happen without talking. I totally
> agree with Joerg. One problems with DSM is that you must track user
> memory accesses to maintain coherency. Unfortunatly, fine grain access
> like cache line is not available to the average system
> programmer. Therefore sub-page protection could be very useful. 

I admit I haven't thought of that... Not having this might
be analogous to the bouncing-cache-line problem slab development
was confronted with (or just avoided?)

>  Regarding DIPC, I think we could improved a little the coherency
> protocol. One big advantage of DIPC is that it provide code, and you
> can't lie with code. :) I hope I'll have more code in the future to
> explain my point of vue in DSM.

Cool, we can always use good/beautiful code...
This is especially true when I can learn new things by
reading it.

Rik.

--
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
