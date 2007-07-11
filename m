Received: by ik-out-1112.google.com with SMTP id c28so1144387ika
        for <linux-mm@kvack.org>; Tue, 10 Jul 2007 23:04:59 -0700 (PDT)
Message-ID: <2c0942db0707102304s3f666eceib454043c716e2178@mail.gmail.com>
Date: Tue, 10 Jul 2007 23:04:59 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <469470A3.5040606@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <b21f8390707101802o2d546477n2a18c1c3547c3d7a@mail.gmail.com>
	 <20070710181419.6d1b2f7e.akpm@linux-foundation.org>
	 <b21f8390707101954s3ae69db8vc30287277941cb1f@mail.gmail.com>
	 <4694683B.3060705@yahoo.com.au>
	 <2c0942db0707102247n3b6e5933i9803a2161d6c00b1@mail.gmail.com>
	 <469470A3.5040606@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matthew Hawkins <darthmdh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Con Kolivas <kernel@kolivas.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/10/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> >> OK that's a good data point. It would be really good to be able to
> >> do an analysis on your overnight IO patterns and the corresponding
> >> memory reclaim behaviour and see why things are getting evicted.
> >
> > Eviction can happen for multiple reasons, as I'm sure you're painfully
> > aware. It can happen because of poor balancing choices, or it can
>
> s/balancing/reclaim, yes. And for the nightly cron job case, this is
> could quite possibly be the cause. At least updatedb should be fairly
> easy to apply use-once heuristics for, so if they're not working then
> we should hopefully be able to improve it.

<nod> Sorry, I'm not so clear on the terminology, am I.

So, that's one part of it: one could argue that for that bit swap
prefetch is a bit of a band-aid over the issue. A useful band-aid,
that works today, isn't invasive, and can be ripped out at some future
time if the underlying issue is eventually solved by a proper use-once
aging mechanism, but nevertheless a band-aid.

The other part is when I've got evolution and a few other things open,
then I run gimp on a raw photo and do some work on it, quit out of
gimp, do a couple of things in a shell to upload the photo to my
server, then switch back to evolution. Hang, waiting on swap in. Well,
the kernel had some free time there to repopulate evolution's working
set, and swap prefetch would help that, while better (or perfect!)
heuristics in the reclaim *won't*.

That's the real issue here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
