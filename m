Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA276B0253
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 15:41:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i195so30900388pgd.2
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 12:41:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g7sor2252873plp.97.2017.10.05.12.41.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 12:41:20 -0700 (PDT)
Subject: Re: [PATCH] block/laptop_mode: Convert timers to use timer_setup()
References: <20171005004924.GA23053@beast>
 <4d4ccf50-d0b6-a525-dc73-0d64d26da68a@kernel.dk>
 <CAGXu5jJA4jfZCnhjLrO6fePVJqoJw7Hj7VF1sGLimU2fFu4AgQ@mail.gmail.com>
 <57ad0ef1-e147-8507-9922-aa72ad47350e@kernel.dk>
 <alpine.DEB.2.20.1710052102480.2398@nanos>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <a74e292d-a0c5-6e75-576b-bb29580028e2@kernel.dk>
Date: Thu, 5 Oct 2017 13:41:17 -0600
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1710052102480.2398@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On 10/05/2017 01:23 PM, Thomas Gleixner wrote:
> On Thu, 5 Oct 2017, Jens Axboe wrote:
>> On 10/05/2017 11:49 AM, Kees Cook wrote:
>>> Yes, totally true. tglx and I ended up meeting face-to-face at the
>>> Kernel Recipes conference and we solved some outstanding design issues
>>> with the conversion. The timing meant the new API went into -rc3,
>>> which seemed better than missing an entire release cycle, or carrying
>>> deltas against maintainer trees that would drift. (This is actually my
>>> second massive refactoring of these changes...)
>>
>> Honestly, I think the change should have waited for 4.15 in that case.
>> Why the rush? It wasn't ready for the merge window.
> 
> Come on. You know very well that a prerequisite for global changes which is
> not yet used in Linus tree can get merged post merge windew in order to
> avoid massive inter maintainer tree dependencies. We've done that before.

My point is that doing it this late makes things harder than they should
have been. If this was in for -rc1, it would have made things a lot
easier. Or even -rc2. I try and wait to fork off the block tree for as
long as I can, -rc2 is generally where that happens.

> There are only a few options we have for such global changes:
> 
>    - Delay everything for a full release and keep hunting the ever changing
>      code and the new users of old interfaces, which is a pain in the
>      butt. I know what I'm talking about.

Not disagreeing with that it's a pain in the butt. The timing is the
main reason why that is the case, though.

>    - Apply everything in a central tree, which is prone to merge conflicts
>      in next when maintainer trees contain changes in the same area. So
>      getting it through the maintainers is the best option for this kind of
>      stuff.

Don't disagree with that either.

>    - Create a separate branch for other maintainers to pull, which I did
>      often enough in the past to avoid merge dependencies.  I decided not
>      to offer that branch this time, because it would be been necessary to
>      pull it into a gazillion of trees. So we decided that Linus tree as a
>      dependency is good enough.
> 
>      Just for the record:
> 
>      Last time I did this for block you did not complain, that you got
>      something based on -rc3 from me because you wanted to have these
>      changes in your tree so you could apply the depending multi-queue
>      patches. tip irq/for-block exists for a reason.
> 
>      So what's the difference to pull -rc3 this time? Nothing, just the
>      fact that you are not interested in the change.
> 
>      So please stop this hypocritical ranting right here.

I'm not judging this based on whether I find it interesting or not, but
rather if it's something that's generally important to get in. Maybe it
is, but I don't see any justification for that at all. So just looking
at the isolated change, it does not strike me as something that's
important enough to warrant special treatment (and the pain associated
with that). I don't care about the core change, it's obviously trivial.
Expecting maintainers to pick up this dependency asap mid cycle is what
sucks.

Please stop accusing me of being hypocritical. I'm questionning the
timing of the change, that should be possible without someone resorting
to ad hominem attacks.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
