Received: by ug-out-1314.google.com with SMTP id c2so114287ugf
        for <linux-mm@kvack.org>; Mon, 23 Jul 2007 21:53:38 -0700 (PDT)
Message-ID: <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
Date: Mon, 23 Jul 2007 21:53:38 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <46A57068.3070701@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/23/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Not talking about swap prefetch itself, but everytime I have asked
> anyone to instrument or produce some workload where swap prefetch
> helps, they never do.
[...]
> so for all the people who a whining about merging this and don't want
> to actually work on the code -- post some numbers for where it helps
> you!!

<Raised eyebrow> You sound frustrated. Perhaps we could be
communicating better. I'll start.

Unlike others on the cc: line, I don't get paid to hack on the kernel,
not even indirectly. So if you find that my lack of providing numbers
is giving you heartache, I can only apologize and point at my paying
work that requires my attention.

That said, I'm willing to run my day to day life through both a swap
prefetch kernel and a normal one. *However*, before I go through all
the work of instrumenting the damn thing, I'd really like Andrew (or
Linus) to lay out his acceptance criteria on the feature. Exactly what
*should* I be paying attention to? I've suggested keeping track of
process swapin delay total time, and comparing with and without. Is
that reasonable? Is it incomplete?

Without Andrew's criteria, we're back to where we've been for a long
time: lots of work, no forward motion. Perhaps it's a character flaw
of mine, but I'd really like to know what would constitute proof here
before I invest the effort. Especially given that Con has already
written a test case that shows that swap prefetch works, and that I've
given you a clear argument for why better (or even perfect) page
reclaim can't provide full coverage to all the situations that swap
prefetch helps. (Also, it's not like I've got tons free time, y'know?
Just like all the rest of you all, I have to pick and choose my
battles if I'm going to be effective.)

Since this merge period has appeared particularly frazzling for
Andrew, I've been keeping silent and waiting for him to get to a point
where there's a breather. I didn't feel it would be polite to request
yet more work out of him while he had a mess on his hands.

But, given this has come to a head, I'm asking now.

Andrew? You've always given the impression that you want this run more
as an engineering effort than an artistic endeavour, so help us out
here. What are your concerns with swap prefetch? What sort of
comparative data would you like to see to justify its inclusion, or to
prove that it's not needed?

Or are we reading too much into the fact that it isn't merged? In
short, communicate please, it will help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
