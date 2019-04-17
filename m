Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53413C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 10:55:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6BF4206B6
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 10:55:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sN9XezfJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6BF4206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 237966B0007; Wed, 17 Apr 2019 06:55:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E5C36B0008; Wed, 17 Apr 2019 06:55:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FDA76B000A; Wed, 17 Apr 2019 06:55:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF3CA6B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:55:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d2so12214242edo.23
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 03:55:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to;
        bh=ywsDRnZXw0K4iHU5gOwpw1ILwLsnoHeavnwibTGmBkc=;
        b=SGjDvSHsY4LtH60wRAgEXt54NNg0riyzIa/gNg0MZmnQaHZRqka049RcXpBJyMTLKO
         PWJ9vBXnpDFt8zGX/G7MN0/mJ58bTNDupBZ9TA3rZAy9b6L1CAHhPWUV4YunYVX4/cyP
         FupAhdJ/ysTf7T6CEVYpZ0dlxjx2VU5HLELZ4U+7SUzQMtXtMWxxyGeki86ceAIxegyL
         qe8wJeEJu4TSuD6arO55UOf1x1y2iQIb4XMaFTHBE2MbEk+XTlaZ6PPJvK1algBeUHeV
         zXprfnpVfbg1Dwi9othNn6x3NrjW08QPO2n7P/ZOpBrR+24V+iqrmU/Lcc4vYjfDkTDR
         H9Zg==
X-Gm-Message-State: APjAAAUfBra/tAfdJi2S9xkYT08nA9QO5zRDIcBOw/k07cE9sBRL3j+8
	hmtQu6uL4O1S+HRjmBSW4/6cmdEB78SvcbRO0qkag3pJ9rgEjokOzLNjipEFuQLShHQnDoojEB3
	kayy4mD6Rd/PmfzohF6Xh7+oEKCULOaFIqW/ipHdDpqGB5jZwSAtb94SQcwp3rCAAIQ==
X-Received: by 2002:a50:b5c3:: with SMTP id a61mr50094195ede.31.1555498528114;
        Wed, 17 Apr 2019 03:55:28 -0700 (PDT)
X-Received: by 2002:a50:b5c3:: with SMTP id a61mr50094129ede.31.1555498527002;
        Wed, 17 Apr 2019 03:55:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555498526; cv=none;
        d=google.com; s=arc-20160816;
        b=Cq0TPGWZwT8KmIenxSWirLH+qwecsVZBEYQytzgK/DaFYi5oSt34V5jJxVPGCrmxci
         SO2lCFyphcRNsr6WJ7tbJMcJNLaktlP/iDWb5WIVeiHlWCBRUoQ/F3xNfgJEau9edou3
         p+znSkK6uSVvDpIqZxmDLjEl8IzTFL17dz9KA4THRiEFGg26i0WsbFnxNxHR94qttOCf
         FlUhIk0XmfJYZq5Tx5lytlWafBpbvKNIsATD3rlbyjy4p1JWSwrmpHCwhOZLYxAh9N6h
         YfJPtXC728EdqGpb+9JMKw1NFUkO+wLrp9yZZ6rIdyteUnOqFT/9t/vkwRJgcfSmmlht
         rdcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=ywsDRnZXw0K4iHU5gOwpw1ILwLsnoHeavnwibTGmBkc=;
        b=krKvm1DnNSbOqyXi5rZPJCye1/zjNIT90JL/e2nJ5uKxZ7AlFkCOIhfW/amAHpbDcv
         tqXxiuvEgqjti8CHalpm+wWkzOQznwdpC4Ziv7RZlfhBThWAATswvnye8RuOQi5Y5UaY
         pWHKVq6djKI/v0Zdgw5yEBVKY3Ex5zj81PyOZF+BSKF8SiKxxq6Ne7S6p4J4v2u+pGjx
         hyzYkIwollpfaBXyyk1YttaooHq/ke/cI8J/kL0PFgmyOhuSCKTvCIKsRSSex9RLZrAM
         xvbpty3fpVxRES5WtBixmgViEMZBGjnOeQzwNBzC5EEr+9Z+tcH355dHe0+1uOb9Vgrz
         Wkng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sN9XezfJ;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l15sor6364454edv.11.2019.04.17.03.55.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 03:55:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sN9XezfJ;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=ywsDRnZXw0K4iHU5gOwpw1ILwLsnoHeavnwibTGmBkc=;
        b=sN9XezfJY0PNH42t6H4czPbYwRjQATW+86vOgjPgf/vVnf8n0WV9saKa4gNRun3B0c
         4TTo4BeVcRzq+CjyX8iAn+Qs1pDQl9MJaZchjS5PU1L1WM1ptL9Ge3c0d2FRlj5VIXcu
         Wc7INNW6MVGOesBudlVu+nH6VYET/E17T8crD2iIBIBrHME+cdSsNpEMF+CX03N167rn
         RGKlxjTBmwmccuuDGHXIg5ZVtRlCLd61vYnVmusHf7BV+o+Mqhd00V5fw5pS+gFQU1QY
         F0LuQdhfbfRHhvsW8JqJzaaTds2pu28FYWzor7LIwu65BzRbOwfOAZUtz6jSoRFaBbyw
         etrQ==
