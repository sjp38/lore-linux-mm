Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CB4BC74A36
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 01:25:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E79AF214AF
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 01:25:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AnhTAJMz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E79AF214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 870828E00A1; Wed, 10 Jul 2019 21:25:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 821678E0032; Wed, 10 Jul 2019 21:25:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 738078E00A1; Wed, 10 Jul 2019 21:25:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C48E8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 21:25:41 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 71so2278168pld.1
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 18:25:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=DTuMNMfkZBV3p2/r2diQjoAt92HjKen6nNck8jRv0YQ=;
        b=RlKq/wLs58MceT6yeGP0/b6NOBfnEufT1fnv2rQ3rJWk6v742cVeInmLNwC39MjbMD
         fFLNPt5s0rKnE/eX7WBic2kp3myetI8GTmz59un1CbmoE+5ifk5lHQuOyH/PviIU+nsm
         1yi37VP/K8JObHhZs8EYtrVEyNFjUGvX77m/lQtebfT/NuJqaARpeyqSnOi7PUw9VNgj
         2XYFOgYFbir8HQTvGfCB0ecwWlmBO8EtFdbSCa4Vcpgi7X6gdmw5hoCGWxl2O30PeDxL
         0jcijA9pKEWm7nOT7OpUygyAY0UCjV9wEMo1MX1sN7oN5f4+jQpNL1HUEvtOZNFKZcC/
         KZjw==
X-Gm-Message-State: APjAAAXi3xBunHw4E+T8514RgFEaeVIwagl6x4yrjNfIhInI49RQGLC2
	ZTTKaNssvF7MT3P6nhNuJ5/x3AaUUNpRe1oFwJ2XuXgXSkTv7c4AUkF1DAEV4jSkvjHixzHTATd
	B8s5OTAtvLQpxeNo5dW5ZxbOeUkbczaBCsV5uQSG3rcgWpL328r/ubPa/1SymE0M=
X-Received: by 2002:a17:902:8509:: with SMTP id bj9mr1440890plb.79.1562808340734;
        Wed, 10 Jul 2019 18:25:40 -0700 (PDT)
X-Received: by 2002:a17:902:8509:: with SMTP id bj9mr1440832plb.79.1562808339908;
        Wed, 10 Jul 2019 18:25:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562808339; cv=none;
        d=google.com; s=arc-20160816;
        b=Oedn+X5A9FlitNG8nWrYMQGYiEz3bn6Apu8JIJrf7gBrxk3RH1SrHuz98i+yhDttxf
         vEMNbeDam0xMfcyMK2CMbTg04qLsaJLmigJzgcWDmpnY7ApU2XleEdu9gFOupXGnMgJF
         JL0YeW4/PTtesFINClya21186SXy7k1yYjxc73G6nWAhAY58B9ccNFNTwBpTA3mBvhbQ
         m9rWNmc6zsJNNk2WVEIPm2b17Z3n0VezqcpBsxkN/JTHeY/yZm/EbFBHqZNY9rTnDeO4
         viHD93dJNXaLb3I2q3C+AyeYwfmMpa+LMFEHYVqC2+ZiZngdHMy/UUMBeBDr57Bf/wZQ
         T0rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:dkim-signature;
        bh=DTuMNMfkZBV3p2/r2diQjoAt92HjKen6nNck8jRv0YQ=;
        b=CtNv+ZcXAPaF01eDd2Wrwg5qIVWmixnRr9MZC5Sx3HguhHdrDAZp/VGn9Hc6B9TXtc
         vqgXn9PeqQc7Bi6B1hNeZX78emd4+u4Z/VHwqv5WzsXDTp5WOW/nQjpMTnYctLD5kWuj
         Kk70G4w1Y2xd7osTcd7ERX85w030A24gbWBS7q4JYs8V8vV/cbXwJ78tQ9w5uVn7qTDH
         ChvYd5gH+ARXZu5yNVvY+LAFpeTIEFLKp/D6+4EUl0/nFVwz/i+iEURTBZZQ8ndumgfo
         PSWTFihPEoP9HBV3aoML7OG2JkxISS5oQ2nFigz5WG0dgnTjYws+5kosMCxK6gmDLQdM
         xGNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AnhTAJMz;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor4807413plr.31.2019.07.10.18.25.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 18:25:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AnhTAJMz;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=DTuMNMfkZBV3p2/r2diQjoAt92HjKen6nNck8jRv0YQ=;
        b=AnhTAJMz00MDcKhRGnJRRhsgMQ1lyGWxqfRtjPfIxXRExEQkihioQanNbkUGnOd1oG
         0W1RhNIF/ROIUqMGewQ8E7b1kEw1nE+NpTV4cqVpf4NnVlB+xhNrszTzSjKpOo2H5dRx
         koXVPtzFJkuHSWsjmWAMMLq5jmaZyD6sywelp7ZhDiEOf6Cp9Dmdd/KH34B79xwXLqfY
         uASHcTTtn2Ryw7xym3jV5w+adkKiLXFzwV7hs+YDW3Te5+QNfek1835F58hyaNXRS3vo
         ygPS/I8b6jNHq5DnWlocM5Z4jlAUoeGkaCTY6fFfNVg+ZTsoHV7ODKXmS7XOznrKVkIt
         VS9w==
