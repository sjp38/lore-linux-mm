Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67AFFC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:59:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D5142084D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:59:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="adgbz1vo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D5142084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 842926B0005; Tue, 13 Aug 2019 11:59:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F3FA6B0006; Tue, 13 Aug 2019 11:59:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 709116B0007; Tue, 13 Aug 2019 11:59:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0041.hostedemail.com [216.40.44.41])
	by kanga.kvack.org (Postfix) with ESMTP id 48F1E6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:59:57 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0561E181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:59:57 +0000 (UTC)
X-FDA: 75817865634.22.rub47_910252a378047
X-HE-Tag: rub47_910252a378047
X-Filterd-Recvd-Size: 10154
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:59:56 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id r4so79932458qkm.13
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:59:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5wYbeJt062YGni4JJRrpw5Er0ip3eb9YlimfJPWTmeY=;
        b=adgbz1vohNtcXb218auKPIEJMAA4N/AhL+EgCkoIrZTw4sJjkmuk6yITXcyaAjlHGw
         QYOYISgAtqVQixxeBPadxlyzgMpyeEPsuR8kJwvdRnfD45cB1MuXD1OEJisG6QWMPOSM
         yvtMTES6gK4c0TbvpJvooOZiXhLo2EzMXVlEXafTmZ0biTJfI9ngTmFRxSj57OEbWpCX
         l3wuA8gr7t5CLHPM90fc362Exw0vmfxq2tYr7PSRghSq+ayFEqpBI2aOl6f4nIHWAIlx
         kb9mwCTQRoPazUD9WX/3aKbiOvUVKLSPn0NMp0tCvKTkw3/Guhy52q1lbEfqKtIEBd3F
         /NYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=5wYbeJt062YGni4JJRrpw5Er0ip3eb9YlimfJPWTmeY=;
        b=qlM5oTKH/DeFw58hARGxqxQ4kkrOc1ulrFoka0FM2Tbm3OgJVUCfvS+KkPLpEmzzXW
         RZdz0RCHybWLoVvM9dOWYWSrDbLj0BBtJcHc9nZKg99zmG4CA6GRVjABvlL07PyrfB14
         WAcW8FCkqeLRH1nhVX9RA8s56OwCX9xj5B3TUs0KbIH6nCuJua5HQVFSN7QMtnEFIWWn
         odpB6iZtDKl9pQZBtwZ8V1pPd8q53189VXcVmb3O/XAGJY1tiaAPe96kdRUJ5KSu1tdw
         34aYVFnbvOnebbXWp9/Wgp3WCL63zZU5TDE1arls+QruJezLLSBedxNWcNkqNqegdBpu
         EZRA==
X-Gm-Message-State: APjAAAUzngaYa7fjc445oODkFAWr7IF4QQptJ0hMqKXrxMH4FtofELYC
	G/oFQHNKZoUvDtZHNG8tK89wMnD5BXljxZvF04E=
X-Google-Smtp-Source: APXvYqwedf7ItGfvmp28v2dVpPWQXYz4bLyvLzDni/9I/2kDnDxkLY1j9Sty4jAaWxCMpgXPjNhgwikLK39hOOpxNtE=
X-Received: by 2002:a37:9d94:: with SMTP id g142mr33317931qke.209.1565711995789;
 Tue, 13 Aug 2019 08:59:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190812192316.13615-1-hannes@cmpxchg.org> <20190813132938.GJ17933@dhcp22.suse.cz>
In-Reply-To: <20190813132938.GJ17933@dhcp22.suse.cz>
From: Yang Shi <shy828301@gmail.com>
Date: Tue, 13 Aug 2019 08:59:38 -0700
Message-ID: <CAHbLzkrRvoVLH16Cxq-f6hn-CLJjh=tJnYnF8P0xNiZ9=eEg8A@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: do not share cgroup iteration between reclaimers
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 6:29 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 12-08-19 15:23:16, Johannes Weiner wrote:
> > One of our services observed a high rate of cgroup OOM kills in the
> > presence of large amounts of clean cache. Debugging showed that the
> > culprit is the shared cgroup iteration in page reclaim.
> >
> > Under high allocation concurrency, multiple threads enter reclaim at
> > the same time. Fearing overreclaim when we first switched from the
> > single global LRU to cgrouped LRU lists, we introduced a shared
> > iteration state for reclaim invocations - whether 1 or 20 reclaimers
> > are active concurrently, we only walk the cgroup tree once: the 1st
> > reclaimer reclaims the first cgroup, the second the second one etc.
> > With more reclaimers than cgroups, we start another walk from the top.
> >
> > This sounded reasonable at the time, but the problem is that reclaim
> > concurrency doesn't scale with allocation concurrency. As reclaim
> > concurrency increases, the amount of memory individual reclaimers get
> > to scan gets smaller and smaller. Individual reclaimers may only see
> > one cgroup per cycle, and that may not have much reclaimable
> > memory. We see individual reclaimers declare OOM when there is plenty
> > of reclaimable memory available in cgroups they didn't visit.
> >
> > This patch does away with the shared iterator, and every reclaimer is
> > allowed to scan the full cgroup tree and see all of reclaimable
> > memory, just like it would on a non-cgrouped system. This way, when
> > OOM is declared, we know that the reclaimer actually had a chance.
> >
> > To still maintain fairness in reclaim pressure, disallow cgroup
> > reclaim from bailing out of the tree walk early. Kswapd and regular
> > direct reclaim already don't bail, so it's not clear why limit reclaim
> > would have to, especially since it only walks subtrees to begin with.
>
> The code does bail out on any direct reclaim - be it limit or page
> allocator triggered. Check the !current_is_kswapd part of the condition.

