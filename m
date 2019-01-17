Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CCAA8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 04:54:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so3477570ede.14
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 01:54:39 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n15si1919143edb.101.2019.01.17.01.54.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 01:54:37 -0800 (PST)
Date: Thu, 17 Jan 2019 10:52:03 +0100
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190117095203.GA23942@rei.lan>
References: <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
 <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica>
 <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm>
 <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
 <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm>
 <20190116213708.GN6310@bombadil.infradead.org>
 <nycvar.YFH.7.76.1901162238310.6626@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1901162238310.6626@cbobk.fhfr.pm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Hi!
> > Your patch 3/3 just removes the test.  Am I right in thinking that it
> > doesn't need to be *moved* because the existing test after !PageUptodate
> > catches it?
> 
> Exactly. It just initiates read-ahead for IOCB_NOWAIT cases as well, and 
> if it's actually set, it'll be handled by the !PageUpdtodate case.
> 
> > Of course, there aren't any tests for RWF_NOWAIT in xfstests.  Are there 
> > any in LTP?
> 
> Not in the released version AFAIK. I've asked the LTP maintainer (in our 
> internal bugzilla) to take care of this thread a few days ago, but not 
> sure what came out of it. Adding him (Cyril) to CC.

So far not much, I've looked over our mincore() tests and noted down how
to improve them here:

https://github.com/linux-test-project/ltp/issues/461

We do plan to test the final mincore() fix:

https://github.com/linux-test-project/ltp/issues/460

And we do have RWF_NOWAIT tests on our TODO for some time as well:

https://github.com/linux-test-project/ltp/issues/286

I guess I can raise priority for that one so that we have basic
functional tests in a week or so. Also if anyone has some RWF_NOWAIT
tests already it would be nice if these could be shared with us.


[A bit off topic rant]

I've been telling kernel developers for years that if they have a test
code they used when developing a kernel feature that they should share
it with us (LTP community) and we will turn these into automated tests
and maintain them for free. LTP is also used in many QA departements
around the word so such tests will end up executed in different
environments also for free. Sadly this does not happen much and there
are only few exceptions so far. But maybe I wasn't shouting loudly
enough.

-- 
Cyril Hrubis
chrubis@suse.cz
