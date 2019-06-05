Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBE60C28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CA932070D
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:45:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="EpwO8+np"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CA932070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3E1E6B026A; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B26EB6B0269; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97AD16B026C; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 764946B0269
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:45:02 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id p123so21541384ywg.3
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=ll9mjXjyPSTWkjT0RH+ntySWmhqIHqoS/UCssxgxW+8=;
        b=a0U9pJarxjfQu/mfDsUxL5ftN4r4lRAWsYH2DisTKN3LGP1lquATkrKnlQs4X0/2W/
         LKF9t4Pm9fJaYx36mS/s0U7wRMh9TxHBIfHBqZoNFcLAThMPhIxITsDI2jCCADgpcoEf
         AIUTgXqDDjz/dJ0Rwfs2mLWyonfMBGZGtJpc6QSFxJlMqLAtT8SZ9bN8QUg8qemb+oaQ
         skplGG4PtpFVdyJMEjX8jJmBZVHHQt6eVSZ2+8cO+S9ltHhWPobU4DmhfynhZf/onxpt
         AfX/54pIqEYdUw06U/6cXXOeaEUJqwKla03LWmL4yRvSrUeRu7ACMT+a5cboyxWR8gh6
         v2YQ==
X-Gm-Message-State: APjAAAV/RzBf2me8sq4OzVGhWrwvEOpWk5mXuO0s6CRwJwkHetNVpZFl
	pBA1c8ZLfEWBO28Y38HwOkZm9YH8wjW/797AWp3WY54gpGf8793ufmWg51cIJdi37V52mZSJJHg
	zkdOuLzF3bONgfgwXjXtgSL4VJ+oX8c3nWk84bqS5+M0yJAKSLIy70MVVHfZcB0BjTQ==
X-Received: by 2002:a81:3cf:: with SMTP id 198mr10277440ywd.219.1559702702143;
        Tue, 04 Jun 2019 19:45:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqkTllZh0cDBgywhUjhOszze5WhH14WTKznMj6RDci7Nwcn+9e5NUFbSoFP40hx8VpzZXk
X-Received: by 2002:a81:3cf:: with SMTP id 198mr10277416ywd.219.1559702701223;
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702701; cv=none;
        d=google.com; s=arc-20160816;
        b=W3T/USUMT8TA7043MhqDBgwfstSeovInsU/4n6wPQ3uJL32svNTLJna2NMtl5Zj2Kz
         6imNJj91zkWyp4g/58XCV4iGAfNOjpqgxmi8lZsC4H3gc0fDsW5QQTtepuy7ZJ3HGX+F
         wD8uBFpBLfYzOczH/ckzwcSWADcbecuDAoxWsw8OqDcT0cbt7DPOI9w337yzilkRLzmP
         x2xIqZ0T3MNfhivnW8Qad08XCDykVmIKoSXnkoW6GqmHtFvmqATJGPdI2kkMJxQUpTh6
         c4kDwgT+RScY1/T147pRx40yQBMVHr18gINCzhf+0PKZy7Je7K4zjaiE7mapXicf4PRZ
         h+ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=ll9mjXjyPSTWkjT0RH+ntySWmhqIHqoS/UCssxgxW+8=;
        b=uuqSEXlC19M+qIIunCzIsC7d3NqK82YRZTBaqT0m04oDdvMKfbZY5qt6t0HIOSwfLL
         QhDP9WPe0Msczok853YW4UcPePjqMSDQr6l7jyM7/0sd3rq5Y8V0JzBMxCI3R8QxvZg/
         J0EA6jfltyHqN3JQPBMB0AWzlUI2p+EZ+hNkaBq0KQTOBKuc6MjSgLcV++bz6AW6hUQ4
         G6MRvrvj97NjVETvwCHw2QU60Whruc4lZSDpe+us+Etraf9GZPnRyX4cQhYCRyKAj7LD
         unsQAuJH+kOGznE4Oeu9nmWz6d835Ec8Xfpg9EVEJOuxowbnsrq335/YBkH80rqfWvHr
         lxXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=EpwO8+np;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k7si6019243ywb.77.2019.06.04.19.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:45:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=EpwO8+np;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x552i3Xr023200
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 19:45:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=ll9mjXjyPSTWkjT0RH+ntySWmhqIHqoS/UCssxgxW+8=;
 b=EpwO8+npvLWFpVz9ImQ3NdVfmajkNi3SDHwWx05JWXthxuj3zTXcLU7RLr47MFnKbtxt
 qQUchegkxA2K4yfE0993zxya7bjou25fNvGbeQvcx4m5oc0xvt6zsIL/+H1hsWhLI+g7
 PK7uRTPbAfiLYsyzkVRlzQebjdzs6fLAQlQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sx41n84vt-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:45:00 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 19:44:59 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 75D6E12C7FDC1; Tue,  4 Jun 2019 19:44:58 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Shakeel Butt
	<shakeelb@google.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Waiman Long
	<longman@redhat.com>, Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v6 00/10] mm: reparent slab memory on cgroup removal