X-Google-Smtp-Source: APXvYqwzAXcD7VW4Lx4wIv4PjS0zl4BS0AJrB9UvjJX+C6yEgSwizlZoVQQj+wo9155ANTPb5q/SqjWuDHaJY7klXXo=
X-Received: by 2002:a50:b283:: with SMTP id p3mr7504856edd.105.1555498526638;
 Wed, 17 Apr 2019 03:55:26 -0700 (PDT)
MIME-Version: 1.0
References: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com> <CAGWkznFCy-Fm1WObEk77shPGALWhn5dWS3ZLXY77+q_4Yp6bAQ@mail.gmail.com>
In-Reply-To: <CAGWkznFCy-Fm1WObEk77shPGALWhn5dWS3ZLXY77+q_4Yp6bAQ@mail.gmail.com>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Wed, 17 Apr 2019 18:55:15 +0800
Message-ID: <CAGWkznEzRB2RPQEK5+4EYB73UYGMRbNNmMH-FyQqT2_en_q1+g@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/workingset : judge file page activity via timestamp
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, 
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>, Roman Gushchin <guro@fb.com>, 
	Jeff Layton <jlayton@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

fix one mailbox and update for some information

Comparing to http://lkml.kernel.org/r/1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com,
this commit fix the packing order error and add trace_printk for
reference debug information.

For johannes's comments, please find bellowing for my feedback.



