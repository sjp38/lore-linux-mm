Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D9ABD6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 13:40:59 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id s18so910305qta.18
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 10:40:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u23sor1373999qki.2.2017.09.28.10.40.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 10:40:58 -0700 (PDT)
Date: Thu, 28 Sep 2017 13:40:56 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH][v2] mm: use sc->priority for slab shrink targets
Message-ID: <20170928174055.4y5csaaika3yzm76@destiny>
References: <1503589176-1823-1-git-send-email-jbacik@fb.com>
 <20170829204026.GA7605@cmpxchg.org>
 <20170829135806.6599f585211058e0842fab85@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829135806.6599f585211058e0842fab85@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, josef@toxicpanda.com, minchan@kernel.org, linux-mm@kvack.org, riel@redhat.com, david@fromorbit.com, kernel-team@fb.com, aryabinin@virtuozzo.com, Josef Bacik <jbacik@fb.com>

On Tue, Aug 29, 2017 at 01:58:06PM -0700, Andrew Morton wrote:
> On Tue, 29 Aug 2017 16:40:26 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > This looks good to me, thanks for persisting Josef.
> > 
> > There is a small cleanup possible on top of this, as the slab shrinker
> > was the only thing that used that lru_pages accumulation when the scan
> > targets are calculated.
> 
> I'm inclined to park this until 4.14-rc1, unless we see a pressing need
> to get it into 4.13?
> 

Hey Andrew,

I just noticed that these aren't in your mmotm tree, did you mean you were going
to wait until after -rc1 to pull them into your tree?  Or did they get
forgotten?  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
