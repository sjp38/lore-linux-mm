Received: by py-out-1112.google.com with SMTP id v53so450705pyh
        for <linux-mm@kvack.org>; Wed, 09 May 2007 22:52:00 -0700 (PDT)
Message-ID: <2c0942db0705092252n13a6a79aq39f13fcfae534de2@mail.gmail.com>
Date: Wed, 9 May 2007 22:52:00 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
In-Reply-To: <46429801.8030202@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	 <200705100928.34056.kernel@kolivas.org>
	 <464261B5.6030809@yahoo.com.au>
	 <200705101134.34350.kernel@kolivas.org> <46427BDB.30004@yahoo.com.au>
	 <2c0942db0705092048m38b36e7fo3a7c2c59fe1612b2@mail.gmail.com>
	 <46429801.8030202@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Con Kolivas <kernel@kolivas.org>, Ingo Molnar <mingo@elte.hu>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/9/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Ray Lee wrote:
> > On 5/9/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> >
> >> You said it helped with the updatedb problem. That says we should look at
> >> why it is going bad first, and for example improve use-once algorithms.
> >> After we do that, then swap prefetching might still help, which is fine.
> >
> > Nick, if you're volunteering to do that analysis, then great. If not,
> > then you're just providing a airy hope with nothing to back up when or
> > if that work would ever occur.
>
> I'd like to try helping. Tell me your problem.

Huh? You already stated one version of it above, namely updatedb. But
let's put this another way, shall we? A gedankenexperiment, if you
will.

Say we have a perfect swap-out algorithm that can choose exactly what
needs to be evicted to disk. ('Perfect', of course, is dependent upon
one's metric, but let's go with "maximizes overall system utilization
and minimizes IO wait time." Arbitrary, but hey.)

So, great, the right things got swapped out. Anything else that could
have been chosen would have caused more overall IO Wait. Yay us.

So what happens when those processes that triggered the swap-outs go
away? (Firefox is closed, I stop hitting my local copy of a database,
whatever.) Well, currently, nothing. What happens when I switch
workspaces and try to use my email program? Swap-ins.

Okay, so why didn't the system swap that stuff in preemptively? Why am
I sitting there waiting for something that it could have already done
in the background?

A new swap-out algorithm, be it use-once, Clock-Pro, or perfect
foreknowledge isn't going to change that issue. Swap prefetch does.

> > Further, if you or someone else *does* do that work, then guess what,
> > we still have the option to rip out the swap prefetching code after
> > the hypothetical use-once improvements have been proven and merged.
> > Which, by the way, I've watched people talk about since 2.4. That was,
> > y'know, a *while* ago.
>
> What's wrong with the use-once we have? What improvements are you talking
> about?

You said, effectively: "Use-once could be improved to deal with
updatedb". I said I've been reading emails from Rik and others talking
about that for four years now, and we're still talking about it. Were
it merely updatedb, I'd say us userspace folk should step up and
rewrite the damn thing to amortize its work. However, I and others
feel it's only an example -- glaring, obviously -- of a more pervasive
issue. A small issue, to be sure!, but an issue nevertheless.

In general, I/others are talking about improving the desktop
experience of running too much on a RAM limited machine. (Which, in my
case, is with a gig and a 2.2GHz processor.)

Or restated: the desktop experience occasionally sucks for me, and I
don't think I'm alone. There may be a heuristic, completely isolated
from userspace (and so isn't an API the kernel has to support! -- if
it doesn't work, we can rip it out again), that may mitigate the
suckiness. Let's try it.

> > So enough with the stop energy, okay? You're better than that.
>
> I don't think it is about energy or being mean, I'm just stating the
> issues I have with it.

Nick, I in no way think you're being mean, and I'm sorry if I've given
you that impression. However, if you're just stating the issues you
have with it, then can I assume that you won't lobby against having
this experiment merged?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
