Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3CEBC46460
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:32:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B047216C4
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:32:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="knPK6xaK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B047216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BE8C6B0003; Fri, 10 May 2019 20:32:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 048746B0005; Fri, 10 May 2019 20:32:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2A7D6B0006; Fri, 10 May 2019 20:32:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA66C6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 20:32:28 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 201so12789628ywr.13
        for <linux-mm@kvack.org>; Fri, 10 May 2019 17:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=41ax0xLOxm/LrOT3A3tZ5B68ILUGPJLp0atAjy77i6o=;
        b=B3fx1fAqZ9C1UOgT1V6lSy+JIsX/ZFPhPGQX4uawZFY0mO45IbIUK8PsRwdXbZCqAU
         z6QYMxpKDPVKMk9LUF93sD9BYTdU+APvcNGjKYKF3axlu0lXkgdX/o553uGp268Dw65h
         5uICOQyEtHN6MdE7aK/lp4TRJV4qtGkQ5jSErlyHfqT2048Xa/e96z28EWUc8TAyA8/A
         lvfq/T2GCOhAdfJyinRNkSCLP0QmglRes7sC7Yx6pA/IWkn6vgJVegwgEXgCWP0Etz6D
         /2ocAiwvSlZkpk3MMXZ6KG0fCdvUeuBEwFdV82ST35ei3355AL5hL15AhBjCbxUe9zCT
         I2aA==
X-Gm-Message-State: APjAAAVEjCd9mJKzGGcWGZA5PbCWTkvYFcu2zWR8Hsim79t6kscXaG+0
	MKoMLxdwcSr5pnEDjRsOXHCeOGbQ9GlYeOHn+V3OMRB/xJlyh5jqRsadSCtmp1wqmsUODqU9gXz
	vEBdwzSDv7IR6uJ3QzQbd+jNugEAZ0DmDgrZ5BjQTDUBV37XbCKTP2AASdIs3hO3Miw==
X-Received: by 2002:a25:393:: with SMTP id 141mr7451400ybd.374.1557534748411;
        Fri, 10 May 2019 17:32:28 -0700 (PDT)
X-Received: by 2002:a25:393:: with SMTP id 141mr7451370ybd.374.1557534747464;
        Fri, 10 May 2019 17:32:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557534747; cv=none;
        d=google.com; s=arc-20160816;
        b=bQMCJBl2QyqGQgStR+BGdaIpsH29dn31uZF7kJvIEDz3QEp3pihFRbNQzGBsvhsWO0
         VGUNRIVTefKXv2X4lQMkfilAunYVE8WonWtreTKPoaq5nNkwJR9FxXZg+IqIlKsVYp65
         iwxV6oHUKCAZIeaYemw2vyT2zLpcEQ7b8r04tE3VgxruZ8puSMsXPDZJDIRbjl4+MWuf
         GIpIPcjdE+SlYbEXv9vNvcUO9QjCFrm53oH0Vjh2IbCoiDh7dfO4r224afN03M1Z5E+v
         iXuICXZL7Va6g+M1omV8D3O0d+xQpnsGz4syCTBLVaIsooQoWFZhtwkx0ezelPF0mKMB
         G6ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=41ax0xLOxm/LrOT3A3tZ5B68ILUGPJLp0atAjy77i6o=;
        b=s6kWc19/JM9fMGu+3CxQqPEkJU5mTBhNQMBhVnRSodxbjhbOrkXX9vYghCzPuvNt70
         oXFRNqJq82cEgUlCU6S45IA2PvSpsRd66Q6ebfjaOt1qeBoxcgHF8e4YfvFLEIq7hEwv
         iz/k0RVs3usp/zNzPfr925qIGZypWbk0qHOHFWwK2VlVcJV5Tr6G8zqpghVn4RXF8H4x
         2PNjGzeI0neuMzzNW3TzYtId9VIIvF+nV5S0t02Jlhs02+APnq1G5jM7r+Da9H06wJbA
         kMQpvE6Yhe/JuKy9xy58DbdBiZ49nrd2Bxttp1w+7FMu/OCVVGIpWihEw2wa1Os/OKna
         CZxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=knPK6xaK;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i9sor3550861ybi.206.2019.05.10.17.32.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 17:32:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=knPK6xaK;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=41ax0xLOxm/LrOT3A3tZ5B68ILUGPJLp0atAjy77i6o=;
        b=knPK6xaKmMuLYUQlJOQ8p1WN4FUsPoYO9+yBhUOxRA+nPaF4tMaKtzK1UFnZDzAnR1
         /7ZEFdZi1ZbuE9I3FRiEU3+KECOjMfdBjCpQCllIlFGQqV+xwWEUus+IDnH4fcal2oaD
         DjmoJByG6r4hHkO01Y94+VpiK7veWvFZ1aBvLXGc+pnUvWCGXZzrFJ6KExypnFK+7UOm
         OAuK706LwUs9cnAwAIIdcB3l0WPuPMj8SQMz+0QgGkVwud+jjbE72x9QRvwJCH1Zsa/V
         XTxyykrqLQYsS6/QTMG4G37djT9cil0+EoWGLw3H3F7g9ik+dDkMxgQgA7zFEaLWS2Ss
         xGWA==
