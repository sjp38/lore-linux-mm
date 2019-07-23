Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A4C5C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:25:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1041223A0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 06:25:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VXaKTLh2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1041223A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ECC96B0007; Tue, 23 Jul 2019 02:25:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 578578E0003; Tue, 23 Jul 2019 02:25:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F0308E0001; Tue, 23 Jul 2019 02:25:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05A906B0007
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:25:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r142so25467553pfc.2
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 23:25:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=zbJ+A75JQxQCTNxDS14guL0hcpKTmg8kD79hd7R+RAs=;
        b=t+Ly4wqt4Oq76ACV9UFoVPPVb7yu/EdlovmaPghQPMqFejpw0jPJHWo65UWQHh1auV
         rEGDLR0rVlMfqc/Ib44/ujt9Wv4lfz4XzisK8ptL6j5ernsI3Rltm3mVaIYczQqdSBJu
         eU9KLj2Xxiv+I0WhnSDz6I23Lw+dUN1zg3kE+cXZhobtWEsdG3lptrDwC08YDqR2da2g
         tEobCa3TjdwFu9BPUab468f8ORY92kQDdrR9YYOQoGdfdANrab/M5JH84PjMce41rbIa
         KtGF2tDnON8ysRriQ/vg4uFYyoB4a+cP+9c4vNqrdSf/sHmbT7CF106/KjXijy7ZPgrq
         g2+g==
X-Gm-Message-State: APjAAAWlXreCjgbAfJNvhK0GSfDGGTQwwiXevWb4vxZZGRJPcV2d5mi2
	4Ur2amjKEKeplQi2a/RqaRxX6aoC26rd6g/OWXjHC0tf0zJ86z1rPhloDTK5pFcz+YcOwWDJ6vv
	pIJUOj9hK8p8hkjBx2+BVLkOL2gl4zsSe5Cp5hW9ZeVi8arTN8sL4+c2XrKKRqzQ=
X-Received: by 2002:a63:7d49:: with SMTP id m9mr65643043pgn.161.1563863150434;
        Mon, 22 Jul 2019 23:25:50 -0700 (PDT)
X-Received: by 2002:a63:7d49:: with SMTP id m9mr65642994pgn.161.1563863149542;
        Mon, 22 Jul 2019 23:25:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563863149; cv=none;
        d=google.com; s=arc-20160816;
        b=b3o8yuqq36NBsdE05leBA8o2A2qWstwF2Ju9Hnnu+IyzTMgjBdsdXIRJBntztjzO/4
         FbpUYrZw9JMNESDCojiEcEIMp1BqiaHAtgkpBN1naEgIj5ODWkbsU+bPmW2IjypyCxzj
         jeiKvsclcY06xd0Z+rMRE9oJp/2JCX9wcdx8Q59QQx1+qjYQIOAKBxHnHJqzsrDFIzkn
         4oi0hKjAIQy62hvAYlEvzYrPyFvZT44h7kTWbaqffIQ6EHm0pGj/252Bo2QHfF6BTRHI
         LV5DFbPoE32l6IEe4lwTnhOXRtlIsORc+oSYl5haobCEXmxPKXgQ15tc57uFiomG4FEg
         h8yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:dkim-signature;
        bh=zbJ+A75JQxQCTNxDS14guL0hcpKTmg8kD79hd7R+RAs=;
        b=pTGaklIj1pUXjYcqRgl3Ao/b3J7flk5mKFdgO1do8clhedozHaCkBfEmINeEFCEihO
         QAN71HAE/BTeQuWGpYJcf+NkmUWz928NKORj0UCkAHOowlUpj7cp5aJ9rsaigISTA2bs
         udDFTq4uHEMSjhi3xe1W0/LCyBFmbpSA4K3IBUCA2lWMz1zaQvcT920E1T2cAQfdEzjj
         hfm3uALLSvjFj2fWsX8PWs8w51l+Cc182Q8hCGsqUtaAWx7qipesoacnM76nvBq5mz0c
         oaYFM+cH+WgPHL+zmKzcALOu08GARiO//+JcrcgLeemiN5VLol6oq3LQjQmIFxSvlGic
         SRJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VXaKTLh2;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t22sor22493590pgg.51.2019.07.22.23.25.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 23:25:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VXaKTLh2;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=zbJ+A75JQxQCTNxDS14guL0hcpKTmg8kD79hd7R+RAs=;
        b=VXaKTLh2Ty2LrXCelx1lwyKW8OoUEN/m3yWWCHsLxRG7z43lLwUBmtnS5qW8dXGXy+
         Su1gckxmF4bW33dT7/eHqSyoDiyUYIt2x0dZahvDO1IBPEGEGVZv4XPYbi45DCInN24Z
         vRtqPHpfPeQZVzkTUpz9IcWpsPkCrQqiabvE4Ht/ehGvV2Tr9e6OEBqmPzDqT1uchqlp
         BOq9aY7aTN1yYfuN9JoBD8sHrtXh/LKfyecVMNYBXWpQtYCefv6mT0r+hPAo6miXJKeZ
         RgRHdl1elYOJFuFZQwMLqBStRr+pvGJDFdpIpTwW8QitsquQSdnK2W07aHtxdxu2j1N8
         ktIg==
X-Google-Smtp-Source: APXvYqztpR2euBdATHntbmVMt8lNwOC2sf/vJyvbaGxMhj9uk0bgrZQ/wZaEfiw4f1tyhHg3Z4WT6Q==
X-Received: by 2002:a65:4507:: with SMTP id n7mr72152681pgq.86.1563863148998;
        Mon, 22 Jul 2019 23:25:48 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id s66sm44630376pfs.8.2019.07.22.23.25.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 23:25:47 -0700 (PDT)
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
Subject: [PATCH v6 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Date: Tue, 23 Jul 2019 15:25:34 +0900
Message-Id: <20190723062539.198697-1-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.657.g960e92d24f-goog
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

This patchset is against on mmotm-2019-07-18-16-08.

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

* v5 - http://lore.kernel.org/lkml/20190714233401.36909-1-minchan@kernel.org
* v4 - http://lore.kernel.org/lkml/20190711012528.176050-1-minchan@kernel.org
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
2.22.0.657.g960e92d24f-goog

