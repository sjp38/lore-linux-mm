Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3200DC76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 02:34:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE231218B8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 02:34:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nlAqPvMg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE231218B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64D426B0003; Thu, 25 Jul 2019 22:34:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FCF36B0005; Thu, 25 Jul 2019 22:34:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EB9C8E0002; Thu, 25 Jul 2019 22:34:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 185736B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:34:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z14so24971512pgr.22
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 19:34:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=4G7DtW9gdm4AoaNq28OMZRUktGi6LZH7+wyJUNGLnhg=;
        b=cILdLeNFCjMz7Ac4hvsdkZVIS1BQhAGSjApSx+bMiLKudTqL1JwLZ/FTBgcUovIpGm
         CGNAvqEA00sQEs07ecTgTWwvgz1+1hu3zhKMlgyyhe/XV71WKjgxNKNOdvSHA3FZ70lD
         bpzGli35/vnvqNniutYn+IBaLpGscJy8qjhQwBRbHUIrdzFan4kujh0EjkP9yzGKhdAT
         6Q2XyAiomhrxVCO+lOqIRyMN0Q92KO4/Kcn4ZaJt6HcCu7Dx51qa/6rC6JUbWrLJlNjd
         fIAIcArbjg+ZZCp+CM17Mv5o7D7/YkijWe7+bzPqNlRczaez4o+d3hj6TD6ChJj5Le9C
         Sevw==
X-Gm-Message-State: APjAAAVUhx4irgOGv8u7dJCqLe5saOgAEf6HP1C28zDaY9AUgd9Xf/H6
	lFyK1OeUgMyJyUCiBtcJKX3SSNIxrSBXzChySGNwvoyHtnIY1RLzmcx1J48EQPlUm4H+CktHXuP
	Tp4nVPGQgTmiFPE9OZXcl42YWSMX7rJXXurVjd7t1UfgsdfSEHl3veDjJaLiFIds=
X-Received: by 2002:a17:902:3181:: with SMTP id x1mr91994906plb.135.1564108486568;
        Thu, 25 Jul 2019 19:34:46 -0700 (PDT)
X-Received: by 2002:a17:902:3181:: with SMTP id x1mr91994836plb.135.1564108485203;
        Thu, 25 Jul 2019 19:34:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564108485; cv=none;
        d=google.com; s=arc-20160816;
        b=IyjcTDjAagqCEau79IvrpMwD+GapPmPjdoa+Odqn6D/G0Ejk0AHsM7vutjYe6/aXhV
         KBvSOFOTIPLL3WBhYP0a6XNs38Mnc2/oBOu627aT+dNt4qSuy5iZ6C4+tQCaYpTb/uRg
         qrNmUHJPChtGxhVDpOcMZMqEmh6D+REvc422ocn/iuJwPppk8W3WpYVVZY/mdNuXZA9b
         nyf2wLPxJ14JxPD8kIfTYruQ/uAcOzanLHhZT7QcICEmDKigPJYJE9s6X3XVRdoQRls0
         M2+HBLZJbra95JXHVAdgz7XSqyc/mp+AXJUGINoGLq2D3rcexmKp60lSh7cmJPR9uVXC
         2C9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:dkim-signature;
        bh=4G7DtW9gdm4AoaNq28OMZRUktGi6LZH7+wyJUNGLnhg=;
        b=1DdI5m1dNT0ccHvJxChHin0JYPCsqD7tze53sx0ncvSLg402/Lu1EOSCZqpEx/6WvN
         6FdsRT7WYUgkKD3iQ7gjMOfU285tDIOVMHHArqM67OkREqBeqEdiJvIHdKOoJvxjPJdg
         q7859Gwr3nnRV8XKqR5hb0gp4GDVZBUdgUMaJj4aeagQS2Wdhjv1k5RZhHk08YRvhpIm
         cKrZ+0dvuoGdGWiNSEzTpWVFIM2GTWnfjIcjhK33q1GdXqOAKyKd+5X3VCU+bjmjiVCV
         bpavpRa0ZqpYARuxX+qXFHTHpfdhaYikaT6WLAv3x+q4h3j7JlR7aAVPrwAIgiPNs/NX
         Qv4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nlAqPvMg;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s24sor11477288pgm.81.2019.07.25.19.34.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 19:34:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nlAqPvMg;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=4G7DtW9gdm4AoaNq28OMZRUktGi6LZH7+wyJUNGLnhg=;
        b=nlAqPvMgNWCHpJ1bDHJ7MhKtm+m+3BAF3t0YZTixnpvQM4m0mm2G4GaaXGrxG1fhJo
         ikN/GrPfDA+yIE9YNjJsqHVw5n5OjjHjls/Ax8ch7Gjnfxtetfn01ccDlDpQor57qeb2
         fbxTrbv9o7vYDghmxcaFkWzOcGMzifUx+5UfaCF4bxpmp5uI3ICz0jete2wwG3VJp+z1
         mHC6YJb+hc9sE010xBOW25uhf1X+phenIZSkVE2nLYKUDMaHayOGXbBUNUO2GDo+1DQV
         0LiBwQ1ORa3kaZeQ50nQqjjTALu+j1pKb5Sy0r0u3EpIJ0n61uVvoPu1ELm9KqiZizFP
         icrw==
X-Google-Smtp-Source: APXvYqyNGxGCHwWEmHeAjFZ0BziOJEqidU+PkPd+8ebMpdP2PvbzoqRqXgEsxbwBOG8R6RMLr6yRjg==
X-Received: by 2002:a65:6552:: with SMTP id a18mr79948447pgw.208.1564108484371;
        Thu, 25 Jul 2019 19:34:44 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id l31sm88958450pgm.63.2019.07.25.19.34.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 19:34:43 -0700 (PDT)
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
Subject: [PATCH v7 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Date: Fri, 26 Jul 2019 11:34:30 +0900
Message-Id: <20190726023435.214162-1-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
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

This patchset is against on mmotm-mmotm-2019-07-24-21-39.

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

* v6 - http://lore.kernel.org/lkml/20190723062539.198697-1-minchan@kernel.org
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

 arch/alpha/include/uapi/asm/mman.h     |   3 +
 arch/mips/include/uapi/asm/mman.h      |   3 +
 arch/parisc/include/uapi/asm/mman.h    |   3 +
 arch/xtensa/include/uapi/asm/mman.h    |   3 +
 include/linux/swap.h                   |   2 +
 include/uapi/asm-generic/mman-common.h |   3 +
 mm/compaction.c                        |   2 -
 mm/gup.c                               |   7 +-
 mm/internal.h                          |   2 +-
 mm/khugepaged.c                        |   3 -
 mm/madvise.c                           | 274 ++++++++++++++++++++++++-
 mm/memory-failure.c                    |   3 -
 mm/memory_hotplug.c                    |   4 -
 mm/mempolicy.c                         |   3 -
 mm/migrate.c                           |  37 +---
 mm/oom_kill.c                          |   2 +-
 mm/swap.c                              |  42 ++++
 mm/vmscan.c                            |  83 +++++++-
 18 files changed, 416 insertions(+), 63 deletions(-)

-- 
2.22.0.709.g102302147b-goog

