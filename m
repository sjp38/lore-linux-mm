Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E333C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:54:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C35692183E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:54:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nKemgCTY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C35692183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63BD36B0007; Wed, 17 Apr 2019 17:54:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EF346B0008; Wed, 17 Apr 2019 17:54:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DBAD6B000A; Wed, 17 Apr 2019 17:54:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 16F7B6B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:54:55 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y17so175246plr.15
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:54:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=FAW0nVkqwuhtC4AE1NCD9XKd3gNjuxUVmvzah7P2H1A=;
        b=JBa1XU2a2jrEB+o9ZC4WWIMRqvxtuYoreog2LeZXFkuwmNGWkRZGMg29H0yAjA4V5V
         4T1I1jvObFN06niB+sZCDwirKkevmqxhNvMeQIZIRWhzinm+kj24xnxY1qO4Rd5CL8Uw
         Xv7hMEiUqfduWnpfBCoLptQZGIRUy5EQmK23NS7QHTQLbBFo82310DIvHS1m0atOMG/1
         IgwKxm/ox1Cp69E0VyVP1RKOlwkAdmxw4/htnUhX4H7PH603VmlpdaVmv06fsWUkuQRe
         ySp62rNCOlPIH61eI/KxlbirokH/tnAWaN/bhWJEnai1UdB6Rg3r6ItWQ+8As3A2AZbQ
         9PSQ==
X-Gm-Message-State: APjAAAXmOMyx0rdRpyutGtRdHS5k88zbnSay7N/Vj3wsVqNus81u3Nyf
	jERXEr+DZJEEGP1VO4CtWUUfDZH3a4FV82h6p5oNFplahM2/5+bfmNkSIKliCmdHBSdMyfco8/0
	VSR39JRDalaNB9IjVUZmnCiQqQJjt9P6blwx8kwd2OmqoZEPzT2l6oiA17tbJlWz8wg==
X-Received: by 2002:a63:e051:: with SMTP id n17mr85150893pgj.19.1555538094581;
        Wed, 17 Apr 2019 14:54:54 -0700 (PDT)
X-Received: by 2002:a63:e051:: with SMTP id n17mr85150834pgj.19.1555538093550;
        Wed, 17 Apr 2019 14:54:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538093; cv=none;
        d=google.com; s=arc-20160816;
        b=RvgmtNE5oBxTss1kvjPy1+mAambIvzULWBEICFlnyoLmIZiFZip/qyJqCMajZT1yrH
         GOD16nvcEH4hP+oAsgbSPC9ukrHE6DuYtzfS5UCYRdysMEDz+q/F4JKCJs57woPpMnWe
         MMv2eKirJJ1sDP9xtwIImFZFyxTvvgeyiQjIrbjQ+Xmy4ri5e+aOjBKcrnf+oBV/j/kE
         v4+Blqe0yeTYlAf7gu77CUX57oGbG4m3Nb9WVESrPIyGs2n2hTqmQfilnMgtXYiNbZ0f
         G0uoJTG1np/doH1moVP4N0Ufwmdwcryqv7Q4850wq8rfzR+Bu/zzSDiIRIgVrOqSNt/N
         0GIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=FAW0nVkqwuhtC4AE1NCD9XKd3gNjuxUVmvzah7P2H1A=;
        b=iWC2wQNL4A8m4BR/gvbnxdSnZMGcDhwKXZpbI28WOTRkMuSfpozpX2o8yI58Yw/t7X
         yhENEEN1DiPG3tVGoxPtj6FHZX3RyMTiqdPKIu4+K7Dldv8hXAdwQy+dpo/+dIazAk3p
         GBsZdPQJyKK26QUzK9En8iHdUmOGeL8zxPuxzQnVfKRy2q4NqxyxAgHWbvdLS5jT0asN
         IBCl25weBxl6NMI1Ly41ZNuOazOh6vzKfVvfsRFCZ/I9mv0mIyls6cnsX+FjoCPQSPwS
         J+mzwFqqonMyuiI0wnop7yult7F1CP6FvrWI7S/r3FC6pkL8S+fmOFqpPUUeYSJWh8VI
         vjUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nKemgCTY;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c189sor121494pfg.45.2019.04.17.14.54.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 14:54:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nKemgCTY;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=FAW0nVkqwuhtC4AE1NCD9XKd3gNjuxUVmvzah7P2H1A=;
        b=nKemgCTYYEYcMMFXJaMe29X4wv1JGY2+vxyJEtgM1uHyJUnwbzKv8VjaQqqC4fzG3C
         5fbpcIfzhUvgOieVNv9xqMKFspOjaozcprqd1UobTmJ311H60G7fwzq2WmUDzt8a9do1
         EPA4KFw/L2ognD2vOXj1HXV5NkzrZHM7Yz0DFQbhdYljPu4arzor09uIcsXxORgMXByY
         BElJZFu+tejD45qUVW+ZiK+WJLy3BZcJkN8GAl+WkaOzai4IHhVtcBc0ojvTLmdB8LNo
         uuoLc1PkXylX8Meyk5jXWe58Kmi+Oz6maxQKjOQnyuiTfxi3EXQ8P/Nct44hUl/7Sf+E
         I2CQ==
