Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 145586B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 22:50:11 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p82-v6so28177itc.0
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 19:50:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m6-v6sor2969921itb.76.2018.07.05.19.50.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 19:50:10 -0700 (PDT)
MIME-Version: 1.0
References: <201807050305.w653594Q081552@www262.sakura.ne.jp>
 <20180705071740.GC32658@dhcp22.suse.cz> <201807060240.w662e7Q1016058@www262.sakura.ne.jp>
In-Reply-To: <201807060240.w662e7Q1016058@www262.sakura.ne.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 5 Jul 2018 19:49:58 -0700
Message-ID: <CA+55aFz87+iXZ_N5jYgo9UFFJ2Tc9dkMLPxwscriAdDKoyF0CA@mail.gmail.com>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup problem.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Thu, Jul 5, 2018 at 7:40 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> >
> > No, direct reclaim is a way to throttle allocations to the reclaim
> > speed. You would have to achive the same by other means.
>
> No. Direct reclaim is a way to lockup the system to unusable level, by not giving
> enough CPU resources to memory reclaim activities including the owner of oom_lock.

No. Really.

Direct reclaim really really does what Michal claims. Yes, it has
other effects too, and it can be problematic, but direct reclaim is
important.

People have tried to remove it many times, but it's always been a
disaster. You need to synchronize with _something_ to make sure that
the thread that is causing a lot of allocations actually pays the
price, and slows down.

You want to have a balance between direct and indirect reclaim.

If you think direct reclaim is only a way to lock up the system to
unusable levels, you should stop doing VM development.

                   Linus
