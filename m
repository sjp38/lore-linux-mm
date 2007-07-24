Received: by hu-out-0506.google.com with SMTP id 32so1651925huf
        for <linux-mm@kvack.org>; Mon, 23 Jul 2007 23:01:41 -0700 (PDT)
Message-ID: <2c0942db0707232301o5ab428bdrd1bc831cacf806c@mail.gmail.com>
Date: Mon, 23 Jul 2007 23:01:41 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <20070723221846.d2744f42.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <20070723221846.d2744f42.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/23/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> Let it just be noted that Con is not the only one who has expended effort
> on this patch.  It's been in -mm for nearly two years and it has meant
> ongoing effort for me and, to a lesser extent, other MM developers to keep
> it alive.

<nods> Yes, keeping patches from crufting up and stepping on other
patches' toes is hard work; I did it for a bit, and it was one of the
more thankless tasks I've tried a hand at.

So, thanks.

> Critera are different for each patch, but it usually comes down to a
> cost/benefit judgement.  Does the benefit of the patch exceed its
> maintenance cost over the lifetime of the kernel (whatever that is).

Well, I suspect it's 'lifetime of the feature,' in this case as it's
no more user visible than the page replacement algorithm in the first
place.

> The other consideration here is, as Nick points out, are the problems which
> people see this patch solving for them solveable in other, better ways?
> IOW, is this patch fixing up preexisting deficiencies post-facto?

In some cases, it almost certainly is. It also has the troubling
aspect of mitigating future regressions without anyone terribly
noticing, due to it being able to paper over those hypothetical future
deficiencies when they're introduced.

> To attack the second question we could start out with bug reports: system A
> with workload B produces result C.  I think result C is wrong for <reasons>
> and would prefer to see result D.

I spend a lot of time each day watching my computer fault my
workingset back in when I switch contexts. I'd rather I didn't have to
do that. Unfortunately, that's a pretty subjective problem report. For
whatever it's worth, we have pretty subjective solution reports
pointing to swap prefetch as providing a fix for them.

My concern is that a subjective problem report may not be good enough.
So, what do I measure to make this an objective problem report? And if
I do that (and it shows a positive result), will that be good enough
to argue for inclusion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
