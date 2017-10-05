Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA6E76B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 15:23:31 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j204so2724305lfe.8
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 12:23:31 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 138si28428wmt.83.2017.10.05.12.23.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 12:23:30 -0700 (PDT)
Date: Thu, 5 Oct 2017 21:23:10 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] block/laptop_mode: Convert timers to use timer_setup()
In-Reply-To: <57ad0ef1-e147-8507-9922-aa72ad47350e@kernel.dk>
Message-ID: <alpine.DEB.2.20.1710052102480.2398@nanos>
References: <20171005004924.GA23053@beast> <4d4ccf50-d0b6-a525-dc73-0d64d26da68a@kernel.dk> <CAGXu5jJA4jfZCnhjLrO6fePVJqoJw7Hj7VF1sGLimU2fFu4AgQ@mail.gmail.com> <57ad0ef1-e147-8507-9922-aa72ad47350e@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Thu, 5 Oct 2017, Jens Axboe wrote:
> On 10/05/2017 11:49 AM, Kees Cook wrote:
> > Yes, totally true. tglx and I ended up meeting face-to-face at the
> > Kernel Recipes conference and we solved some outstanding design issues
> > with the conversion. The timing meant the new API went into -rc3,
> > which seemed better than missing an entire release cycle, or carrying
> > deltas against maintainer trees that would drift. (This is actually my
> > second massive refactoring of these changes...)
> 
> Honestly, I think the change should have waited for 4.15 in that case.
> Why the rush? It wasn't ready for the merge window.

Come on. You know very well that a prerequisite for global changes which is
not yet used in Linus tree can get merged post merge windew in order to
avoid massive inter maintainer tree dependencies. We've done that before.

There are only a few options we have for such global changes:

   - Delay everything for a full release and keep hunting the ever changing
     code and the new users of old interfaces, which is a pain in the
     butt. I know what I'm talking about.

   - Apply everything in a central tree, which is prone to merge conflicts
     in next when maintainer trees contain changes in the same area. So
     getting it through the maintainers is the best option for this kind of
     stuff.

   - Create a separate branch for other maintainers to pull, which I did
     often enough in the past to avoid merge dependencies.  I decided not
     to offer that branch this time, because it would be been necessary to
     pull it into a gazillion of trees. So we decided that Linus tree as a
     dependency is good enough.

     Just for the record:

     Last time I did this for block you did not complain, that you got
     something based on -rc3 from me because you wanted to have these
     changes in your tree so you could apply the depending multi-queue
     patches. tip irq/for-block exists for a reason.

     So what's the difference to pull -rc3 this time? Nothing, just the
     fact that you are not interested in the change.

     So please stop this hypocritical ranting right here.

Thanks,

	tglx






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