On Wed, Apr 17, 2019 at 3:59 PM Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:
>
> add Johannes and answer his previous question.
>
> @Johannes Weiner
> Yes. I do agree with you about the original thought of sacrificing
> long distance access pages when huge memory demands arise. The problem
> is what is the criteria of the distance, which you can find from what
> I comment in the patch, that is, some pages have long refault_distance
> while having a very short access time in between. I think the latter
> one should be take into consideration or as part of the finnal
> decision of if the page should be active/inactive.
>
> On Wed, Apr 17, 2019 at 3:48 PM Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:
> >
> > From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> >
> > This patch introduce timestamp into workingset's entry and judge if the page
> > is active or inactive via active_file/refault_ratio instead of refault distance.
> >
> > The original thought is coming from the logs we got from trace_printk in this
> > patch, we can find about 1/5 of the file pages' refault are under the
> > scenario[1],which will be counted as inactive as they have a long refault distance
> > in between access. However, we can also know from the time information that the
> > page refault quickly as comparing to the average refault time which is calculated
> > by the number of active file and refault ratio. We want to save these kinds of
> > pages from evicted earlier as it used to be. The refault ratio is the value
> > which can reflect lru's average file access frequency and also can be deemed as a
> > prediction of future.
> >
> > The patch is tested on an android system and reduce 30% of page faults, while
> > 60% of the pages remain the original status as (refault_distance < active_file)
> > indicates. Pages status got from ftrace during the test can refer to [2].
> >
> > [1]
> > system_server workingset_refault: WKST_ACT[0]:rft_dis 265976, act_file 34268 rft_ratio 3047 rft_time 0 avg_rft_time 11 refault 295592 eviction 29616 secs 97 pre_secs 97
> > HwBinder:922  workingset_refault: WKST_ACT[0]:rft_dis 264478, act_file 35037 rft_ratio 3070 rft_time 2 avg_rft_time 11 refault 310078 eviction 45600 secs 101 pre_secs 99
> >
> > [2]
> > WKST_ACT[0]:   original--INACTIVE  commit--ACTIVE
> > WKST_ACT[1]:   original--ACTIVE    commit--ACTIVE
> > WKST_INACT[0]: original--INACTIVE  commit--INACTIVE
> > WKST_INACT[1]: original--ACTIVE    commit--INACTIVE
> >
> > Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
> > ---
> >  include/linux/mmzone.h |   1 +
> >  mm/workingset.c        | 120 +++++++++++++++++++++++++++++++++++++++++++++----
> >  2 files changed, 112 insertions(+), 9 deletions(-)
> >
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 32699b2..6f30673 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -240,6 +240,7 @@ struct lruvec {
> >         atomic_long_t                   inactive_age;
> >         /* Refaults at the time of last reclaim cycle */
> >         unsigned long                   refaults;
> > +       atomic_long_t                   refaults_ratio;
> >  #ifdef CONFIG_MEMCG
> >         struct pglist_data *pgdat;
> >  #endif
> > diff --git a/mm/workingset.c b/mm/workingset.c
> > index 40ee02c..66c177b 100644
> > --- a/mm/workingset.c
> > +++ b/mm/workingset.c
> > @@ -160,6 +160,21 @@
> >                          MEM_CGROUP_ID_SHIFT)
> >  #define EVICTION_MASK  (~0UL >> EVICTION_SHIFT)
> >
> > +#ifdef CONFIG_64BIT
> > +#define EVICTION_SECS_POS_SHIFT 20
> > +#define EVICTION_SECS_SHRINK_SHIFT 4
> > +#define EVICTION_SECS_POS_MASK  ((1UL << EVICTION_SECS_POS_SHIFT) - 1)
> > +#else
> > +#ifndef CONFIG_MEMCG
> > +#define EVICTION_SECS_POS_SHIFT 12
> > +#define EVICTION_SECS_SHRINK_SHIFT 4
> > +#define EVICTION_SECS_POS_MASK  ((1UL << EVICTION_SECS_POS_SHIFT) - 1)
> > +#else
> > +#define EVICTION_SECS_POS_SHIFT 0
> > +#define EVICTION_SECS_SHRINK_SHIFT 0
> > +#define NO_SECS_IN_WORKINGSET
> > +#endif
> > +#endif
> >  /*
> >   * Eviction timestamps need to be able to cover the full range of
> >   * actionable refaults. However, bits are tight in the radix tree
> > @@ -169,10 +184,54 @@
> >   * evictions into coarser buckets by shaving off lower timestamp bits.
> >   */
> >  static unsigned int bucket_order __read_mostly;
> > -
> > +#ifdef NO_SECS_IN_WORKINGSET
> > +static void pack_secs(unsigned long *peviction) { }
> > +static unsigned int unpack_secs(unsigned long entry) {return 0; }
> > +#else
> > +/*
> > + * Shrink the timestamp according to its value and store it together
> > + * with the shrink size in the entry.
> > + */
> > +static void pack_secs(unsigned long *peviction)
> > +{
> > +       unsigned int secs;
> > +       unsigned long eviction;
> > +       int order;
> > +       int secs_shrink_size;
> > +       struct timespec ts;
> > +
> > +       get_monotonic_boottime(&ts);
> > +       secs = (unsigned int)ts.tv_sec ? (unsigned int)ts.tv_sec : 1;
> > +       order = get_count_order(secs);
> > +       secs_shrink_size = (order <= EVICTION_SECS_POS_SHIFT)
> > +                       ? 0 : (order - EVICTION_SECS_POS_SHIFT);
> > +
> > +       eviction = *peviction;
> > +       eviction = (eviction << EVICTION_SECS_POS_SHIFT)
> > +                       | ((secs >> secs_shrink_size) & EVICTION_SECS_POS_MASK);
> > +       eviction = (eviction << EVICTION_SECS_SHRINK_SHIFT) | (secs_shrink_size & 0xf);
> > +       *peviction = eviction;
> > +}
> > +/*
> > + * Unpack the second from the entry and restore the value according to the
> > + * shrink size.
> > + */
> > +static unsigned int unpack_secs(unsigned long entry)
> > +{
> > +       unsigned int secs;
> > +       int secs_shrink_size;
> > +
> > +       secs_shrink_size = entry & ((1 << EVICTION_SECS_SHRINK_SHIFT) - 1);
> > +       entry >>= EVICTION_SECS_SHRINK_SHIFT;
> > +       secs = entry & EVICTION_SECS_POS_MASK;
> > +       secs = secs << secs_shrink_size;
> > +       return secs;
> > +}
> > +#endif
> >  static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
> >  {
> >         eviction >>= bucket_order;
> > +       pack_secs(&eviction);
> >         eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
> >         eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
> >         eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
> > @@ -181,20 +240,24 @@ static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
> >  }
> >
> >  static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
> > -                         unsigned long *evictionp)
> > +                         unsigned long *evictionp, unsigned int *prev_secs)
> >  {
> >         unsigned long entry = (unsigned long)shadow;
> >         int memcgid, nid;
> > +       unsigned int secs;
> >
> >         entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
> >         nid = entry & ((1UL << NODES_SHIFT) - 1);
> >         entry >>= NODES_SHIFT;
> >         memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
> >         entry >>= MEM_CGROUP_ID_SHIFT;
> > +       secs = unpack_secs(entry);
> > +       entry >>= (EVICTION_SECS_POS_SHIFT + EVICTION_SECS_SHRINK_SHIFT);
> >
> >         *memcgidp = memcgid;
> >         *pgdat = NODE_DATA(nid);
> >         *evictionp = entry << bucket_order;
> > +       *prev_secs = secs;
> >  }
> >
> >  /**
> > @@ -242,9 +305,22 @@ bool workingset_refault(void *shadow)
> >         unsigned long refault;
> >         struct pglist_data *pgdat;
> >         int memcgid;
> > +#ifndef NO_SECS_IN_WORKINGSET
> > +       unsigned long avg_refault_time;
> > +       unsigned long refault_time;
> > +       int tradition;
> > +       unsigned int prev_secs;
> > +       unsigned int secs;
> > +       unsigned long refaults_ratio;
> > +#endif
> > +       struct timespec ts;
> > +       /*
> > +       convert jiffies to second
> > +       */
> > +       get_monotonic_boottime(&ts);
> > +       secs = (unsigned int)ts.tv_sec ? (unsigned int)ts.tv_sec : 1;
> >
> > -       unpack_shadow(shadow, &memcgid, &pgdat, &eviction);
> > -
> > +       unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &prev_secs);
> >         rcu_read_lock();
> >         /*
> >          * Look up the memcg associated with the stored ID. It might
> > @@ -288,14 +364,37 @@ bool workingset_refault(void *shadow)
> >          * list is not a problem.
> >          */
> >         refault_distance = (refault - eviction) & EVICTION_MASK;
> > -
> >         inc_lruvec_state(lruvec, WORKINGSET_REFAULT);
> > -
> > -       if (refault_distance <= active_file) {
> > +#ifndef NO_SECS_IN_WORKINGSET
> > +       refaults_ratio = (atomic_long_read(&lruvec->inactive_age) + 1) / secs;
> > +       atomic_long_set(&lruvec->refaults_ratio, refaults_ratio);
> > +       refault_time = secs - prev_secs;
> > +       avg_refault_time = active_file / refaults_ratio;
> > +       tradition = !!(refault_distance < active_file);
> > +       if (refault_time <= avg_refault_time) {
> > +#else
> > +       if (refault_distance < active_file) {
> > +#endif
> >                 inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
> > +#ifndef NO_SECS_IN_WORKINGSET
> > +               trace_printk("WKST_ACT[%d]:rft_dis %ld, act_file %ld \
> > +                               rft_ratio %ld rft_time %ld avg_rft_time %ld \
> > +                               refault %ld eviction %ld secs %d pre_secs %d\n",
> > +                               tradition, refault_distance, active_file,
> > +                               refaults_ratio, refault_time, avg_refault_time,
> > +                               refault, eviction, secs, prev_secs);
> > +#endif
> >                 rcu_read_unlock();
> >                 return true;
> >         }
> > +#ifndef NO_SECS_IN_WORKINGSET
> > +       trace_printk("WKST_INACT[%d]:rft_dis %ld, act_file %ld \
> > +                       rft_ratio %ld rft_time %ld avg_rft_time %ld \
> > +                       refault %ld eviction %ld secs %d pre_secs %d\n",
> > +                       tradition, refault_distance, active_file,
> > +                       refaults_ratio, refault_time, avg_refault_time,
> > +                       refault, eviction, secs, prev_secs);
> > +#endif
> >         rcu_read_unlock();
> >         return false;
> >  }
> > @@ -513,7 +612,9 @@ static int __init workingset_init(void)
> >         unsigned int max_order;
> >         int ret;
> >
> > -       BUILD_BUG_ON(BITS_PER_LONG < EVICTION_SHIFT);
> > +       BUILD_BUG_ON(BITS_PER_LONG < (EVICTION_SHIFT
> > +                               + EVICTION_SECS_POS_SHIFT
> > +                               + EVICTION_SECS_SHRINK_SHIFT));
> >         /*
> >          * Calculate the eviction bucket size to cover the longest
> >          * actionable refault distance, which is currently half of
> > @@ -521,7 +622,8 @@ static int __init workingset_init(void)
> >          * some more pages at runtime, so keep working with up to
> >          * double the initial memory by using totalram_pages as-is.
> >          */
> > -       timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
> > +       timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT
> > +                       - EVICTION_SECS_POS_SHIFT - EVICTION_SECS_SHRINK_SHIFT;
> >         max_order = fls_long(totalram_pages - 1);
> >         if (max_order > timestamp_bits)
> >                 bucket_order = max_order - timestamp_bits;
> > --
> > 1.9.1
> >

