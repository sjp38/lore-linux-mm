Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37159C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 11:54:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E54B220656
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 11:54:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ia1UX23b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E54B220656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 786C06B0003; Thu, 27 Jun 2019 07:54:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 737F68E0003; Thu, 27 Jun 2019 07:54:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FF1A8E0002; Thu, 27 Jun 2019 07:54:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25E206B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 07:54:17 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a20so1420350pfn.19
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 04:54:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=uBobCJvUi1gowBXqDw03EU0Ml7quxJ1JQosDRG7xm1o=;
        b=lsj52H9u8QzW3OKg34UBhUhxhiLqWc6DPGJducx1+oy5DNv7Ld4JDeTon4z8unfVcK
         a8/BEMvby83LdX8YUqWnyYlBYGShnCRUeS2Gc95ad+OD143JRdLK+o9fHqtYvuMvELZC
         SzjHDHvlBw5W6gY0sHZq7KwdtvoeNNTI843rMpv1g1j4z0jJWGjRENEKF2JxJDC9wGYw
         4VHo4w9nNpmiEAHzru3BG8sVkM4Lo63qd8ES8KYHzmMDX/eakkmuDtQGOpRPQlQtciZV
         R9pXwnUKwYC06a0JpEtHQalvyy4hrIE/8IW8Na8PlYunOxStbh3xbMbtl3k0oftbbV4Z
         kB7Q==
X-Gm-Message-State: APjAAAVEWPwnx9NusVPk8+Ogf76IX+tTf2/IuIlY8PYsDwPHHg8GIZrY
	E1NdY0TiisGiyt7kPZgeruwGyzRdGWwaPuJF6uhbr3Gc8u7nGok0Z5ewtbVZiJ7irMpa/yp6apG
	FsPzwzBWJCglkbowmhWw3YdHX3kdP4XgZnrK+CVHu45ctGWngFl1iQY88phPJnoI=
X-Received: by 2002:a17:90a:246f:: with SMTP id h102mr5552818pje.126.1561636456601;
        Thu, 27 Jun 2019 04:54:16 -0700 (PDT)
X-Received: by 2002:a17:90a:246f:: with SMTP id h102mr5552739pje.126.1561636455530;
        Thu, 27 Jun 2019 04:54:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561636455; cv=none;
        d=google.com; s=arc-20160816;
        b=bnDVozU1OXR6HF0Ghg+RGeLiFL2BnT1mFPYsDFNE/VjEvEI/+yyk1ba4h0ccuriT9B
         QB60GInE5frxCszBPBqLJydwI4JJKZqXlBbIhcmGkO3qN9gtcXfF6O4cbnTpaJdYPBIR
         38ZThwq098tZm/rUwFoIEWuceKAI01JL5kmAVE764N/2LVFqbDa9AWfOjKiLjxRdVgd6
         iYQWiun97wzRnvUKsB5LlLw2wJpsK3LdssFmVnwH07Xi4UFm6w90i3kyAD4RlJ4n27sV
         xVNNfr9e8ztIG4ail/77ejUtqGWFVqd/CyKduDr53tvZbH8tL1+o/kxDHJvlz9H4yDHz
         1dgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:dkim-signature;
        bh=uBobCJvUi1gowBXqDw03EU0Ml7quxJ1JQosDRG7xm1o=;
        b=A+tpfmhU4Ine4MxZWyzu86sx+uLJk8IBeO1etEOEuPVOZy/KyzgoS0c3MNqPpwlIMB
         96+djEN/mFcthSQn2gR/whZyVWL85bIUMn9XB5q9MpJQlHtHSu1tqNTPY3WE4BUjfOAK
         +6ojb2Vc1w6EgNP/PyCflyzoa0I48M0jSEhLPBIP6D0XDx+AstWk8SiI8JsC1mgXrvlL
         N/uXzLFxCum5n+uDTVC7jsOKpeDRSbVx6li2SRlXAfu2ODvvFzDpBuLBMCnn4lFq555D
         gjhrLgHhh9XIIOLOmbvwMDuwdx2pehg7f+CxkeApfobjZfWWUvgyIieya+s6oGN0mE1A
         I+xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ia1UX23b;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y131sor1015546pfb.27.2019.06.27.04.54.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 04:54:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ia1UX23b;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=uBobCJvUi1gowBXqDw03EU0Ml7quxJ1JQosDRG7xm1o=;
        b=Ia1UX23bxS0nM3Tx5wUheW7ibikUb3hh5/mcXpIwpGEKCl6/3rOs7+ZDR0nCL2mhdV
         dWuWamXIghUeQacGKDXTcrpb7h1srGz9hjVDUzswI4iMlshlLHx2ilxDORSgkBFibKzC
         WsxkUNukp0rZvv67oGG49chJtS96I8X4KVsJO3lASvIufo2BXIQPk/IKBTVABv66g9/b
         BMn7ujUhPRf1xx8TSDeiT7ze7KsqQEJdGwVZ+tEFaHF/+h5H3Ao6Eh2E4UQziZ/RcJpi
         OwncinVaDpjVuHit6CWNx8SCfGd0OeTPZzzbrSBEO8x5bxHcK8QOCLNLAcbmnlk5JKdN
         LOrA==
