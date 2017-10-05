Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id D43C46B0038
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 14:49:08 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id d12so9512473uaj.18
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 11:49:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a22sor28033itd.93.2017.10.05.11.49.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 11:49:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57ad0ef1-e147-8507-9922-aa72ad47350e@kernel.dk>
References: <20171005004924.GA23053@beast> <4d4ccf50-d0b6-a525-dc73-0d64d26da68a@kernel.dk>
 <CAGXu5jJA4jfZCnhjLrO6fePVJqoJw7Hj7VF1sGLimU2fFu4AgQ@mail.gmail.com> <57ad0ef1-e147-8507-9922-aa72ad47350e@kernel.dk>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 5 Oct 2017 11:49:06 -0700
Message-ID: <CAGXu5j+g6PoJ_e_CVNt-QWrtfA+TZt1=0MExbZygSffMt7yK6A@mail.gmail.com>
Subject: Re: [PATCH] block/laptop_mode: Convert timers to use timer_setup()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Oct 5, 2017 at 11:26 AM, Jens Axboe <axboe@kernel.dk> wrote:
> Honestly, I think the change should have waited for 4.15 in that case.
> Why the rush? It wasn't ready for the merge window.

My understanding from my discussion with tglx was that if the API
change waiting for 4.15, then the conversions would have to wait until
4.16. With most conversions only depending on the new API, it seemed
silly to wait another whole release when the work is just waiting to
be merged.

But yes, timing was not ideal. I did try to get it in earlier, but I
think tglx was busy with other concerns.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