X-Google-Smtp-Source: APXvYqwjns9n0oUciPRms5JJERnoBElcCJ1mcZ+OMgwpDHiPtM7z27hQetG1tauEX2cSfVOPTcBEXoIakE6PJoEEXqY=
X-Received: by 2002:a25:f507:: with SMTP id a7mr7198027ybe.164.1557534746760;
 Fri, 10 May 2019 17:32:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190508202458.550808-1-guro@fb.com>
In-Reply-To: <20190508202458.550808-1-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 10 May 2019 17:32:15 -0700
Message-ID: <CALvZod4WGVVq+UY_TZdKP_PHdifDrkYqPGgKYTeUB6DsxGAdVw@mail.gmail.com>
Subject: Re: [PATCH v3 0/7] mm: reparent slab memory on cgroup removal
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <kernel-team@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, 
	Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Roman Gushchin <guro@fb.com>
Date: Wed, May 8, 2019 at 1:30 PM
To: Andrew Morton, Shakeel Butt
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
<kernel-team@fb.com>, Johannes Weiner, Michal Hocko, Rik van Riel,
Christoph Lameter, Vladimir Davydov, <cgroups@vger.kernel.org>, Roman
Gushchin

> # Why do we need this?
>
> We've noticed that the number of dying cgroups is steadily growing on most
> of our hosts in production. The following investigation revealed an issue
> in userspace memory reclaim code [1], accounting of kernel stacks [2],
> and also the mainreason: slab objects.
>
> The underlying problem is quite simple: any page charged
> to a cgroup holds a reference to it, so the cgroup can't be reclaimed unless
> all charged pages are gone. If a slab object is actively used by other cgroups,
> it won't be reclaimed, and will prevent the origin cgroup from being reclaimed.
>
> Slab objects, and first of all vfs cache, is shared between cgroups, which are
> using the same underlying fs, and what's even more important, it's shared
> between multiple generations of the same workload. So if something is running
> periodically every time in a new cgroup (like how systemd works), we do
> accumulate multiple dying cgroups.
>
> Strictly speaking pagecache isn't different here, but there is a key difference:
> we disable protection and apply some extra pressure on LRUs of dying cgroups,

How do you apply extra pressure on dying cgroups? cgroup-v2 does not
have memory.force_empty.


