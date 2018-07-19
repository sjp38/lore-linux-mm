Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 96F376B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 12:11:36 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s14-v6so3953014wra.0
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:11:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18-v6sor1436010wmd.76.2018.07.19.09.11.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 09:11:35 -0700 (PDT)
MIME-Version: 1.0
References: <153201627722.12295.11034132843390627757.stgit@localhost.localdomain>
In-Reply-To: <153201627722.12295.11034132843390627757.stgit@localhost.localdomain>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 19 Jul 2018 09:11:22 -0700
Message-ID: <CALvZod6iCE8W51m2N704GQ_ML==J76SU6e9w7RCFE2+Vd+Vjaw@mail.gmail.com>
Subject: Re: [PATCH] mm: Cleanup in do_shrink_slab()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 19, 2018 at 9:04 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> Group long variables together to minimize number of occupied lines
> and place all definitions in back Christmas tree order. Also,
> simplify expression around batch_size: use all power of C language!
>
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  mm/vmscan.c |   11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9918bfc1d2f9..636657213b9b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -445,16 +445,11 @@ EXPORT_SYMBOL(unregister_shrinker);
>  static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>                                     struct shrinker *shrinker, int priority)
>  {
> -       unsigned long freed = 0;
> +       long total_scan, freeable, nr, new_nr, next_deferred, scanned = 0;
> +       long batch_size = shrinker->batch ? : SHRINK_BATCH;
>         unsigned long long delta;
> -       long total_scan;
> -       long freeable;
> -       long nr;
> -       long new_nr;
>         int nid = shrinkctl->nid;
> -       long batch_size = shrinker->batch ? shrinker->batch
> -                                         : SHRINK_BATCH;
> -       long scanned = 0, next_deferred;
> +       unsigned long freed = 0;
>
>         freeable = shrinker->count_objects(shrinker, shrinkctl);
>         if (freeable == 0 || freeable == SHRINK_EMPTY)
>
