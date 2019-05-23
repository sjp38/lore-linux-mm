Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9D02C04AAC
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 04:57:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54DAC20881
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 04:57:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AVCZCgXw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54DAC20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE3DB6B0003; Thu, 23 May 2019 00:57:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D94C46B0006; Thu, 23 May 2019 00:57:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C81BA6B0007; Thu, 23 May 2019 00:57:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id A813D6B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 00:57:20 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z2so3723020iog.12
        for <linux-mm@kvack.org>; Wed, 22 May 2019 21:57:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6GvvhoV5tuEA7YN7GezTmuQTjTWspYSTINuWJweWn1s=;
        b=pJXL/vaGcFolInmv2zHrArTsHoMO9ZDMHAGDls2O3a6CNe/evoG7TDIgF7TOCJoPqu
         gPpVk+t2QQ2bVz97l07GPGQGNBHYMeu9n/W1mmUMUF6w9eKmywmU8hXLLvrxxD57Lo+4
         SHzqACls8z1E00Ui1JrTvip/xY7rR76RDuD+zLDCvJAJGmb2kfDKDVLmgKYGsePNNmyH
         1bHDPPjCB3aW9q9vM5yyqT0RMXAFVaeIdg8SwF5LxJi1FKOWSE/a5RCCY3e6HMTSEVm8
         c/vVVD5OztE9NA5l1UB4RMv3P9MWFq1qOZZTlbkIeR60Tt+I2YmvTCcUtPlqtDTog39u
         rTOA==
X-Gm-Message-State: APjAAAXYrVbP0VKTs/pD/v8ESYLIHU9yHq9JRrE6M+4kB3Co59Hc4Znm
	o87YAGYBGdAcsYNVvrnAY+MnnANbnAt0845olcyNIFbZTQZhAy7skQnkLvs8Nc68/pO/ABoIvzK
	Je/BLxev0IhR0Yg178SY3pCurwMLT9x4/7gEAaP2/g8imapQuwdc7PdQe+61grZKbnw==
X-Received: by 2002:a24:55cf:: with SMTP id e198mr11179162itb.28.1558587440448;
        Wed, 22 May 2019 21:57:20 -0700 (PDT)
X-Received: by 2002:a24:55cf:: with SMTP id e198mr11179132itb.28.1558587439637;
        Wed, 22 May 2019 21:57:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558587439; cv=none;
        d=google.com; s=arc-20160816;
        b=y+HDtXlMW8wl4px56j/AfJGLwXpIQ5fcRpsPks9zy4JRiv9qBMSBaC/7J4rnj6cUbX
         HO2cmurH89d64zfB9N8MHULEumRpp8juHU16uRafuaFkcv5WdzOK7A/WnYQZl2QJbbYv
         PoGdmvXYWEI3ZGe/2YzC41RMqiF/jzrwTx0OG6U7eXXVtGFhjJwzAGploT7h9X1ca7L6
         1aWbylud11kIGzhtaSRHx7k3gQM3iKJQOykJnaq8KDUEOl/mBnE/yRq7j3I406dShAqz
         iCOVWJGP1R+qKl/qjkdub2nrB0u4Zi2yHaScn5p2HnYVwTWy87C/+UUMQKI48kJVPaVf
         MU4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6GvvhoV5tuEA7YN7GezTmuQTjTWspYSTINuWJweWn1s=;
        b=amU+zanI3miYI/SkH1FGlq+YDerr3g5sttRngOUAD1oHFaNYNZfQiH/mQ30aXcNIwo
         EbcLF2B1aZoeNO/NU4qKV7UymvDhQFLwxZU8XS/JkKVuPC4HQs+RAslQRjgVW/QdeUlM
         mSQg9Pqn+bUUDGskX0hENii6W/OGi0KI7WY/hTp8++1bUWHB9Ea1qVsUzBVa+B5tMOao
         mN4v3MgWqvOeV+nRFeRDCF/dN3XlhnaD6GdpPgvUI2Ao6241aBPeHlJ+ITvmbVsirqgu
         NuMfjBVCDuApXm1CuQ7LuHXwgVDjaaQe3ZmyXnpOm9tnymP2ffak9wYeWaQ+xJQqDsGM
         0zng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AVCZCgXw;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor13199068iof.140.2019.05.22.21.57.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 21:57:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AVCZCgXw;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6GvvhoV5tuEA7YN7GezTmuQTjTWspYSTINuWJweWn1s=;
        b=AVCZCgXwB6gvx7tvNK1Pt3RdMgpl/5NSawlYJZpYNedNwDLm1uhhEP23F2M6qQBSdn
         glj9GNbaHt/hzJnZHVw245g4bxVQS7mQ1CGzxG3scd4OhUXsr6XlL+7vCgesMpBTIZr0
         lxA7R+2zrtHobUn4jLm/DO7OeqKb2jiGG+NOE3khms5pXN9HdE13O9gk73aRSLvNyqfn
         gHWqccGgteVHXMVnK048b3CzDImtO0KGpq2uST+8NhSCfL1blpRWqKwQFrzbpsMbITWl
         BZ1cGQ5/sMEZp+VK/WSK/wtyH2GE1iijGlgVm1G0LOvmrLAZDpqAxxKrqxvdVTGZDUd4
         Y10Q==
