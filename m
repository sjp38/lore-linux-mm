Message-ID: <46A589D5.9050103@goop.org>
Date: Mon, 23 Jul 2007 22:10:45 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <200707102015.44004.kernel@kolivas.org>	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	 <46A57068.3070701@yahoo.com.au> <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
In-Reply-To: <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ray Lee wrote:
> That said, I'm willing to run my day to day life through both a swap
> prefetch kernel and a normal one. *However*, before I go through all
> the work of instrumenting the damn thing, I'd really like Andrew (or
> Linus) to lay out his acceptance criteria on the feature. Exactly what
> *should* I be paying attention to? I've suggested keeping track of
> process swapin delay total time, and comparing with and without. Is
> that reasonable? Is it incomplete?

Um, isn't it up to you?  The questions that need to be answered are:

   1. What are you trying to achieve?  Presumably you have some intended
      or desired effect you're trying to get.  What's the intended
      audience?  Who would be expected to see a benefit?  Who suffers?
   2. How does the code achieve that end?  Is it nasty or nice?  Has
      everyone who's interested in the affected areas at least looked at
      the changes, or ideally given them a good review?  Does it need
      lots of tunables, or is it set-and-forget?
   3. Does it achieve the intended end?  Numbers are helpful here.
   4. Does it make anything worse?  A lot or a little?  Rare corner
      cases, or a real world usage?  Again, numbers make the case most
      strongly.


I can't say I've been following this particular feature very closely,
but these are the fundamental questions that need to be dealt with in
merging any significant change.  And as Nick says, historically point 4
is very important in VM tuning changes, because "obvious" improvements
have often ended up giving pathologically bad results on unexpected
workloads.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
