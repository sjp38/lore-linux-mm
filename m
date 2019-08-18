Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D52E7C3A59B
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 00:30:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 563BE2173B
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 00:30:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tj8HYYpV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 563BE2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C03FC6B0008; Sat, 17 Aug 2019 20:30:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8E116B000A; Sat, 17 Aug 2019 20:30:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A53906B000C; Sat, 17 Aug 2019 20:30:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0120.hostedemail.com [216.40.44.120])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9616B0008
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 20:30:53 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 244B8AC14
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 00:30:53 +0000 (UTC)
X-FDA: 75833668386.25.ear68_24c7f8122252d
X-HE-Tag: ear68_24c7f8122252d
X-Filterd-Recvd-Size: 6854
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 00:30:52 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id s21so13690982ioa.1
        for <linux-mm@kvack.org>; Sat, 17 Aug 2019 17:30:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7TCNFB9IApthvRti5TuZchHBScOrRK3vIeUZCqgFKMI=;
        b=tj8HYYpVDjnt1qYAUFi8njHti8RuQcSWkQtHtqD1We3t+PxlKqxbB/qfwaPyA8nHhp
         lbZyujDvxpi9CAG9wKs23piBQucNB9PmSt9q5SgWO1Ifod75spKzLsEFXAWix5Ko8yxe
         dspmNumSio874P0gjjGD3oUC9rtbsiwnVl/cvqgzUtEqgTPY4qP76oeDFzxU/hrh7rVt
         XqFc2BdsP2K3/J9KKWm4n1JmisYMrtA7po/sepEUkpaEUCpFsv27YDqC0U8WaFTWjh5v
         utYJ2ffXqr54hNV12WHdRG65pgSnutp5gHjWsPyzCyaaTxYwvPj54xTMw1BrvXuSnorO
         XyEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=7TCNFB9IApthvRti5TuZchHBScOrRK3vIeUZCqgFKMI=;
        b=N4F7IkPJRts2WGus+5nYRN+LzRGKRn7BIdk17QvmHBmh3v3ZNikcRcQv3Ja/QZUADy
         3R8WcyweltEe2F5cKcn9O9t2liNY1rbFujnZzfE+72I7XvcuRo9pasj6QAu1HtvQRumc
         NR9IQ4xuoqtLVk+dHnqIXQlexv07tGxK/Okn87NYa3wo7vCqU+DQHeai8oN4d71zJ0Ie
         JYI1iZXJ3bdE0chLqWdsIWdypYvZOxGa8bNz64zH3B1CD/CpMVzK0Bw0ktv1RzktrTQh
         aCLeO0FND1rJWl5UD7Mmh4etJpb0kh+6g53vCsahU2ALC/bTjVdZTm6GQgTcs780QXrl
         GYDg==
X-Gm-Message-State: APjAAAXAiTxaS0LzdJa78CsuPiSm2TIdxDJh0m6nuVdzAUniBTgaFWhp
	l970adI9unx8dE0bHnDF2tKIc5IxFl+tc17P71Y=
X-Google-Smtp-Source: APXvYqw1qG48u3XtTNYDfqmoOH9rsc/UNf1NeLz1rj1kTjqIKQY9w3co5mCGqjVQJYxMGCTLXpee08DDnt3uvuATBKs=
X-Received: by 2002:a02:1981:: with SMTP id b123mr18589621jab.72.1566088251625;
 Sat, 17 Aug 2019 17:30:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190817004726.2530670-1-guro@fb.com> <CALOAHbBsMNLN6jZn83zx6EWM_092s87zvDQ7p-MZpY+HStk-1Q@mail.gmail.com>
 <20190817191419.GA11125@castle>
In-Reply-To: <20190817191419.GA11125@castle>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sun, 18 Aug 2019 08:30:15 +0800
Message-ID: <CALOAHbA-Z-1QDSgQ6H6QhPaPwAGyqfpd3Gbq-KLnoO=ZZxWnrw@mail.gmail.com>
Subject: Re: [PATCH] Partially revert "mm/memcontrol.c: keep local VM counters
 in sync with the hierarchical ones"
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, 
	"stable@vger.kernel.org" <stable@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 18, 2019 at 3:14 AM Roman Gushchin <guro@fb.com> wrote:
>
> On Sat, Aug 17, 2019 at 11:33:57AM +0800, Yafang Shao wrote:
> > On Sat, Aug 17, 2019 at 8:47 AM Roman Gushchin <guro@fb.com> wrote:
> > >
> > > Commit 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync
> > > with the hierarchical ones") effectively decreased the precision of
> > > per-memcg vmstats_local and per-memcg-per-node lruvec percpu counters.
> > >
> > > That's good for displaying in memory.stat, but brings a serious regression
> > > into the reclaim process.
> > >
> > > One issue I've discovered and debugged is the following:
> > > lruvec_lru_size() can return 0 instead of the actual number of pages
> > > in the lru list, preventing the kernel to reclaim last remaining
> > > pages. Result is yet another dying memory cgroups flooding.
> > > The opposite is also happening: scanning an empty lru list
> > > is the waste of cpu time.
> > >
> > > Also, inactive_list_is_low() can return incorrect values, preventing
> > > the active lru from being scanned and freed. It can fail both because
> > > the size of active and inactive lists are inaccurate, and because
> > > the number of workingset refaults isn't precise. In other words,
> > > the result is pretty random.
> > >
> > > I'm not sure, if using the approximate number of slab pages in
> > > count_shadow_number() is acceptable, but issues described above
> > > are enough to partially revert the patch.
> > >
> > > Let's keep per-memcg vmstat_local batched (they are only used for
> > > displaying stats to the userspace), but keep lruvec stats precise.
> > > This change fixes the dead memcg flooding on my setup.
> > >
> >
> > That will make some misunderstanding if the local counters are not in
> > sync with the hierarchical ones
> > (someone may doubt whether there're something leaked.).
>
> Sure, but the actual leakage is a much more serious issue.
>
> > If we have to do it like this, I think we should better document this behavior.
>
> Lru size calculations can be done using per-zone counters, which is
> actually cheaper, because the number of zones is usually smaller than
> the number of cpus. I'll send a corresponding patch on Monday.
>

Looks like a good idea.

> Maybe other use cases can also be converted?

We'd better keep the behavior the same across counters. I think you
can have a try.

Thanks
Yafang

>
> Thanks!
>
> >
> > > Fixes: 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones")
> > > Signed-off-by: Roman Gushchin <guro@fb.com>
> > > Cc: Yafang Shao <laoar.shao@gmail.com>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > ---
> > >  mm/memcontrol.c | 8 +++-----
> > >  1 file changed, 3 insertions(+), 5 deletions(-)
> > >
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 249187907339..3429340adb56 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -746,15 +746,13 @@ void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
> > >         /* Update memcg */
> > >         __mod_memcg_state(memcg, idx, val);
> > >
> > > +       /* Update lruvec */
> > > +       __this_cpu_add(pn->lruvec_stat_local->count[idx], val);
> > > +
> > >         x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
> > >         if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
> > >                 struct mem_cgroup_per_node *pi;
> > >
> > > -               /*
> > > -                * Batch local counters to keep them in sync with
> > > -                * the hierarchical ones.
> > > -                */
> > > -               __this_cpu_add(pn->lruvec_stat_local->count[idx], x);
> > >                 for (pi = pn; pi; pi = parent_nodeinfo(pi, pgdat->node_id))
> > >                         atomic_long_add(x, &pi->lruvec_stat[idx]);
> > >                 x = 0;
> > > --
> > > 2.21.0
> > >

