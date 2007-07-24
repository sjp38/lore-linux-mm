Received: by hu-out-0506.google.com with SMTP id 32so1647654huf
        for <linux-mm@kvack.org>; Mon, 23 Jul 2007 22:18:05 -0700 (PDT)
Message-ID: <2c0942db0707232218g4a742e92k925526c5cb962f3e@mail.gmail.com>
Date: Mon, 23 Jul 2007 22:18:04 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <46A589D5.9050103@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A589D5.9050103@goop.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/23/07, Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> Ray Lee wrote:
> > That said, I'm willing to run my day to day life through both a swap
> > prefetch kernel and a normal one. *However*, before I go through all
> > the work of instrumenting the damn thing, I'd really like Andrew (or
> > Linus) to lay out his acceptance criteria on the feature. Exactly what
> > *should* I be paying attention to? I've suggested keeping track of
> > process swapin delay total time, and comparing with and without. Is
> > that reasonable? Is it incomplete?
>
> Um, isn't it up to you?

Huh? I'm not Linus or Andrew, with the power to merge a patch to the
2.6 kernel, so I think that the answer to that is a really clear 'No.'

> 4. Does it make anything worse?  A lot or a little?  Rare corner
> cases, or a real world usage?  Again, numbers make the case most
> strongly.
>
> I can't say I've been following this particular feature very closely,
> but these are the fundamental questions that need to be dealt with in
> merging any significant change.  And as Nick says, historically point 4
> is very important in VM tuning changes, because "obvious" improvements
> have often ended up giving pathologically bad results on unexpected
> workloads.

Dude. My whole question was *what* numbers. Please go back and read it
all again. Maybe I was unclear, but I really don't think so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
