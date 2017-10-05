Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF9D26B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 10:56:54 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g18so12301642itg.1
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 07:56:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o195sor7327112ioe.241.2017.10.05.07.56.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 07:56:53 -0700 (PDT)
Subject: Re: [PATCH] block/laptop_mode: Convert timers to use timer_setup()
References: <20171005004924.GA23053@beast>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <4d4ccf50-d0b6-a525-dc73-0d64d26da68a@kernel.dk>
Date: Thu, 5 Oct 2017 08:56:51 -0600
MIME-Version: 1.0
In-Reply-To: <20171005004924.GA23053@beast>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On 10/04/2017 06:49 PM, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Jeff Layton <jlayton@redhat.com>
> Cc: linux-block@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> This requires commit 686fef928bba ("timer: Prepare to change timer
> callback argument type") in v4.14-rc3, but should be otherwise
> stand-alone.

My only complaint about this is the use of a from_timer() macro instead
of just using container_of() at the call sites to actually show that is
happening. I'm generally opposed to obfuscation like that. It just means
you have to look up what is going on, instead of it being readily
apparent to the reader/reviewer.

I guess I do have a a second complaint as well - that it landed in -rc3,
which is rather late considering subsystem trees are usually forked
earlier than that. Had this been in -rc1, I would have had an easier
time applying the block bits for 4.15.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
