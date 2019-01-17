Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C50F8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 20:26:51 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so5028215plr.8
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 17:26:51 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id m20si75388pgk.323.2019.01.16.17.26.48
        for <linux-mm@kvack.org>;
        Wed, 16 Jan 2019 17:26:49 -0800 (PST)
Date: Thu, 17 Jan 2019 12:26:45 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190117012645.GU4205@dastard>
References: <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard>
 <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard>
 <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
 <20190111073606.GP27534@dastard>
 <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
 <20190115234510.GA6173@dastard>
 <CAHk-=wjc2inOae8+9-DK4jFK78-7ZpNR=TEyZg0Dj57SYwP-ng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wjc2inOae8+9-DK4jFK78-7ZpNR=TEyZg0Dj57SYwP-ng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 16, 2019 at 04:54:49PM +1200, Linus Torvalds wrote:
> On Wed, Jan 16, 2019 at 11:45 AM Dave Chinner <david@fromorbit.com> wrote:
> >
> > I'm assuming that you can invalidate the page cache reliably by a
> > means that does not repeated require probing to detect invalidation
> > has occurred. I've mentioned one method in this discussion
> > already...
> 
> Yes. And it was made clear to you that it was a bug in xfs dio and
> what the right thing to do was.
> 
> And you ignored that, and claimed it was a feature.

Linus, either you aren't listening or you're being intentionally
provocative.

So, for the *third* time this thread: we can probably remove this
code but first we need to be sure it doesn't cause unexpected
regressions before we commit such a change. We are not cowboys who
test userspace behavioural changes on users without review or
discussion.

Indeed, I wrote a patch to remove the invalidation /several days
ago/ and put it into my test trees, and it's been there since. Just
because you don't see immediate changes doesn't mean it isn't
happening.

> Either you care or you don't. If you don't care (and so far everything
> you said seems to imply you don't),

Linus, this is just a personal attack and IMO a violation of the
CoC.  It's straight out wrong, insulting, totally unprofessional and
completely uncalled for.

This is most definitely not a useful technical response to the
issues I raised. i.e you cut out all the context of my response
about whether "no probing necessary" page cache invalidation attacks
are something we need to care about in the future. We don't need you
to shout about existing "no probing necessary" page cache
invalidation attacks that are already being addressed, we need to
determine if it's going to be a recurring problem in future because
that directly affects the mitigation strategies we can implement.

-Dave.
-- 
Dave Chinner
david@fromorbit.com
