Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39328C5ACAE
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 03:05:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1AA82084F
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 03:05:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1AA82084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6334F6B0003; Wed, 11 Sep 2019 23:05:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E2C86B0005; Wed, 11 Sep 2019 23:05:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D1E56B0006; Wed, 11 Sep 2019 23:05:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0180.hostedemail.com [216.40.44.180])
	by kanga.kvack.org (Postfix) with ESMTP id 274B76B0003
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 23:05:48 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9F9591E085
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:05:47 +0000 (UTC)
X-FDA: 75924778734.11.brush59_4f95911b6cb63
X-HE-Tag: brush59_4f95911b6cb63
X-Filterd-Recvd-Size: 10774
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:05:46 +0000 (UTC)
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 99F27C04BD33
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:05:45 +0000 (UTC)
Received: by mail-pl1-f200.google.com with SMTP id 70so4436060ple.1
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 20:05:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=nG3/jJUlf8fUtZ/Upol47uTiEuf72L05OZhbWxnHNM0=;
        b=nc31vwoCnbY5Va1iQjR26huYpXHrFoUL+MvS7E7ZSaYQYVi9kX7L9ILplz1utCZ9SU
         0eYCw+4+nZvW3w1z7FUGh+VLuf9gbj2PM9zJu20428bk0Ro9f5tVgFaGwNDfK4jmRgOb
         B3aybbo6zfMUED3k9rXczuYNQEDLdwlAxSKkeB1ZHKJ1QUVqisrg7P7HhVeGVx0hktq5
         aHMMa6gKMofDTXPfRff5ZpqclKWzauXRpVxT0iQpXUjlL5sY7I7QjNzoBEKJOJX9uwzB
         7wtNx6sRpgbfuw3MUivTtPdOO6YTkulRHxvPIvVJnwvLqeHLhD4iM0FoJVzEf3B4n1XP
         hWfw==
X-Gm-Message-State: APjAAAUduDRegJjhXKfaILQPqMs9jzOvwfPeEkcIfen64+jQ2980Se0D
	nU/uJKUkmJ6p2HseI1LGxpd8FeC5Sn2erLtMDASYL/66stgeY73dVFB1FU8j5FizhgxX+hNGsAW
	K8AUtI7ZEJaE=
X-Received: by 2002:a62:7911:: with SMTP id u17mr48465207pfc.162.1568257545109;
        Wed, 11 Sep 2019 20:05:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvJgMvzAA3GTlVHdrDEI3jmmQyYvEA8QZHD/800p23XgRG23/if596HdJHKQ8FDS+wi6lebA==
X-Received: by 2002:a62:7911:: with SMTP id u17mr48465177pfc.162.1568257544806;
        Wed, 11 Sep 2019 20:05:44 -0700 (PDT)
Received: from xz-x1 ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id r187sm37436555pfc.105.2019.09.11.20.05.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Sep 2019 20:05:43 -0700 (PDT)
Date: Thu, 12 Sep 2019 11:05:31 +0800
From: Peter Xu <peterx@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Marty McFadden <mcfadden8@llnl.gov>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 7/7] mm/gup: Allow VM_FAULT_RETRY for multiple times
Message-ID: <20190912030531.GB8552@xz-x1>
References: <20190911071007.20077-1-peterx@redhat.com>
 <20190911071007.20077-8-peterx@redhat.com>
 <CAHk-=wh03Qx6zNS_yhhsf5gPah=2=mi7+dKMNCVrKhw6+894ag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHk-=wh03Qx6zNS_yhhsf5gPah=2=mi7+dKMNCVrKhw6+894ag@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 10:47:59AM +0100, Linus Torvalds wrote:
> On Wed, Sep 11, 2019 at 8:11 AM Peter Xu <peterx@redhat.com> wrote:
> >
> > This is the gup counterpart of the change that allows the
> > VM_FAULT_RETRY to happen for more than once.  One thing to mention is
> > that we must check the fatal signal here before retry because the GUP
> > can be interrupted by that, otherwise we can loop forever.
> 
> I still get nervous about the signal handling here.
> 
> I'm not entirely sure we get it right even before your patch series.
> 
> Right now, __get_user_pages() can return -ERESTARTSYS when it's killed:
> 
>         /*
>          * If we have a pending SIGKILL, don't keep faulting pages and
>          * potentially allocating memory.
>          */
>         if (fatal_signal_pending(current)) {
>                 ret = -ERESTARTSYS;
>                 goto out;
>         }
> 
> and I don't think your series changes that.  And note how this is true
> _regardless_ of any FOLL_xyz flags (and we don't pass the
> FAULT_FLAG_xyz flags at all, they get generated deeper down if we
> actually end up faulting things in).
> 
> So this part of the patch:
> 
> +               if (fatal_signal_pending(current))
> +                       goto out;
> +
>                 *locked = 1;
> -               lock_dropped = true;
>                 down_read(&mm->mmap_sem);
>                 ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
> -                                      pages, NULL, NULL);
> +                                      pages, NULL, locked);
> +               if (!*locked) {
> +                       /* Continue to retry until we succeeded */
> +                       BUG_ON(ret != 0);
> +                       goto retry;
> 
> just makes me go "that can't be right". The fatal_signal_pending() is
> pointless and would probably better be something like
> 
>         if (down_read_killable(&mm->mmap_sem) < 0)
>                 goto out;

Thanks for noticing all these!  I'd admit when I was working on the
series I didn't think & test very carefully with fatal signals but
mostly I'm making sure the normal signals should work especially for
processes like userfaultfd tracees so they won't hang death (I'm
always testing with GDB, and if without proper signal handle they do
hang death..).

