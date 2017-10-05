Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB086B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 18:58:46 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id 137so7801112vkk.11
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 15:58:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n184sor187947itg.118.2017.10.05.15.58.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 15:58:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <763df3b2-dc7e-d68f-a4ea-b7d0d45dc111@kernel.dk>
References: <20171005004924.GA23053@beast> <4d4ccf50-d0b6-a525-dc73-0d64d26da68a@kernel.dk>
 <CAGXu5jJA4jfZCnhjLrO6fePVJqoJw7Hj7VF1sGLimU2fFu4AgQ@mail.gmail.com>
 <57ad0ef1-e147-8507-9922-aa72ad47350e@kernel.dk> <alpine.DEB.2.20.1710052102480.2398@nanos>
 <a74e292d-a0c5-6e75-576b-bb29580028e2@kernel.dk> <alpine.DEB.2.20.1710052335030.2398@nanos>
 <763df3b2-dc7e-d68f-a4ea-b7d0d45dc111@kernel.dk>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 5 Oct 2017 15:58:44 -0700
Message-ID: <CAGXu5j+TajC1bAWhdyFr3eXCKeMEDQx6UViShkUZr3dBQ7xWow@mail.gmail.com>
Subject: Re: [PATCH] block/laptop_mode: Convert timers to use timer_setup()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Thu, Oct 5, 2017 at 3:07 PM, Jens Axboe <axboe@kernel.dk> wrote:
> Yes, it's not impossible, I just usually prefer not to. For this case, I
> just setup a for-4.15/timer, that is the current block branch with -rc3
> pulled in. I applied the two patches for floppy and amiflop, I'm
> assuming Kees will respin the writeback/laptop version and I can shove
> that in there too.

Thanks for setting this up! I'll respin and send it out again.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