X-Google-Smtp-Source: APXvYqy66rSlhIyzjplSY0vGytonT+Lmtlly+k6UJY895bJ6YUVQDcuphMGDrTz9NwnE9ZHy8NPy3Q==
X-Received: by 2002:a17:902:9a42:: with SMTP id x2mr1480602plv.106.1562808339390;
        Wed, 10 Jul 2019 18:25:39 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id b37sm10031974pjc.15.2019.07.10.18.25.34
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 18:25:38 -0700 (PDT)
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
Subject: [PATCH v4 0/4] Introduce MADV_COLD and MADV_PAGEOUT
Date: Thu, 11 Jul 2019 10:25:24 +0900
Message-Id: <20190711012528.176050-1-minchan@kernel.org>
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
https://lore.kernel.org/lkml/20190531064313.193437-1-minchan@kernel.org/
Originally, it was created for external madvise hinting feature.

https://lkml.org/lkml/2019/5/31/463
Michal wanted to separte the discussion from external hinting interface
so this patchset includes only first part of my entire patchset

  - introduce MADV_COLD and MADV_PAGEOUT hint to madvise.

However, I keep entire description for others for easier understanding
why this kinds of hint was born.

Thanks.

This patchset is against on next-20190710.

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

* v3 - http://lore.kernel.org/lkml/20190627115405.255259-1-minchan@kernel.org
* v2 - http://lore.kernel.org/lkml/20190610111252.239156-1-minchan@kernel.org
* v1 - http://lore.kernel.org/lkml/20190603053655.127730-1-minchan@kernel.org

Minchan Kim (4):
  mm: introduce MADV_COLD
  mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
  mm: account nr_isolated_xxx in [isolate|putback]_lru_page
  mm: introduce MADV_PAGEOUT

 include/linux/swap.h                   |   2 +
 include/uapi/asm-generic/mman-common.h |   2 +
 mm/compaction.c                        |   2 -
 mm/gup.c                               |   7 +-
 mm/internal.h                          |   2 +-
 mm/khugepaged.c                        |   3 -
 mm/madvise.c                           | 377 ++++++++++++++++++++++++-
 mm/memory-failure.c                    |   3 -
 mm/memory_hotplug.c                    |   4 -
 mm/mempolicy.c                         |   6 +-
 mm/migrate.c                           |  37 +--
 mm/oom_kill.c                          |   2 +-
 mm/swap.c                              |  42 +++
 mm/vmscan.c                            |  83 +++++-
 14 files changed, 507 insertions(+), 65 deletions(-)

-- 
2.22.0.410.gd8fdbe21b5-goog

