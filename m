Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 964176B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 23:51:10 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so10535658ioi.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 20:51:10 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id l128si1062913ioe.149.2015.09.03.20.51.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 20:51:10 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so7997042igb.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 20:51:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150904032607.GX1933@devil.localdomain>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
	<CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com>
	<20150904032607.GX1933@devil.localdomain>
Date: Thu, 3 Sep 2015 20:51:09 -0700
Message-ID: <CA+55aFzBTL=DnC4zv6yxjk0HxwxWpOhpKDPA8zkTGdgbh08sEg@mail.gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 3, 2015 at 8:26 PM, Dave Chinner <dchinner@redhat.com> wrote:
>
> The double standard is the problem here. No notification, proof,
> discussion or review was needed to turn on slab merging for
> everyone, but you're setting a very high bar to jump if anyone wants
> to turn it off in their code.

Ehh. You realize that almost the only load that is actually seriously
allocator-limited is networking?

And slub was beating slab on that? And slub has been doing the merging
since day one. Slab was just changed to try to keep up with the
winning strategy.

Really. You seem to think that this merging thing is new. It's really
not. Where did you miss the part that it's been done since 2007?

It's only new for slab, and the reason it was introduced for slab was
that it was losing most relevant benchmarks to slub.

So do you now want a "SLAB_NO_MERGE_IF_NOT_SLUB" flag, which keeps the
traditional behavior for slab and slub? Just because its' traditional?
One that says "if the allocator is slub, then merge, but if the
allocator is slab, then don't merge".

Really, Dave. You have absolutely nothing to back up your points with.
Merging is *not* some kind of "new" thing that was silently enabled
recently to take you by surprise.

That seems to be your *only* argument: that the behavior changed
behind your back. IT IS NOT TRUE. It's only true since you don't seem
to realize that a large portion of the world moved on to SLUB a long
time ago.

Do you seriously believe that a "SLAB_NO_MERGE_IF_NOT_SLUB" flag is a
good idea, just to justify your position of "let's keep the merging
behavior the way it has been"?

Or do you seriously think that it's a good idea to take the
non-merging behavior from the allocator that was falling behind?

So no. The switch to merging behavior was not some kind of "no
discussion" thing. It was very much part of the whole original _point_
of SLUB. And the point of having allocator choices was to see which
one worked best.

SLUB essentially won. We could have just deleted SLAB. I don't think
that would necessarily have been a bad idea. Instead, slab was taught
to try to do some of the same things that worked for slub.

At what point do you just admit that your arguments aren't holding water?

So the fact remains: if you can actually show that not merging is a
good idea for particular slabs, then that's real data. But right now
you are just ignoring the real data and the SLUB  we've had over the
years.

And if you continue to spout nonsense about "silent behavioral
changes", the only thing you show is that you don't know what the hell
you are talking about.

So your claim of "double standard" is pure and utter shit. Get over it.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