Date: Tue, 4 Jun 2019 19:44:44 -0700
Message-ID: <20190605024454.1393507-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050015
X-FB-Internal: deliver
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
stabilizes in 60s range; however with the original version it grows almost
linearly and doesn't show any signs of plateauing. The difference in slab
and percpu usage between patched and unpatched versions also grows linearly.
In 7 days it exceeded 200Mb.

day           0    1    2    3    4    5    6    7
original     56  362  628  752 1070 1250 1490 1560
patched      23   46   51   55   60   57   67   69
mem diff(Mb) 22   74  123  152  164  182  214  241


# History

v6:
  1) split biggest patches into parts to make the review easier
  2) changed synchronization around the dying flag
  3) sysfs entry removal on deactivation is back
  4) got rid of redundant rcu wait on kmem_cache release
  5) fixed getting memcg pointer in mem_cgroup_from_kmem()
  5) fixed missed smp_rmb()
  6) removed redundant CONFIG_SLOB
  7) some renames and cosmetic fixes

v5:
  1) fixed a compilation warning around missing kmemcg_queue_cache_shutdown()
  2) s/rcu_read_lock()/rcu_read_unlock() in memcg_kmem_get_cache()

v4:
  1) removed excessive memcg != parent check in memcg_deactivate_kmem_caches()
  2) fixed rcu_read_lock() usage in memcg_charge_slab()
  3) fixed synchronization around dying flag in kmemcg_queue_cache_shutdown()
  4) refreshed test results data
  5) reworked PageTail() checks in memcg_from_slab_page()
  6) added some comments in multiple places

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


Roman Gushchin (10):
  mm: add missing smp read barrier on getting memcg kmem_cache pointer
  mm: postpone kmem_cache memcg pointer initialization to
    memcg_link_cache()
  mm: rename slab delayed deactivation functions and fields
  mm: generalize postponed non-root kmem_cache deactivation
  mm: introduce __memcg_kmem_uncharge_memcg()
  mm: unify SLAB and SLUB page accounting
  mm: synchronize access to kmem_cache dying flag using a spinlock
  mm: rework non-root kmem_cache lifecycle management
  mm: stop setting page->mem_cgroup pointer for slab pages
  mm: reparent slab memory on cgroup removal

 include/linux/memcontrol.h |  10 +++
 include/linux/slab.h       |  13 +--
 mm/list_lru.c              |  11 ++-
 mm/memcontrol.c            | 102 +++++++++++++++-------
 mm/slab.c                  |  25 ++----
 mm/slab.h                  | 140 +++++++++++++++++++++---------
 mm/slab_common.c           | 170 ++++++++++++++++++++++---------------
 mm/slub.c                  |  24 +-----
 8 files changed, 312 insertions(+), 183 deletions(-)

-- 
2.20.1

