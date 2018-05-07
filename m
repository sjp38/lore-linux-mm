Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B98186B0007
	for <linux-mm@kvack.org>; Mon,  7 May 2018 16:19:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x7-v6so18157050wrn.13
        for <linux-mm@kvack.org>; Mon, 07 May 2018 13:19:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s67-v6sor426958wme.35.2018.05.07.13.19.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 13:19:20 -0700 (PDT)
MIME-Version: 1.0
References: <20180507201651.165879-1-shakeelb@google.com>
In-Reply-To: <20180507201651.165879-1-shakeelb@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 07 May 2018 20:19:08 +0000
Message-ID: <CALvZod7gktckGdTRCmTQTACXZKbtpCJqqovxFvSqG1uDa07ocg@mail.gmail.com>
Subject: Re: [PATCH] mm: memcontrol: drain memcg stock on force_empty
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Junaid Shahid <junaids@google.com>, Junaid Shahid <juanids@google.com>

On Mon, May 7, 2018 at 1:16 PM Shakeel Butt <shakeelb@google.com> wrote:

> From: Junaid Shahid <junaids@google.com>

> The per-cpu memcg stock can retain a charge of upto 32 pages. On a
> machine with large number of cpus, this can amount to a decent amount
> of memory. Additionally force_empty interface might be triggering
> unneeded memcg reclaims.

> Signed-off-by: Junaid Shahid <juanids@google.com>

This should be "Junaid Shahid <junaids@google.com>".

> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>   mm/memcontrol.c | 3 +++
>   1 file changed, 3 insertions(+)

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e2d33a37f971..2c3c69524b49 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2841,6 +2841,9 @@ static int mem_cgroup_force_empty(struct mem_cgroup
*memcg)

>          /* we call try-to-free pages for make this cgroup empty */
>          lru_add_drain_all();
> +
> +       drain_all_stock(memcg);
> +
>          /* try to free all pages in this cgroup */
>          while (nr_retries && page_counter_read(&memcg->memory)) {
>                  int progress;
> --
> 2.17.0.441.gb46fe60e1d-goog
