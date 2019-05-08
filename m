Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A7FAC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:30:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C3FF20675
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:30:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="fKRD9CRa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C3FF20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E0036B0007; Wed,  8 May 2019 16:30:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8341D6B0008; Wed,  8 May 2019 16:30:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 685B86B000C; Wed,  8 May 2019 16:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 250F76B0007
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:30:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d22so48799pgg.2
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:30:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=bkxsQz5DNwg69RU2L4GfwkN7tlUrhZ5E88CadfnBnHc=;
        b=jfNVgcz2gG2O+lGIb+xKTDHaVgVOrqsab0FwMc17gm/EhfyDERjGEdbig332m4oF3I
         1W/UuTw5O35R76AQjTFvhW3X0kx9lqyt8FXRhh3/P/NMDixf/4tZbDODghTk85iFoAi/
         nxxQCHE9025+sgRph+hYYlEcuVX7MNso+3A5t/eCuli1ouNHmS4B3dEto3j6Kkrebpuj
         k3YKSbkXFN8ywTwQgacFStO1ZoFXWRcRfwmLtwKc/p3vs+4SChgjCsycaH8gKmSFpn3o
         L3kocffc3V0ZzXv7F5DN3rn37+eUOkxIOmv5gx4fcWa7heStLjdWq7w5/mNAynbGXoi8
         vyig==
X-Gm-Message-State: APjAAAVtK0bMRHiPpBzJfzSTfUXs8naLBa9ih0ISQ2rLhGEGUikI3zZH
	/vih3gT8BAxm2c66kvv3dwtSN0FM4o0CIMrEOj4wC6tl2fgPOKpxkSEaKi+SeZhKp/ZLXAQ8n20
	f0kPIcw9wn4xDeJqo+lPzSklrfZzRFbTCP0KvAH/QlUsxabtGv8bnuHed12LWSquIxg==
X-Received: by 2002:a65:64ca:: with SMTP id t10mr116599pgv.177.1557347451619;
        Wed, 08 May 2019 13:30:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/M5hlEMmoIvC/ZukVoaxHB/309TbYrQwJWt4KphC5jnzynrDK36gEgzRkt+AKeZLMHtp1
X-Received: by 2002:a65:64ca:: with SMTP id t10mr116495pgv.177.1557347450754;
        Wed, 08 May 2019 13:30:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557347450; cv=none;
        d=google.com; s=arc-20160816;
        b=AO8piGDdfe9tKKZYXaUExOIDuTSTN6ic6+mQFymw52pkLPqpJTzKV/EhLnElLEZla8
         piINcsIEUcjLC6BSWY4YZ9YT8Vz3wL0CrHbxgxerOK4OCUgwDtX5p4u5DBk8mDbSy9hy
         ujKLiithSdG9I7lec9lkhE+pXeT6jS7U0lIhc6/dvAVKxsW8ZwY+rF/X5iEbaxQKbxNs
         dCMFI4yK2nvTCBvB/0YeiAtFLVcxgyXpcUcqKo3Zd3i/7OBQcSEjRbGzMSDHbO9SdTV7
         UHCTQfyLdWIjxnqt/M2nYRCzzm7L+o5vp0tK2Fo6/shSDnYINz9lys8qGmxm5mFYrWoG
         MiPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=bkxsQz5DNwg69RU2L4GfwkN7tlUrhZ5E88CadfnBnHc=;
        b=vDbFqVY8a//vKLhLnZZGPy1kFx+A6GyutGNhei11TpIm8aPC4y2AiJUZPwUsGP+3WZ
         N3W+TlJj23OOMeaMp7+oGu/jCH89/tM7qznVn+Z9tMymBzeJ3GnOiipPQrAOLkP31lTS
         3+qtU3jRe1HUnjM7mGJALt2qhQlu26GJDdnT5elEhWATkgzaqGv5QMPdZhvIk0dI075N
         tJV3pmD6b39sfDYixg3/AInIz3O7dQfDCZfYptNIya/sLYPJn+6/5KJnfY7noNgmjlBo
         mYsH+hKiemYW8v2gFwB/VbOyokgQidtkmz9p8CfIupZzC7oU45CF5AR9fH6fRhyKczS1
         sILQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fKRD9CRa;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s9si25238521pgr.443.2019.05.08.13.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:30:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fKRD9CRa;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x48KDpFG016008
	for <linux-mm@kvack.org>; Wed, 8 May 2019 13:30:50 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=bkxsQz5DNwg69RU2L4GfwkN7tlUrhZ5E88CadfnBnHc=;
 b=fKRD9CRaRv3U5XdtjU5cjRWlqr4Ir9ZCAeVnkKoHXkpFAOTVnpR0nuVTa5NHvrxIKLfK
 5N1c9tJcM1w0M2zwlAyMlHtUAV9eF2rf/H8hNGUIs5VWjmpsjlI7W+MxilBa+tgB2u9K
 G6JsghcepEUbBAMv16Kno//1Ozao/7gEg1s= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sc2prgv23-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 13:30:50 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 8 May 2019 13:30:48 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 020C511CDBCF0; Wed,  8 May 2019 13:24:59 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>,
        Shakeel Butt
	<shakeelb@google.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        Christoph Lameter
	<cl@linux.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>, <cgroups@vger.kernel.org>,
        Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v3 0/7] mm: reparent slab memory on cgroup removal
Date: Wed, 8 May 2019 13:24:51 -0700
Message-ID: <20190508202458.550808-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
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
linearly and doesn't show any signs of plateauing. The difference in slab
and percpu usage between patched and unpatched versions also grows linearly.
In 6 days it reached 200Mb.

day           0    1    2    3    4    5    6
original     39  338  580  827 1098 1349 1574
patched      23   44   45   47   50   46   55
mem diff(Mb) 53   73   99  137  148  182  209


# History

v3:
  1) reworked memcg kmem_cache search on allocation path
  2) fixed /proc/kpagecgroup interface

v2:
  1) switched to percpu kmem_cache refcounter
  2) a reference to kmem_cache is held during the allocation
  3) slabs stats are fixed for !MEMCG case (and the refactoring
     is separated into a standalone patch)
  4) kmem_cache reparenting is performed from deactivatation context

v1:
  https://lkml.org/lkml/2019/4/17/1095


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


Roman Gushchin (7):
  mm: postpone kmem_cache memcg pointer initialization to
    memcg_link_cache()
  mm: generalize postponed non-root kmem_cache deactivation
  mm: introduce __memcg_kmem_uncharge_memcg()
  mm: unify SLAB and SLUB page accounting
  mm: rework non-root kmem_cache lifecycle management
  mm: reparent slab memory on cgroup removal
  mm: fix /proc/kpagecgroup interface for slab pages

 include/linux/memcontrol.h |  10 +++
 include/linux/slab.h       |  13 ++--
 mm/memcontrol.c            |  97 ++++++++++++++++--------
 mm/slab.c                  |  25 ++----
 mm/slab.h                  | 120 +++++++++++++++++++++--------
 mm/slab_common.c           | 151 ++++++++++++++++++++-----------------
 mm/slub.c                  |  36 ++-------
 7 files changed, 267 insertions(+), 185 deletions(-)

-- 
2.20.1