Yes, please see commit 2bb0f34fe3c1 ("mm: vmscan: do not iterate all
mem cgroups for global direct reclaim")

>
> > This change completely eliminates the OOM kills on our service, while
> > showing no signs of overreclaim - no increased scan rates, %sys time,
> > or abrupt free memory spikes. I tested across 100 machines that have
> > 64G of RAM and host about 300 cgroups each.
>
> What is the usual direct reclaim involvement on those machines?
>
> > [ It's possible overreclaim never was a *practical* issue to begin
> >   with - it was simply a concern we had on the mailing lists at the
> >   time, with no real data to back it up. But we have also added more
> >   bail-out conditions deeper inside reclaim (e.g. the proportional
> >   exit in shrink_node_memcg) since. Regardless, now we have data that
> >   suggests full walks are more reliable and scale just fine. ]
>
> I do not see how shrink_node_memcg bail out helps here. We do scan up-to
> SWAP_CLUSTER_MAX pages for each LRU at least once. So we are getting to
> nr_memcgs_with_pages multiplier with the patch applied in the worst case.
>
> How much that matters is another question and it depends on the
> number of cgroups and the rate the direct reclaim happens. I do not
> remember exact numbers but even walking a very large memcg tree was
> noticeable.

I'm concerned by this too. It might be ok to cgroup v2, but v1 still
dominates. And, considering offline memcgs it might be not unusual to
have quite large memcg tree.

>
> For the over reclaim part SWAP_CLUSTER_MAX is a relatively small number
> so even hundreds of memcgs on a "reasonably" sized system shouldn't be
> really observable (we are talking about 7MB per reclaim per reclaimer on
> 1k memcgs with pages). This would get worse with many reclaimers. Maybe
> we will need something like the regular direct reclaim throttling of
> mmemcg limit reclaim as well in the future.
>
> That being said, I do agree that the oom side of the coin is causing
> real troubles and it is a real problem to be addressed first. Especially with
> cgroup v2 where we have likely more memcgs without any pages because
> inner nodes do not have any tasks and direct charges which makes some
> reclaimers hit memcgs without pages more likely.
>
> Let's see whether we see regression due to over-reclaim.
>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>
> With the direct reclaim bail out reference fixed - unless I am wrong
> there of course
>
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> It is sad to see this piece of fun not being used after that many years
> of bugs here and there and all the lockless fun but this is the life
> ;)
>
> > ---
> >  mm/vmscan.c | 22 ++--------------------
> >  1 file changed, 2 insertions(+), 20 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index dbdc46a84f63..b2f10fa49c88 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2667,10 +2667,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> >
> >       do {
> >               struct mem_cgroup *root = sc->target_mem_cgroup;
> > -             struct mem_cgroup_reclaim_cookie reclaim = {
> > -                     .pgdat = pgdat,
> > -                     .priority = sc->priority,
> > -             };
> >               unsigned long node_lru_pages = 0;
> >               struct mem_cgroup *memcg;
> >
> > @@ -2679,7 +2675,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> >               nr_reclaimed = sc->nr_reclaimed;
> >               nr_scanned = sc->nr_scanned;
> >
> > -             memcg = mem_cgroup_iter(root, NULL, &reclaim);
> > +             memcg = mem_cgroup_iter(root, NULL, NULL);
> >               do {
> >                       unsigned long lru_pages;
> >                       unsigned long reclaimed;
> > @@ -2724,21 +2720,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> >                                  sc->nr_scanned - scanned,
> >                                  sc->nr_reclaimed - reclaimed);
> >
> > -                     /*
> > -                      * Kswapd have to scan all memory cgroups to fulfill
> > -                      * the overall scan target for the node.
> > -                      *
> > -                      * Limit reclaim, on the other hand, only cares about
> > -                      * nr_to_reclaim pages to be reclaimed and it will
> > -                      * retry with decreasing priority if one round over the
> > -                      * whole hierarchy is not sufficient.
> > -                      */
> > -                     if (!current_is_kswapd() &&
> > -                                     sc->nr_reclaimed >= sc->nr_to_reclaim) {
> > -                             mem_cgroup_iter_break(root, memcg);
> > -                             break;
> > -                     }
> > -             } while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
> > +             } while ((memcg = mem_cgroup_iter(root, memcg, NULL)));
> >
> >               if (reclaim_state) {
> >                       sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> > --
> > 2.22.0
>
> --
> Michal Hocko
> SUSE Labs
>

