Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DE03C742D2
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 23:34:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4634E214AE
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 23:34:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="T2Wy+WQi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4634E214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB65F6B0006; Sun, 14 Jul 2019 19:34:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D67D76B0007; Sun, 14 Jul 2019 19:34:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7F216B0008; Sun, 14 Jul 2019 19:34:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93E9D6B0006
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 19:34:12 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so7544036pla.18
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 16:34:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ZvDmUghJGtIcoH1lAHyVM001UDDabPCfyEnhJcDGzTM=;
        b=jS1GEFKXhDRRZmPZEGHjuCBqmUNCDBGVrFwPqofFirMZ2dFHYig3cJcEr/sHdK7wpZ
         EOW2T77PIQXfnO6w9gUql7vRDTnrwU5g50EkbdyGE8RxPExn6gKd8ga2cPtA2lGYd3pT
         cTTd1LhjAKbj+ZPNd8vTqJ64y1RGtNASWIrREMsWhnUh32ooGDfr9wGPhGMDi3zZwkYJ
         lO44Y0NQ6PB4byCy2Gk/T53Qvc6+IX7TRNXLsLuFgw5cUDwWsu3zh7ZKMu5QszshzH4U
         N6ebDb6Jik2+IIg06AWo5c96lER9p0Ry6iXrbf/fmaHL3mC1Ol72ahvinE+B2cmKrq7F
         ZrKw==
X-Gm-Message-State: APjAAAX4r+naZwDBmPaStY5GlaKcTDc9gqB6lj1Nf0kzvwMGXvYpfEzb
	Ew9PPcL3oKIeF8t1KTyKgNP64GbKdDlGq/eCt255fImYl8t5xLNsiX0n8DbdVt/mVTzqepSbwRQ
	RpqKGlZrHSja5Wuhj8ji/RE8cXTs5r8IbocRPi4N7Q538QHghiqQGwFR0o2NqKQg=
X-Received: by 2002:a65:48c3:: with SMTP id o3mr24333155pgs.70.1563147252044;
        Sun, 14 Jul 2019 16:34:12 -0700 (PDT)
X-Received: by 2002:a65:48c3:: with SMTP id o3mr24333100pgs.70.1563147251082;
        Sun, 14 Jul 2019 16:34:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563147251; cv=none;
        d=google.com; s=arc-20160816;
        b=SsYiO/nPNzFzfzdHC2z0jF3/5HC5BxRGeIn1X7g+lE9LgOO8SgPAUM6se1EX2t3cqF
         xwYzP9qow8FICU0K/PuGdKQI2fMy3Q+euwC9tNYTZXm+hvWSFuWv8orG7hYCNieH3scu
         92cRVU81v2RwZ/rQnOpMwZgr/TXX9OwqXHiofLFj15mxSrDo25gXcoGEFUokRZxFmA7N
         srAdalEDJuqQ1nkcwJ9PKYr+hWNRdVUN1ByzVBskKNvTtA5s6yjXCVYA0f9jOwop6OvR
         eaaPj7A56dc6PfebRppHy6P1laq/ysYAAavIbTd1+DYnRrttLCSmA2HSL/x9GGUGZwq/
         Oanw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:dkim-signature;
        bh=ZvDmUghJGtIcoH1lAHyVM001UDDabPCfyEnhJcDGzTM=;
        b=PBcotmJjnfRgCeGTKSjQjQU/5lMOMUgAcW/xBJyPaK5X6m+n+xa4+5zCsb87+HXXDV
         B23jmaHk8iKfoFZmOwtb5Z8tNsrCdhzJVjAwkgEZVn+i1wGtz+jR9pvw5NB1NfWU00Th
         pBLdPwqPkgM4o6NNA8Zy0HIIj4s6uv2r+SdL/r47YrkDZQv79UA0dCq1qaxIlstfZH4m
         GAoHYI7g1q6BBYgrkDTu+kGSO0Rbt8KVB7NdzdNCckz/uNfYF9Z+kYEvZ/CE8zrx2zAb
         zilRcVHV9y0OS0S26p6MN7FnWcp/pvVX/fIdp6WzAvda82LtENxXvAan03WppdlWmq1o
         IgCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=T2Wy+WQi;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1sor8323377pff.23.2019.07.14.16.34.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Jul 2019 16:34:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=T2Wy+WQi;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ZvDmUghJGtIcoH1lAHyVM001UDDabPCfyEnhJcDGzTM=;
        b=T2Wy+WQirnIETDVwa5I7Np0AMEW+cV8L1e7Ij5LicL7Qhvsdij85agQZ5e4+gSLhlO
         u8U4gowMTiXquKCqEqj9IwSdDaJNFdyMb9ZKNYq5ETKBBtsqBgSsStyMcxexqtpJBUus
         Z/RHkYpBbpD64NZ2jwEzpHc2FsMwqEi8/V6rRg5ntZj5t1WGPL4bD/KNs0ylQYGrgK0D
         kLgTrpOJ79uGEbJWnJkh8o6T/2OEkANymRkPHA877tCKQB6Qz8mJSYl4DTGIILZE3y51
         w+uW8OrZ5hy2Oufr301FAVaWrOxaVNsG0syPeH5oIGyHn909rrLANBhIsP2ejgqdcqyU
         sqkA==
