Received: by qb-out-0506.google.com with SMTP id e21so2299975qba
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 10:33:29 -0700 (PDT)
Message-ID: <a781481a0707251033t5b95cde7k620810bcc0b98c1@mail.gmail.com>
Date: Wed, 25 Jul 2007 23:03:28 +0530
From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <20070725135016.GA18633@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <46A6CC56.6040307@yahoo.com.au>
	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	 <46A6DFFD.9030202@gmail.com>
	 <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com>
	 <20070725082822.GA13098@elte.hu> <46A70D37.3060005@gmail.com>
	 <5c77e14b0707250353r48458316x5e6adde6dbce1fbd@mail.gmail.com>
	 <46A75062.1050809@gmail.com> <20070725135016.GA18633@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rene Herman <rene.herman@gmail.com>, Jos Poortvliet <jos@mijnkamer.nl>, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Valdis.Kletnieks@vt.edu, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Ingo,

[ Going off-topic, nothing related to swap/prefetch/etc. Just getting
a hang of how development goes on here ... ]

On 7/25/07, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Rene Herman <rene.herman@gmail.com> wrote:
>
> > Nick Piggin is the person to convince it seems and if I've read things
> > right (I only stepped into this thing at the updatedb mention, so
> > maybe I haven't) his main question is _why_ the hell it helps
> > updatedb. [...]
>
> btw., i'd like to make this clear: if you want stuff to go upstream, do
> not concentrate on 'convincing the maintainer'.

It's not so easy or clear-cut, see below.

> Instead concentrate on understanding the _problem_,

Of course -- that's a given.

> concentrate on
> making sure that both you and the maintainer understands the problem
> correctly,

This itself may require some "convincing" to do. What if the maintainer
just doesn't recognize the problem? Note that the development model
here is more about the "social" thing than purely a "technical" thing.
People do handwave, possibly due to innocent misunderstandings,
possibly without. Often it's just a case of seeing different reasons behind
the "problematic behaviour". Or it could be a case of all of the above.

> possibly write some testcase that clearly exposes it, and

Oh yes -- that'll be helpful, but definitely not necessarily a prerequisite
for all issues, and then you can't even expect everybody to write or
test/benchmark with testcases. (oh, btw, this is assuming you do find
consensus on a testcase)

> help the maintainer debug the problem.

Umm ... well. Should this "dance-with-the-maintainer" and all be really
necessary? What you're saying is easy if a "bug" is simple and objective,
with mathematically few (probably just one) possible correct solutions.
Often (most often, in fact) it's a subjective issue -- could be about APIs,
high level design, tradeoffs, even little implementation nits ... with one
person wanting to do it one way, another thinks there's something hacky
or "band-aidy" about it and a more beautiful/elegant solution exists elsewhere.
I think there's a similar deadlock here (?)

> _Optionally_, if you find joy in
> it, you are also free to write a proposed solution for that problem

Oh yes. But why "optionally"? This is *precisely* what the spirit of
development in such open / distributed projects is ... unless Linux
wants to die the same, slow, ivory-towered, miserable death that
*BSD have.

> and
> submit it to the maintainer.

Umm, ok ... pretty unlikely Linus or Andrew would take patches for any
kernel subsystem (that isn't obvious/trivial) from anybody just like that,
so you do need to Cc: the ones they trust (maintainer) to ensure they
review/ack your work and pick it up.

> But a "here is a solution, take it or leave it" approach,

Agreed. That's definitely not the way to go.

> before having
> communicated the problem to the maintainer

Umm, well this could depend from problem-to-problem.

> and before having debugged
> the problem

Again, agreed -- but people can plausibly see different root causes for
the same symptoms -- and different solutions.

> is the wrong way around. It might still work out fine if the
> solution is correct (especially if the patch is small and obvious), but
> if there are any non-trivial tradeoffs involved, or if nontrivial amount
> of code is involved, you might see your patch at the end of a really
> long (and constantly growing) waiting list of patches.

That's the whole point. For non-trivial / non-obvious / subjective issues,
the "process" you laid out above could itself become a problem ...

Satyam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
