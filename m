Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 245446B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 15:49:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so20495713pfc.7
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 12:49:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y4sor2307625pgp.16.2017.10.05.12.49.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 12:49:42 -0700 (PDT)
Subject: Re: [PATCH] block/laptop_mode: Convert timers to use timer_setup()
From: Jens Axboe <axboe@kernel.dk>
References: <20171005004924.GA23053@beast>
 <4d4ccf50-d0b6-a525-dc73-0d64d26da68a@kernel.dk>
 <CAGXu5jJA4jfZCnhjLrO6fePVJqoJw7Hj7VF1sGLimU2fFu4AgQ@mail.gmail.com>
 <57ad0ef1-e147-8507-9922-aa72ad47350e@kernel.dk>
 <alpine.DEB.2.20.1710052102480.2398@nanos>
 <a74e292d-a0c5-6e75-576b-bb29580028e2@kernel.dk>
Message-ID: <c04f0253-4ed5-3c3e-d9c5-0263ab277b8c@kernel.dk>
Date: Thu, 5 Oct 2017 13:49:38 -0600
MIME-Version: 1.0
In-Reply-To: <a74e292d-a0c5-6e75-576b-bb29580028e2@kernel.dk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On 10/05/2017 01:41 PM, Jens Axboe wrote:
> On 10/05/2017 01:23 PM, Thomas Gleixner wrote:
>> On Thu, 5 Oct 2017, Jens Axboe wrote:
>>> On 10/05/2017 11:49 AM, Kees Cook wrote:
>>>> Yes, totally true. tglx and I ended up meeting face-to-face at the
>>>> Kernel Recipes conference and we solved some outstanding design issues
>>>> with the conversion. The timing meant the new API went into -rc3,
>>>> which seemed better than missing an entire release cycle, or carrying
>>>> deltas against maintainer trees that would drift. (This is actually my
>>>> second massive refactoring of these changes...)
>>>
>>> Honestly, I think the change should have waited for 4.15 in that case.
>>> Why the rush? It wasn't ready for the merge window.
>>
>> Come on. You know very well that a prerequisite for global changes which is
>> not yet used in Linus tree can get merged post merge windew in order to
>> avoid massive inter maintainer tree dependencies. We've done that before.
> 
> My point is that doing it this late makes things harder than they should
> have been. If this was in for -rc1, it would have made things a lot
> easier. Or even -rc2. I try and wait to fork off the block tree for as
> long as I can, -rc2 is generally where that happens.

Timing of the change aside, this patch doesn't even apply to the 4.15
block tree:

checking file block/blk-core.c
checking file include/linux/writeback.h
Hunk #1 succeeded at 309 (offset -20 lines).
checking file mm/page-writeback.c
Hunk #1 FAILED at 1977.
Hunk #2 FAILED at 1988.
2 out of 2 hunks FAILED

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