X-Google-Smtp-Source: APXvYqxPNd56Ruj4+d9gaHMgq8nm67VzpKr7zPEFJR/Ph1orc5zxtioAdeFX1yd3HNSoyZ8td1Fc3Q==
X-Received: by 2002:a63:3f48:: with SMTP id m69mr23329517pga.17.1563147250578;
        Sun, 14 Jul 2019 16:34:10 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id n26sm16256923pfa.83.2019.07.14.16.34.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 14 Jul 2019 16:34:09 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com,
	hdanton@sina.com,
	lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v5 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Date: Mon, 15 Jul 2019 08:33:55 +0900
Message-Id: <20190714233401.36909-1-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.510.g264f2c817a-goog
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is part of previous series:
https://lore.kernel.org/lkml/20190531064313.193437-1-minchan@kernel.org/
Originally, it was created for external madvise hinting feature.

https://lkml.org/lkml/2019/5/31/463
Michal wanted to separte the discussion from external hinting interface
so this patchset includes only first part of my entire patchset

  - introduce MADV_COLD and MADV_PAGEOUT hint to madvise.

However, I keep entire description for others for easier understanding
why this kinds of hint was born.

Thanks.

This patchset is against on next-20190712.

Below is description of previous entire patchset.

================= &< =====================

- Background

The Android terminology used for forking a new process and starting an app
from scratch is a cold start, while resuming an existing app is a hot start.
While we continually try to improve the performance of cold starts, hot
starts will always be significantly less power hungry as well as faster so
we are trying to make hot start more likely than cold start.

To increase hot start, Android userspace manages the order that apps should
be killed in a process called ActivityManagerService. ActivityManagerService
tracks every Android app or service that the user could be interacting with
at any time and translates that into a ranked list for lmkd(low memory
killer daemon). They are likely to be killed by lmkd if the system has to
reclaim memory. In that sense they are similar to entries in any other cache.
Those apps are kept alive for opportunistic performance improvements but
those performance improvements will vary based on the memory requirements of
individual workloads.

- Problem

Naturally, cached apps were dominant consumers of memory on the system.
However, they were not significant consumers of swap even though they are
good candidate for swap. Under investigation, swapping out only begins
once the low zone watermark is hit and kswapd wakes up, but the overall
allocation rate in the system might trip lmkd thresholds and cause a cached
process to be killed(we measured performance swapping out vs. zapping the
memory by killing a process. Unsurprisingly, zapping is 10x times faster
even though we use zram which is much faster than real storage) so kill
from lmkd will often satisfy the high zone watermark, resulting in very
few pages actually being moved to swap.

- Approach

The approach we chose was to use a new interface to allow userspace to
proactively reclaim entire processes by leveraging platform information.
This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
that are known to be cold from userspace and to avoid races with lmkd
by reclaiming apps as soon as they entered the cached state. Additionally,
it could provide many chances for platform to use much information to
optimize memory efficiency.

To achieve the goal, the patchset introduce two new options for madvise.
One is MADV_COLD which will deactivate activated pages and the other is
MADV_PAGEOUT which will reclaim private pages instantly. These new options
complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
gain some free memory space. MADV_PAGEOUT is similar to MADV_DONTNEED in a way
that it hints the kernel that memory region is not currently needed and
should be reclaimed immediately; MADV_COLD is similar to MADV_FREE in a way
that it hints the kernel that memory region is not currently needed and
should be reclaimed when memory pressure rises.

* v4 - http://lore.kernel.org/lkml/20190711012528.176050-1-minchan@kernel.org/
* v3 - http://lore.kernel.org/lkml/20190627115405.255259-1-minchan@kernel.org
* v2 - http://lore.kernel.org/lkml/20190610111252.239156-1-minchan@kernel.org
* v1 - http://lore.kernel.org/lkml/20190603053655.127730-1-minchan@kernel.org

Minchan Kim (5):
  mm: introduce MADV_COLD
  mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
  mm: account nr_isolated_xxx in [isolate|putback]_lru_page
  mm: introduce MADV_PAGEOUT
  mm: factor out common parts between MADV_COLD and MADV_PAGEOUT

 include/linux/swap.h                   |   2 +
 include/uapi/asm-generic/mman-common.h |   2 +
 mm/compaction.c                        |   2 -
 mm/gup.c                               |   7 +-
 mm/internal.h                          |   2 +-
 mm/khugepaged.c                        |   3 -
 mm/madvise.c                           | 274 ++++++++++++++++++++++++-
 mm/memory-failure.c                    |   3 -
 mm/memory_hotplug.c                    |   4 -
 mm/mempolicy.c                         |   6 +-
 mm/migrate.c                           |  37 +---
 mm/oom_kill.c                          |   2 +-
 mm/swap.c                              |  42 ++++
 mm/vmscan.c                            |  83 +++++++-
 14 files changed, 404 insertions(+), 65 deletions(-)

-- 
2.22.0.510.g264f2c817a-goog

