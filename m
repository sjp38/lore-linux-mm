Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3702D8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 02:04:01 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so5741024pgb.7
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 23:04:01 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id i5si8841597pfo.189.2019.01.09.23.03.58
        for <linux-mm@kvack.org>;
        Wed, 09 Jan 2019 23:03:59 -0800 (PST)
Date: Thu, 10 Jan 2019 18:03:55 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190110070355.GJ27534@dastard>
References: <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard>
 <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard>
 <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 09, 2019 at 05:18:21PM -0800, Linus Torvalds wrote:
> On Wed, Jan 9, 2019 at 4:44 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > I wouldn't look at ext4 as an example of a reliable, problem free
> > direct IO implementation because, historically speaking, it's been a
> > series of nasty hacks (*cough* mount -o dioread_nolock *cough*) and
> > been far worse than XFS from data integrity, performance and
> > reliability perspectives.
> 
> That's some big words from somebody who just admitted to much worse hacks.

Sorry, what hacks did I just admit to making? This O_DIRECT
behaviour long predates me - I'm just the messenger and you are
shooting from the hip.

Linus, the point I was making is that there are many, many ways to
control page cache invalidation and measure page cache residency,
and that trying to address them one-by-one is just a game of
whack-a-mole.

In future, can you please try not to go off the rails when someone
mentions O_DIRECT? You have a terrible habit of going off on
misdirected rants about O_DIRECT and/or XFS at any opportunity you
can get, and all it does is derail whatever useful conversation was
taking place.

> Seriously. XFS is buggy in this regard, ext4 apparently isn't.

So you keep asserting despite being presented with evidence that it
mitigates other longstanding bugs that are really hard to solve.
Ignoring all the evidence you've been presented with and
re-asserting your original statement doesn't make it correct.

Did you not think to ask "what are those problems, and what can do
to solve them so we can remove the invalidation mitigations that XFS
uses?". That would be a useful contribution, whereas shouting about
how O_DIRECT is broken just pisses off the people working their
asses off to fix the problems you just heard about and are ranting
about.

> Thinking that it's better to just invalidate the cache  for direct IO
> reads is all kinds of odd.

No, it's practicality. If we can't fix the problem, we have to
mitigate it. When we fix the underlying problem we can remove the
mitigation code. having you assert that it's broken and demand that
it be removed doesn't change the fact that we haven't fixed the
underlying problems. It's being worked on, but we're not there yet.

-Dave.
-- 
Dave Chinner
david@fromorbit.com
