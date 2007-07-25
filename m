Received: by ug-out-1314.google.com with SMTP id c2so449729ugf
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 09:19:08 -0700 (PDT)
Message-ID: <2c0942db0707250919j48a65798s816b4cad27171e56@mail.gmail.com>
Date: Wed, 25 Jul 2007 09:19:04 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <46A6CC56.6040307@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/24/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Ray Lee wrote:
> > On 7/23/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> >> If we can first try looking at
> >> some specific problems that are easily identified.
> >
> > Always easier, true. Let's start with "My mouse jerks around under
> > memory load." A Google Summer of Code student working on X.Org claims
> > that mlocking the mouse handling routines gives a smooth cursor under
> > load ([1]). It's surprising that the kernel would swap that out in the
> > first place.
> >
> > [1]
> > http://vignatti.wordpress.com/2007/07/06/xorg-input-thread-summary-or-something/
>
> OK, I'm not sure what the point is though. Under heavy memory load,
> things are going to get swapped out... and swap prefetch isn't going
> to help there (at least, not during the memory load).

Sorry, I headed slightly off-topic. Or perhaps 'up-topic' to the
larger issue, which is that the desktop experience has some suckiness
to it.

My point is that the page replacement algorithm has some choice as to
what to evict. The xorg input handler never should have been evicted.
It was hopefully a hard example of where the current page replacement
policy is falling flat on its face.

All that said, this could really easily be handled by xorg mlocking
the critical realtime stuff.

> There are also other issues like whether the CPU scheduler is at fault,
> etc. Interactive workloads are always the hardest to work out.

This one is not a scheduler issue, as mlock()ing the mouse handling
routines gives a smooth cursor. It's just a pure page replacement
problem, as the kernel should never have swapped that out in the first
place.

<snip things I agreed with>

<snip list of things to watch during updatedb run>

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