X-Google-Smtp-Source: APXvYqzXrbuKY9VZA/Q1MpKMFB7Sgk3hAnf2FWaxkQcw/dMoD+50BlAQfxWmH5BLZhAtWeSI5uuzOA==
X-Received: by 2002:a62:e710:: with SMTP id s16mr83765855pfh.74.1555538093073;
        Wed, 17 Apr 2019 14:54:53 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::5597])
        by smtp.gmail.com with ESMTPSA id x6sm209024pfb.171.2019.04.17.14.54.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 14:54:52 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	david@fromorbit.com,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	cgroups@vger.kernel.org,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 0/5] mm: reparent slab memory on cgroup removal
Date: Wed, 17 Apr 2019 14:54:29 -0700
Message-Id: <20190417215434.25897-1-guro@fb.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

# Why do we need this?

We've noticed that the number of dying cgroups is steadily growing on most
of our hosts in production. The following investigation revealed an issue
in userspace memory reclaim code [1], accounting of kernel stacks [2],
and also the mainreason: slab objects.

The underlying problem is quite simple: any page charged
to a cgroup holds a reference to it, so the cgroup can't be reclaimed unless
all charged pages are gone. If a slab object is actively used by other cgroups,
it won't be reclaimed, and will prevent the origin cgroup from being reclaimed.

Slab objects, and first of all vfs cache, is shared between cgroups, which are
using the same underlying fs, and what's even more important, it's shared
between multiple generations of the same workload. So if something is running
periodically every time in a new cgroup (like how systemd works), we do
accumulate multiple dying cgroups.

Strictly speaking pagecache isn't different here, but there is a key difference:
we disable protection and apply some extra pressure on LRUs of dying cgroups,
and these LRUs contain all charged pages.
My experiments show that with the disabled kernel memory accounting the number
of dying cgroups stabilizes at a relatively small number (~100, depends on
memory pressure and cgroup creation rate), and with kernel memory accounting
it grows pretty steadily up to several thousands.

Memory cgroups are quite complex and big objects (mostly due to percpu stats),
so it leads to noticeable memory losses. Memory occupied by dying cgroups
is measured in hundreds of megabytes. I've even seen a host with more than 100Gb
of memory wasted for dying cgroups. It leads to a degradation of performance
with the uptime, and generally limits the usage of cgroups.

My previous attempt [3] to fix the problem by applying extra pressure on slab
shrinker lists caused a regressions with xfs and ext4, and has been reverted [4].
The following attempts to find the right balance [5, 6] were not successful.

So instead of trying to find a maybe non-existing balance, let's do reparent
the accounted slabs to the parent cgroup on cgroup removal.


# Implementation approach

There is however a significant problem with reparenting of slab memory:
there is no list of charged pages. Some of them are in shrinker lists,
but not all. Introducing of a new list is really not an option.

But fortunately there is a way forward: every slab page has a stable pointer
to the corresponding kmem_cache. So the idea is to reparent kmem_caches
instead of slab pages.

It's actually simpler and cheaper, but requires some underlying changes:
1) Make kmem_caches to hold a single reference to the memory cgroup,
   instead of a separate reference per every slab page.
2) Stop setting page->mem_cgroup pointer for memcg slab pages and use
   page->kmem_cache->memcg indirection instead. It's used only on
   slab page release, so it shouldn't be a big issue.
3) Introduce a refcounter for non-root slab caches. It's required to
   be able to destroy kmem_caches when they become empty and release
   the associated memory cgroup.

There is a bonus: currently we do release empty kmem_caches on cgroup
removal, however all other are waiting for the releasing of the memory cgroup.
These refactorings allow kmem_caches to be released as soon as they
become inactive and free.

Some additional implementation details are provided in corresponding
commit messages.


# Results

Below is the average number of dying cgroups on two groups of our production
hosts. They do run some sort of web frontend workload, the memory pressure
is moderate. As we can see, with the kernel memory reparenting the number
stabilizes in 50s range; however with the original version it grows almost
linearly and doesn't show any signs of plateauing.

Releasing kmem_caches and memory cgroups created by systemd on startup
releases almost 50Mb immediately, and the difference in slab and percpu
usage between patched and unpatched versions also grows linearly.
In 6 days it reached 200Mb.

day           0    1    2    3    4    5    6
original     39  338  580  827 1098 1349 1574
patched      23   44   45   47   50   46   55
mem diff(Mb) 53   73   99  137  148  182  209


# Links

[1]: commit 68600f623d69 ("mm: don't miss the last page because of
round-off error")
[2]: commit 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
[3]: commit 172b06c32b94 ("mm: slowly shrink slabs with a relatively
small number of objects")
[4]: commit a9a238e83fbb ("Revert "mm: slowly shrink slabs
with a relatively small number of objects")
[5]: https://lkml.org/lkml/2019/1/28/1865
[6]: https://marc.info/?l=linux-mm&m=155064763626437&w=2


Roman Gushchin (5):
  mm: postpone kmem_cache memcg pointer initialization to
    memcg_link_cache()
  mm: generalize postponed non-root kmem_cache deactivation
  mm: introduce __memcg_kmem_uncharge_memcg()
  mm: rework non-root kmem_cache lifecycle management
  mm: reparent slab memory on cgroup removal

 include/linux/memcontrol.h |  10 +++
 include/linux/slab.h       |   8 +-
 mm/memcontrol.c            |  38 ++++++----
 mm/slab.c                  |  21 ++----
 mm/slab.h                  |  64 ++++++++++++++--
 mm/slab_common.c           | 147 ++++++++++++++++++++-----------------
 mm/slub.c                  |  32 +-------
 7 files changed, 185 insertions(+), 135 deletions(-)

-- 
2.20.1

