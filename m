Received: by mu-out-0910.google.com with SMTP id g7so248563muf
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 08:30:02 -0700 (PDT)
Message-ID: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>
Date: Wed, 25 Jul 2007 17:30:02 +0200
From: "Kacper Wysocki" <kacperw@online.no>
Subject: howto get a patch merged (WAS: Re: -mm merge plans for 2.6.23)
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rene Herman <rene.herman@gmail.com>, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Valdis.Kletnieks@vt.edu, Ray Lee <ray-lk@madrabbit.org>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Jesper Juhl <jesper.juhl@gmail.com>
List-ID: <linux-mm.kvack.org>

On 7/25/07, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Rene Herman <rene.herman@gmail.com> wrote:
>
> > Nick Piggin is the person to convince it seems and if I've read things
> > right (I only stepped into this thing at the updatedb mention, so
> > maybe I haven't) his main question is _why_ the hell it helps
> > updatedb. [...]
[snip howto get a patch merged]
> But a "here is a solution, take it or leave it" approach, before having
> communicated the problem to the maintainer and before having debugged
> the problem is the wrong way around. It might still work out fine if the
> solution is correct (especially if the patch is small and obvious), but
> if there are any non-trivial tradeoffs involved, or if nontrivial amount
> of code is involved, you might see your patch at the end of a really
> long (and constantly growing) waiting list of patches.

Is that what happened with swap prefetch these two years? The approach
has been wrong?

In this particular instance, there are lots of people who have looked
at, tried, tested, reported on, advocated, and most importantly -been
using for several years- swap prefetch. That's a lot of people, it's
hard to coordinate a unified approach, eh?

You are the gatekeepers. The dudes with the keys. The guys who must
claim technical and moral superiority over the rabble, the rest of us.

I always believed that the linux development model consisted of
collaboration with technical merit as the prime goal in mind. But the
sheer volume of patches and the small number of keyholders precludes
such a scenario. So the gatekeepers have trusted advisors, and it's
quicker to look at numbers than to try out all the random (and often
crappy) patches that flow in.

It's easier to ask for more testing, more feedback, more "unbiased",
easier to just drop it rather than to look at the new code itself.
It's easier and less risky to try and understand a problem yourself,
and write your own code. After all, you trust your own code, right?

Life is so much simpler without any alien objects around.
However, cool things usually come from outside such a stable environment.

The problem isn't debugging the wrong way around. The problem is no
matter how many people read it, test it, use it, brag about it,
measure it, it doesn't matter at all unless they can convince one of
these few dudes that he should really turn that key.

0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