X-Google-Smtp-Source: APXvYqy9Gaq8iYnWYjy5NvvDJozskvY+bp46SgUnHo44GMgXlkPTuUwKeA0C994XxtEIQI05oENDD1CXEb8/owBYQ5U=
X-Received: by 2002:a05:6602:2049:: with SMTP id z9mr27477680iod.46.1558587439089;
 Wed, 22 May 2019 21:57:19 -0700 (PDT)
MIME-Version: 1.0
References: <1557389269-31315-1-git-send-email-laoar.shao@gmail.com>
 <1557389269-31315-2-git-send-email-laoar.shao@gmail.com> <20190522144014.9ea621c56cd80461fcd26a61@linux-foundation.org>
In-Reply-To: <20190522144014.9ea621c56cd80461fcd26a61@linux-foundation.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 23 May 2019 12:56:42 +0800
Message-ID: <CALOAHbCLRH1otrXkBKe1JD0w8YuRhXoi8yrkAUxDvdyv+FJ4eg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/vmscan: shrink slab in node reclaim
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 5:40 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Thu,  9 May 2019 16:07:49 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:
>
> > In the node reclaim, may_shrinkslab is 0 by default,
> > hence shrink_slab will never be performed in it.
> > While shrik_slab should be performed if the relcaimable slab is over
> > min slab limit.
> >
> > This issue is very easy to produce, first you continuously cat a random
> > non-exist file to produce more and more dentry, then you read big file
> > to produce page cache. And finally you will find that the denty will
> > never be shrunk.
>
> It does sound like an oversight.
>
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -4141,6 +4141,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >               .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> >               .may_swap = 1,
> >               .reclaim_idx = gfp_zone(gfp_mask),
> > +             .may_shrinkslab = node_page_state(pgdat, NR_SLAB_RECLAIMABLE) >
> > +                               pgdat->min_slab_pages,
> >       };
> >
> >       trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > @@ -4158,15 +4160,13 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >       reclaim_state.reclaimed_slab = 0;
> >       p->reclaim_state = &reclaim_state;
> >
> > -     if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
>
> Would it be better to do
>
>         if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages ||
>                         sc.may_shrinkslab) {
>

This if condition is always true here, because we already check them
in node_reclaim(),
see bellow,

    if (node_pagecache_reclaimable(pgdat) <= pgdat->min_unmapped_pages &&
        node_page_state(pgdat, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
        return NODE_RECLAIM_FULL;


> >               /*
> >                * Free memory by calling shrink node with increasing
> >                * priorities until we have enough memory freed.
> >                */
>
> The above will want re-indenting and re-right-justifying.
>

Sorry about the carelessness.

> > -             do {
> > -                     shrink_node(pgdat, &sc);
> > -             } while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
> > -     }
> > +     do {
> > +             shrink_node(pgdat, &sc);
> > +     } while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
>
> Won't this cause pagecache reclaim and compaction which previously did
> not occur?  If yes, what are the effects of this and are they
> desirable?  If no, perhaps call shrink_slab() directly in this case.
> Or something like that.
>

It may cause pagecache reclaim and compaction even if
node_pagecache_reclaimable() is still less than
pgdat->min_unmapped_pages.
The active file will be deactivated and the inactive file will be recaimed.
(I traced these behavior with mm_vmscan_lru_shrink_active and
mm_vmscan_lru_shrink_inactive tracepoint)

If we don't like these behavior, what about bellow change ?

@@ -4166,6 +4166,17 @@ static int __node_reclaim(struct pglist_data
*pgdat, gfp_t gfp_mask, unsigned in
                do {
                        shrink_node(pgdat, &sc);
                } while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
+       } else {
+               struct mem_cgroup *memcg;
+               struct mem_cgroup_reclaim_cookie reclaim = {
+                        .pgdat = pgdat,
+                        .priority = sc.priority,
+                };
+
+               memcg = mem_cgroup_iter(false, NULL, &reclaim);
+               do {
+                       shrink_slab(sc.gfp_mask, pgdat->node_id,
memcg, sc.priority);
+               } while ((memcg = mem_cgroup_iter(false, memcg, &reclaim)));

        }


> It's unclear why min_unmapped_pages (min_unmapped_ratio) exists. Is it

I have tried to understand it, but still don't have a clear idea yet.
So I just let it as-is.

> a batch-things-up efficiency thing?

I guess so.

Thanks
Yafang