> and these LRUs contain all charged pages.
> My experiments show that with the disabled kernel memory accounting the number
> of dying cgroups stabilizes at a relatively small number (~100, depends on
> memory pressure and cgroup creation rate), and with kernel memory accounting
> it grows pretty steadily up to several thousands.
>
> Memory cgroups are quite complex and big objects (mostly due to percpu stats),
> so it leads to noticeable memory losses. Memory occupied by dying cgroups
> is measured in hundreds of megabytes. I've even seen a host with more than 100Gb
> of memory wasted for dying cgroups. It leads to a degradation of performance
> with the uptime, and generally limits the usage of cgroups.
>
> My previous attempt [3] to fix the problem by applying extra pressure on slab
> shrinker lists caused a regressions with xfs and ext4, and has been reverted [4].
> The following attempts to find the right balance [5, 6] were not successful.
>
> So instead of trying to find a maybe non-existing balance, let's do reparent
> the accounted slabs to the parent cgroup on cgroup removal.
>
>
> # Implementation approach
>
> There is however a significant problem with reparenting of slab memory:
> there is no list of charged pages. Some of them are in shrinker lists,
> but not all. Introducing of a new list is really not an option.
>
> But fortunately there is a way forward: every slab page has a stable pointer
> to the corresponding kmem_cache. So the idea is to reparent kmem_caches
> instead of slab pages.
>
> It's actually simpler and cheaper, but requires some underlying changes:
> 1) Make kmem_caches to hold a single reference to the memory cgroup,
>    instead of a separate reference per every slab page.
> 2) Stop setting page->mem_cgroup pointer for memcg slab pages and use
>    page->kmem_cache->memcg indirection instead. It's used only on
>    slab page release, so it shouldn't be a big issue.
> 3) Introduce a refcounter for non-root slab caches. It's required to
>    be able to destroy kmem_caches when they become empty and release
>    the associated memory cgroup.
>
> There is a bonus: currently we do release empty kmem_caches on cgroup
> removal, however all other are waiting for the releasing of the memory cgroup.
> These refactorings allow kmem_caches to be released as soon as they
> become inactive and free.
>
> Some additional implementation details are provided in corresponding
> commit messages.
>
>
> # Results
>
> Below is the average number of dying cgroups on two groups of our production
> hosts. They do run some sort of web frontend workload, the memory pressure
> is moderate. As we can see, with the kernel memory reparenting the number
> stabilizes in 50s range; however with the original version it grows almost
> linearly and doesn't show any signs of plateauing. The difference in slab
> and percpu usage between patched and unpatched versions also grows linearly.
> In 6 days it reached 200Mb.
>
> day           0    1    2    3    4    5    6
> original     39  338  580  827 1098 1349 1574
> patched      23   44   45   47   50   46   55
> mem diff(Mb) 53   73   99  137  148  182  209
>
>
> # History
>
> v3:
>   1) reworked memcg kmem_cache search on allocation path
>   2) fixed /proc/kpagecgroup interface
>
> v2:
>   1) switched to percpu kmem_cache refcounter
>   2) a reference to kmem_cache is held during the allocation
>   3) slabs stats are fixed for !MEMCG case (and the refactoring
>      is separated into a standalone patch)
>   4) kmem_cache reparenting is performed from deactivatation context
>
> v1:
>   https://lkml.org/lkml/2019/4/17/1095
>
>
> # Links
>
> [1]: commit 68600f623d69 ("mm: don't miss the last page because of
> round-off error")
> [2]: commit 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
> [3]: commit 172b06c32b94 ("mm: slowly shrink slabs with a relatively
> small number of objects")
> [4]: commit a9a238e83fbb ("Revert "mm: slowly shrink slabs
> with a relatively small number of objects")
> [5]: https://lkml.org/lkml/2019/1/28/1865
> [6]: https://marc.info/?l=linux-mm&m=155064763626437&w=2
>
>
> Roman Gushchin (7):
>   mm: postpone kmem_cache memcg pointer initialization to
>     memcg_link_cache()
>   mm: generalize postponed non-root kmem_cache deactivation
>   mm: introduce __memcg_kmem_uncharge_memcg()
>   mm: unify SLAB and SLUB page accounting
>   mm: rework non-root kmem_cache lifecycle management
>   mm: reparent slab memory on cgroup removal
>   mm: fix /proc/kpagecgroup interface for slab pages
>
>  include/linux/memcontrol.h |  10 +++
>  include/linux/slab.h       |  13 ++--
>  mm/memcontrol.c            |  97 ++++++++++++++++--------
>  mm/slab.c                  |  25 ++----
>  mm/slab.h                  | 120 +++++++++++++++++++++--------
>  mm/slab_common.c           | 151 ++++++++++++++++++++-----------------
>  mm/slub.c                  |  36 ++-------
>  7 files changed, 267 insertions(+), 185 deletions(-)
>
> --
> 2.20.1
>