I agree that we should probably replace the down_read() with the
killable version as you suggested.  Though we might still want the
explicit check of fatal_signal_pending() to make sure we react even
faster because IMHO down_read_killable() does not really check signals
all the time but it just put us into killable state if we need to wait
for the mmap_sem.  In other words, if we are always lucky that we get
the lock without even waiting anything then down_read_killable() will
still ignore the fatal signals forever.

> 
> and then _after_ calling __get_user_pages(), the whole "negative error
> handling" should be more obvious.
> 
> The BUG_ON(ret != 0) makes me nervous, but it might be fine (I guess
> the fatal signal handling has always been done before the lock is
> released?).

Yes it indeed looks nervous, though it's probably should be true in
all cases.  Actually we already have checks like this, for example, in
current __get_user_pages_locked():

        /* VM_FAULT_RETRY cannot return errors */
        if (!*locked) {
                BUG_ON(ret < 0);
                BUG_ON(ret >= nr_pages);
        }

And in the new retry path since we always pass in npages==1 so it must
be zero when VM_FAULT_RETRY.

While... When I'm looking into this more carefully I seem to have
found another bug that we might want to fix with hugetlbfs path:

diff --git a/mm/gup.c b/mm/gup.c
index 7230f60a68d6..29ee3de65fad 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -836,6 +836,16 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
                                i = follow_hugetlb_page(mm, vma, pages, vmas,
                                                &start, &nr_pages, i,
                                                gup_flags, locked);
+                               if (locked && *locked == 0) {
+                                       /*
+                                        * We've got a VM_FAULT_RETRY
+                                        * and we've lost mmap_sem.
+                                        * We must stop here.
+                                        */
+                                       BUG_ON(gup_flags & FOLL_NOWAIT);
+                                       BUG_ON(ret != 0);
+                                       goto out;
+                               }
                                continue;
                        }
                }

The problem is that if *locked==0 then we've lost the mmap_sem
already!  Then we probably can't go any further before taking it back
again.  With that, we should be able to keep the previous assumption
valid.

> 
> But exactly *because* __get_user_pages() can already return on fatal
> signals, I think it should also set FAULT_FLAG_KILLABLE when faulting
> things in. I don't think it does right now, so it doesn't actually
> necessarily check fatal signals in a timely manner (not _during_ the
> fault, only _before_ it).

Probably correct again at least to me...

So for current gup we never use FAULT_FLAG_KILLABLE.  However I can't
figure out a reason on why we should continue with anything if the
thread context is going to be destroyed after all.  And since we're at
it, I also noticed that userfaultfd will react upon fatal signals even
without FAULT_FLAG_KILLABLE.  So, here's the things that I think could
be good to have probably in my next post:

- Allow the gup code to always use FAULT_FLAG_KILLABLE as long as
  FAULT_FLAG_ALLOW_RETRY && !FAULT_FLAG_NOWAIT (that should be when
  "locked" parameter is passed into gup), and,

- With previous change, we touch up handle_userfault() to also respect
  the fault flag, so instead of:
  
	blocking_state = return_to_userland ? TASK_INTERRUPTIBLE :
			 TASK_KILLABLE;

  We now let the blocking_state to be either (1) INTERRUPTIBLE, if
  with the new FAULT_FLAG_INTERRUPTIBLE, or (2) KILLABLE, if with
  FAULT_FLAG_KILLABLE, or (3) UNINTERRUPTIBLE.  Though if we start to
  use FAULT_FLAG_KILLABLE in gup codes then in most cases (both gup
  and the default page fault flags that most archs use) the
  userfaultfd code should also behave as before.

Does above make any sense?

There could also be considerations behind on the current model of
handling fatal signals that I totally overlooked.  I would appreciate
if anyone can point that out if so.

> 
> See what I'm reacting to?
> 
> And maybe I'm wrong. Maybe I misread the code, and your changes. And
> at least some of these logic error predate your changes, I just was
> hoping that since this whole "react to signals" is very much what your
> patch series is working on, you'd look at this.

Yes, I'd be happy to (as long as they can be reviewed properly so I
can get a chance to fix all my potential mistakes :).

Thanks,

-- 
Peter Xu

