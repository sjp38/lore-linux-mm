Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E947BC10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 07:59:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 846172054F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 07:59:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c1v4SK4Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 846172054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C25C6B000A; Wed, 17 Apr 2019 03:59:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0710F6B000C; Wed, 17 Apr 2019 03:59:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7A576B000D; Wed, 17 Apr 2019 03:59:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 94F4B6B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 03:59:27 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m47so6282742edd.15
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 00:59:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to;
        bh=jQL+/hzVQKWUcXK58myvXbK+OrvlIIBcgeWycPAqydM=;
        b=cDzb+rrt8V0YnUBm5egx6qRlycISG30LF+Ba8lhQtA/PNaPvIWI0wsIujzuBhPHA2h
         53l9841Z/OA2EpOPmx/7nM8QH05JvOOxWusu+uUD/ThV1jImuUvMTgSYRcuD1QiJkg7o
         Zf3G9jZnsJwciScuBHm62ZYT+rhZcb5kswlyNN/3kpAhfEypVIBUOqgEHTqQjeyOG/Ow
         rN8RTij0YYlXsg3gLJNXaDeLorj69DQ8OnKt/ZPGjLAHbQFoJyjxGuM5PBJpRxJMaHM3
         HJLv2x3WS8bNif//szf1yvyk48oi2YLit+JnAUM3+0BLN+K3x1HTEAKaOThlcdooONyc
         DF8A==
X-Gm-Message-State: APjAAAUgvfrFk4wZV1Wxk0lD0lNE94GeGrantliNeZU+VQJ28q/7uccf
	6Y2tZUzjfJwkurviFhmjTQ3Xa+y6dTSerhnZrFPuUun4fAA2EG/mIeSv/r0PYc0taoqn56YmGgr
	8rcpuk5197SstPzDgjE+X8nJhMISbzzwchKllOvA+geXT9EyogKoZnPZ9j2YyeekOWw==
X-Received: by 2002:a17:906:bc2:: with SMTP id y2mr37082661ejg.98.1555487966993;
        Wed, 17 Apr 2019 00:59:26 -0700 (PDT)
X-Received: by 2002:a17:906:bc2:: with SMTP id y2mr37082607ejg.98.1555487965724;
        Wed, 17 Apr 2019 00:59:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555487965; cv=none;
        d=google.com; s=arc-20160816;
        b=x26WJ6fOPdj4RiQyHwI3lH5UCISLQMZYHCMK5dEpNiaVB9R1R/jXe+kOsVimdyxZpY
         J4Sh60uvqvdv6r394gsvd7zw4nhsQ3t4dFtRJKqiq3jmsgX6mMojDzKo9bMsbeiqiOUB
         wU2JP2YZVXQE4zn1rUvid6F+JR5VQMUNBV9fZJvRVHDdqDtk7sBmhzXMgp9gmqQLPayl
         HjONG030gVNy2pXqvaHXjc6V41TCPc1egTx83U7owHwmksEPZHzuKYb8H30FNY/APyyQ
         F0ubxnE2YOqvuz72xMvDssvohAjLuCDqFqKfkl1ZN9KRggB376UwW9/8KvJLsBRZ8vbY
         hW9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=jQL+/hzVQKWUcXK58myvXbK+OrvlIIBcgeWycPAqydM=;
        b=erfzo3DLizvcE2GwmklC5f+XcsHY61VWzRT4ir51CotB0iJLgq9/q5voBygFH2mzEw
         q6EPgVDe6IBez35TxWkRvELC01YizvC9FV6lIh1vvDot3c3KL0UHvIVasA+JcnWXzvXi
         3OLLUCyr7b1xSs4iquhI446QPQj/3GQeD+ixFVZ9g0K0yUp4Ua8ENYyUgBS1ER6xCLN1
         b9ke4BAND1ezHU3g6aNcyL6de62cdeygRRVUkm/1qX4KJCtvdHrDY6xAQ4kn1kRjL63Q
         q6m2pcml/YBNn1KjomhfuzFqb0K9WYBfz0LJrFoORfMSJkH6+LtWrZ1JF6L/uEumuK9L
         eboA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=c1v4SK4Z;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gw18sor11530686ejb.60.2019.04.17.00.59.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 00:59:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=c1v4SK4Z;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=jQL+/hzVQKWUcXK58myvXbK+OrvlIIBcgeWycPAqydM=;
        b=c1v4SK4Z6waVLTMxG/3vhnt+2e1modPUViHrZiLAq2V+hCJlKyO7p4wAtK5qyHq9j4
         SLTvl2Me9IVKistTIOmYRK/xTqDVvgpDhw7j06HErVpfyB4hz4dxCSlAT9oCrUlGCGfB
         ++B6Eg0NXD0pcN3yJ/yzpPLJtqaJYbogs/l6CNwvdxH/Dn/LyJhm0hmJcoDUryfu9vTe
         GOVTSY/FKXqHRDQMeWBET8Ef3jFlPnmHkax3zdrRHQvpPiYI/QAgVPqfOvWjJ7z73/jM
         0PZ3tWT7RyRyXa1vtrFMLcVYqV07YIpZUgdy8vROKQqPXiQqg4qq29IYQ6kEV0Gk1wnW
         26AQ==