X-Google-Smtp-Source: APXvYqy4QMow2C4473WHef5Gt5kQIBXHZ0K2Uj+3vgkLBrPlaZ4/gN3yLt674ez0KnWu0GcQIXRbBA==
X-Received: by 2002:a65:6656:: with SMTP id z22mr3291953pgv.197.1561636454835;
        Thu, 27 Jun 2019 04:54:14 -0700 (PDT)
Received: from bbox-1.seo.corp.google.com ([2401:fa00:d:0:d988:f0f2:984f:445b])
        by smtp.gmail.com with ESMTPSA id x14sm3241419pfq.158.2019.06.27.04.54.09
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 04:54:13 -0700 (PDT)
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
Subject: [PATCH v3 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Date: Thu, 27 Jun 2019 20:54:00 +0900
Message-Id: <20190627115405.255259-1-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is part of previous series:
https://lore.kernel.org/lkml/20190531064313.193437-1-minchan@kernel.org/T/#u
Originally, it was created for external madvise hinting feature.

https://lkml.org/lkml/2019/5/31/463
Michal wanted to separte the discussion from external hinting interface
so this patchset includes only first part of my entire patchset

  - introduce MADV_COLD and MADV_PAGEOUT hint to madvise.

However, I keep entire description for others for easier understanding
why this kinds of hint was born.

Thanks.

This patchset is against on next-20190530.

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

Minchan Kim (5):
  mm: introduce MADV_COLD
  mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
  mm: account nr_isolated_xxx in [isolate|putback]_lru_page
  mm: introduce MADV_PAGEOUT
  mm: factor out pmd young/dirty bit handling and THP split

 include/linux/huge_mm.h                |   3 -
 include/linux/swap.h                   |   2 +
 include/uapi/asm-generic/mman-common.h |   2 +
 mm/compaction.c                        |   2 -
 mm/gup.c                               |   7 +-
 mm/huge_memory.c                       |  74 -----
 mm/internal.h                          |   2 +-
 mm/khugepaged.c                        |   3 -
 mm/madvise.c                           | 438 ++++++++++++++++++++++++-
 mm/memory-failure.c                    |   3 -
 mm/memory_hotplug.c                    |   4 -
 mm/mempolicy.c                         |   6 +-
 mm/migrate.c                           |  37 +--
 mm/oom_kill.c                          |   2 +-
 mm/swap.c                              |  42 +++
 mm/vmscan.c                            |  86 ++++-
 16 files changed, 566 insertions(+), 147 deletions(-)

-- 
2.22.0.410.gd8fdbe21b5-goog

