Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43B4D6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 14:56:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i195so30739530pgd.2
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 11:56:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 2sor2149238pgi.253.2017.10.05.11.56.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 11:56:27 -0700 (PDT)
Subject: Re: [PATCH] block/laptop_mode: Convert timers to use timer_setup()
References: <20171005004924.GA23053@beast>
 <4d4ccf50-d0b6-a525-dc73-0d64d26da68a@kernel.dk>
 <CAGXu5jJA4jfZCnhjLrO6fePVJqoJw7Hj7VF1sGLimU2fFu4AgQ@mail.gmail.com>
 <57ad0ef1-e147-8507-9922-aa72ad47350e@kernel.dk>
 <CAGXu5j+g6PoJ_e_CVNt-QWrtfA+TZt1=0MExbZygSffMt7yK6A@mail.gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <57556968-319c-b259-d8a7-164e6e6600a8@kernel.dk>
Date: Thu, 5 Oct 2017 12:56:23 -0600
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+g6PoJ_e_CVNt-QWrtfA+TZt1=0MExbZygSffMt7yK6A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>

On 10/05/2017 12:49 PM, Kees Cook wrote:
> On Thu, Oct 5, 2017 at 11:26 AM, Jens Axboe <axboe@kernel.dk> wrote:
>> Honestly, I think the change should have waited for 4.15 in that case.
>> Why the rush? It wasn't ready for the merge window.
> 
> My understanding from my discussion with tglx was that if the API
> change waiting for 4.15, then the conversions would have to wait until
> 4.16. With most conversions only depending on the new API, it seemed
> silly to wait another whole release when the work is just waiting to
> be merged.

Right, it would have shifted everything a release. But that's how we do
things! If something isn't ready _before_ the merge window, let alone
talking -rc3 time, then it gets to wait unless it's fixing a regression
introduced in the merge window. Or if you can argue that it's a really
critical fix, sure, it can be squeezed in.

I'm puzzled why anyone would think that this is any different. What I'm
hearing here is that "I didn't want to wait, and my change is more
important than others", as an argument for why this should be treated
any differently.

I'm not saying the change is bad, it looks trivial, from_timer()
discussion aside. But it's not a critical fix, by any stretch of the
imagination, and neither are the driver conversions. With this
additionally causing extra problems because of the timing, that's just
further proof that it should have waited.

> But yes, timing was not ideal. I did try to get it in earlier, but I
> think tglx was busy with other concerns.

So it should have waited...

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