X-Google-Smtp-Source: APXvYqwlLVcOMeJtr4wNVo5XRadsqKuP+HYJznYQvqQ0e4bLkZWQUGF4lNAhVltOW4+jGW/xJPXjiKyrXUOFH6GlGY4=
X-Received: by 2002:a17:906:7b86:: with SMTP id s6mr45805184ejo.144.1555487965356;
 Wed, 17 Apr 2019 00:59:25 -0700 (PDT)
MIME-Version: 1.0
References: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
In-Reply-To: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Wed, 17 Apr 2019 15:59:03 +0800
Message-ID: <CAGWkznFCy-Fm1WObEk77shPGALWhn5dWS3ZLXY77+q_4Yp6bAQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/workingset : judge file page activity via timestamp
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, 
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>, Roman Gushchin <guro@fb.com>, 
	Jeff Layton <jlayton@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, 
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

add Johannes and answer his previous question.

@Johannes Weiner
Yes. I do agree with you about the original thought of sacrificing
long distance access pages when huge memory demands arise. The problem
is what is the criteria of the distance, which you can find from what
I comment in the patch, that is, some pages have long refault_distance
while having a very short access time in between. I think the latter
one should be take into consideration or as part of the finnal
decision of if the page should be active/inactive.

On Wed, Apr 17, 2019 at 3:48 PM Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:
>
> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
>
> This patch introduce timestamp into workingset's entry and judge if the page
> is active or inactive via active_file/refault_ratio instead of refault distance.
>
> The original thought is coming from the logs we got from trace_printk in this
> patch, we can find about 1/5 of the file pages' refault are under the
> scenario[1],which will be counted as inactive as they have a long refault distance
> in between access. However, we can also know from the time information that the
> page refault quickly as comparing to the average refault time which is calculated
> by the number of active file and refault ratio. We want to save these kinds of
> pages from evicted earlier as it used to be. The refault ratio is the value
> which can reflect lru's average file access frequency and also can be deemed as a
> prediction of future.
>
> The patch is tested on an android system and reduce 30% of page faults, while
> 60% of the pages remain the original status as (refault_distance < active_file)
> indicates. Pages status got from ftrace during the test can refer to [2].
>
> [1]
> system_server workingset_refault: WKST_ACT[0]:rft_dis 265976, act_file 34268 rft_ratio 3047 rft_time 0 avg_rft_time 11 refault 295592 eviction 29616 secs 97 pre_secs 97
> HwBinder:922  workingset_refault: WKST_ACT[0]:rft_dis 264478, act_file 35037 rft_ratio 3070 rft_time 2 avg_rft_time 11 refault 310078 eviction 45600 secs 101 pre_secs 99
>
> [2]
> WKST_ACT[0]:   original--INACTIVE  commit--ACTIVE
> WKST_ACT[1]:   original--ACTIVE    commit--ACTIVE
> WKST_INACT[0]: original--INACTIVE  commit--INACTIVE
> WKST_INACT[1]: original--ACTIVE    commit--INACTIVE
>
> Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
> ---
>  include/linux/mmzone.h |   1 +
>  mm/workingset.c        | 120 +++++++++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 112 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 32699b2..6f30673 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -240,6 +240,7 @@ struct lruvec {
>         atomic_long_t                   inactive_age;
>         /* Refaults at the time of last reclaim cycle */
>         unsigned long                   refaults;
> +       atomic_long_t                   refaults_ratio;
>  #ifdef CONFIG_MEMCG
>         struct pglist_data *pgdat;
>  #endif
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 40ee02c..66c177b 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -160,6 +160,21 @@
>                          MEM_CGROUP_ID_SHIFT)
>  #define EVICTION_MASK  (~0UL >> EVICTION_SHIFT)
>
> +#ifdef CONFIG_64BIT
> +#define EVICTION_SECS_POS_SHIFT 20
> +#define EVICTION_SECS_SHRINK_SHIFT 4
> +#define EVICTION_SECS_POS_MASK  ((1UL << EVICTION_SECS_POS_SHIFT) - 1)
> +#else
> +#ifndef CONFIG_MEMCG
> +#define EVICTION_SECS_POS_SHIFT 12
> +#define EVICTION_SECS_SHRINK_SHIFT 4
> +#define EVICTION_SECS_POS_MASK  ((1UL << EVICTION_SECS_POS_SHIFT) - 1)
> +#else
> +#define EVICTION_SECS_POS_SHIFT 0
> +#define EVICTION_SECS_SHRINK_SHIFT 0
> +#define NO_SECS_IN_WORKINGSET
> +#endif
> +#endif
>  /*
>   * Eviction timestamps need to be able to cover the full range of
>   * actionable refaults. However, bits are tight in the radix tree
> @@ -169,10 +184,54 @@
>   * evictions into coarser buckets by shaving off lower timestamp bits.
>   */
>  static unsigned int bucket_order __read_mostly;
> -
> +#ifdef NO_SECS_IN_WORKINGSET
> +static void pack_secs(unsigned long *peviction) { }
> +static unsigned int unpack_secs(unsigned long entry) {return 0; }
> +#else
> +/*
> + * Shrink the timestamp according to its value and store it together
> + * with the shrink size in the entry.
> + */
> +static void pack_secs(unsigned long *peviction)
> +{
> +       unsigned int secs;
> +       unsigned long eviction;
> +       int order;
> +       int secs_shrink_size;
> +       struct timespec ts;
> +
> +       get_monotonic_boottime(&ts);
> +       secs = (unsigned int)ts.tv_sec ? (unsigned int)ts.tv_sec : 1;
> +       order = get_count_order(secs);
> +       secs_shrink_size = (order <= EVICTION_SECS_POS_SHIFT)
> +                       ? 0 : (order - EVICTION_SECS_POS_SHIFT);
> +
> +       eviction = *peviction;
> +       eviction = (eviction << EVICTION_SECS_POS_SHIFT)
> +                       | ((secs >> secs_shrink_size) & EVICTION_SECS_POS_MASK);
> +       eviction = (eviction << EVICTION_SECS_SHRINK_SHIFT) | (secs_shrink_size & 0xf);
> +       *peviction = eviction;
> +}
> +/*
> + * Unpack the second from the entry and restore the value according to the
> + * shrink size.
> + */
> +static unsigned int unpack_secs(unsigned long entry)
> +{
> +       unsigned int secs;
> +       int secs_shrink_size;
> +
> +       secs_shrink_size = entry & ((1 << EVICTION_SECS_SHRINK_SHIFT) - 1);
> +       entry >>= EVICTION_SECS_SHRINK_SHIFT;
> +       secs = entry & EVICTION_SECS_POS_MASK;
> +       secs = secs << secs_shrink_size;
> +       return secs;
> +}
> +#endif
>  static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
>  {
>         eviction >>= bucket_order;
> +       pack_secs(&eviction);
>         eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
>         eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
>         eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
> @@ -181,20 +240,24 @@ static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
>  }
>
>  static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
> -                         unsigned long *evictionp)
> +                         unsigned long *evictionp, unsigned int *prev_secs)
>  {
>         unsigned long entry = (unsigned long)shadow;
>         int memcgid, nid;
> +       unsigned int secs;
>
>         entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
>         nid = entry & ((1UL << NODES_SHIFT) - 1);
>         entry >>= NODES_SHIFT;
>         memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
>         entry >>= MEM_CGROUP_ID_SHIFT;
> +       secs = unpack_secs(entry);
> +       entry >>= (EVICTION_SECS_POS_SHIFT + EVICTION_SECS_SHRINK_SHIFT);
>
>         *memcgidp = memcgid;
>         *pgdat = NODE_DATA(nid);
>         *evictionp = entry << bucket_order;
> +       *prev_secs = secs;
>  }
>
>  /**
> @@ -242,9 +305,22 @@ bool workingset_refault(void *shadow)
>         unsigned long refault;
>         struct pglist_data *pgdat;
>         int memcgid;
> +#ifndef NO_SECS_IN_WORKINGSET
> +       unsigned long avg_refault_time;
> +       unsigned long refault_time;
> +       int tradition;
> +       unsigned int prev_secs;
> +       unsigned int secs;
> +       unsigned long refaults_ratio;
> +#endif
> +       struct timespec ts;
> +       /*
> +       convert jiffies to second
> +       */
> +       get_monotonic_boottime(&ts);
> +       secs = (unsigned int)ts.tv_sec ? (unsigned int)ts.tv_sec : 1;
>
> -       unpack_shadow(shadow, &memcgid, &pgdat, &eviction);
> -
> +       unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &prev_secs);
>         rcu_read_lock();
>         /*
>          * Look up the memcg associated with the stored ID. It might
> @@ -288,14 +364,37 @@ bool workingset_refault(void *shadow)
>          * list is not a problem.
>          */
>         refault_distance = (refault - eviction) & EVICTION_MASK;
> -
>         inc_lruvec_state(lruvec, WORKINGSET_REFAULT);
> -
> -       if (refault_distance <= active_file) {
> +#ifndef NO_SECS_IN_WORKINGSET
> +       refaults_ratio = (atomic_long_read(&lruvec->inactive_age) + 1) / secs;
> +       atomic_long_set(&lruvec->refaults_ratio, refaults_ratio);
> +       refault_time = secs - prev_secs;
> +       avg_refault_time = active_file / refaults_ratio;
> +       tradition = !!(refault_distance < active_file);
> +       if (refault_time <= avg_refault_time) {
> +#else
> +       if (refault_distance < active_file) {
> +#endif
>                 inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
> +#ifndef NO_SECS_IN_WORKINGSET
> +               trace_printk("WKST_ACT[%d]:rft_dis %ld, act_file %ld \
> +                               rft_ratio %ld rft_time %ld avg_rft_time %ld \
> +                               refault %ld eviction %ld secs %d pre_secs %d\n",
> +                               tradition, refault_distance, active_file,
> +                               refaults_ratio, refault_time, avg_refault_time,
> +                               refault, eviction, secs, prev_secs);
> +#endif
>                 rcu_read_unlock();
>                 return true;
>         }
> +#ifndef NO_SECS_IN_WORKINGSET
> +       trace_printk("WKST_INACT[%d]:rft_dis %ld, act_file %ld \
> +                       rft_ratio %ld rft_time %ld avg_rft_time %ld \
> +                       refault %ld eviction %ld secs %d pre_secs %d\n",
> +                       tradition, refault_distance, active_file,
> +                       refaults_ratio, refault_time, avg_refault_time,
> +                       refault, eviction, secs, prev_secs);
> +#endif
>         rcu_read_unlock();
>         return false;
>  }
> @@ -513,7 +612,9 @@ static int __init workingset_init(void)
>         unsigned int max_order;
>         int ret;
>
> -       BUILD_BUG_ON(BITS_PER_LONG < EVICTION_SHIFT);
> +       BUILD_BUG_ON(BITS_PER_LONG < (EVICTION_SHIFT
> +                               + EVICTION_SECS_POS_SHIFT
> +                               + EVICTION_SECS_SHRINK_SHIFT));
>         /*
>          * Calculate the eviction bucket size to cover the longest
>          * actionable refault distance, which is currently half of
> @@ -521,7 +622,8 @@ static int __init workingset_init(void)
>          * some more pages at runtime, so keep working with up to
>          * double the initial memory by using totalram_pages as-is.
>          */
> -       timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
> +       timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT
> +                       - EVICTION_SECS_POS_SHIFT - EVICTION_SECS_SHRINK_SHIFT;
>         max_order = fls_long(totalram_pages - 1);
>         if (max_order > timestamp_bits)
>                 bucket_order = max_order - timestamp_bits;
> --
> 1.9.1
>

