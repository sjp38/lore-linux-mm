Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C40E7C41517
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 02:42:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70D302238C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 02:42:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bTVjRsdM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70D302238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EF366B0006; Thu, 25 Jul 2019 22:42:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A0016B0007; Thu, 25 Jul 2019 22:42:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED0028E0002; Thu, 25 Jul 2019 22:42:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6CF46B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:42:39 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 191so32208005pfy.20
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 19:42:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Sw8V9bDn7QTKMld9EYLdEeoC4y9pSS5VgcZuqisuwyo=;
        b=bxgNjP9JnHF36ksX6vSVgUwXhI5Kq6SvoTaIGgsZqYGI27il3t8XwiSys7BciUZPeq
         jF3mEa/9H02IX2Ch29xI1gOVd5iwjdKs4WOzLRy84hF+fXO5qo1+1ix4q3EaMZNGqCRu
         7VLwrkdBmJxqH502sWQ0MiY2vmTIdAhTyMrsv3rNsJfenLy+ly/reE3hAnAW7hSAar05
         87F8B3gil1ftS6PwjMl37T4tZHz86kfberbx8LzH16MufQDZuAeBEQeQUAlTTDQzLwK2
         qI+tvcD9dGmZAjX1hqKCvDQLq/y3EZ+BClmcj/Ut7zPBI01gel8wxlN9mv7X54JO2VM/
         QGXA==
X-Gm-Message-State: APjAAAV7WJl/Cnh1nzlAG5kgjLvDG4mx+O2h2QB4qNtj5nR9UG267wbl
	IaO2A0RpTffldQl0iChnm2vyS6mbSvZHsZGBXrOJFdMyHspur+u/tnpeQPw1h1578eZrrptVEMZ
	AYZ0fKjAevz+XkyqlJfkeJWlMxJFIvT21YmCS7TgmZnryK0PpbiQ3CpXx5s1fTIA=
X-Received: by 2002:a63:ed50:: with SMTP id m16mr32825840pgk.209.1564108959288;
        Thu, 25 Jul 2019 19:42:39 -0700 (PDT)
X-Received: by 2002:a63:ed50:: with SMTP id m16mr32825787pgk.209.1564108958176;
        Thu, 25 Jul 2019 19:42:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564108958; cv=none;
        d=google.com; s=arc-20160816;
        b=H319eO7FfozbTvQ92GWJb2FwTO9MgYR1RRQmBt8Czgs00CoesBRA67jJEJlsKMAN7H
         calkCGoBuG7cevO7cZUXe1kksSiwVpECg8jWz7XI0n1+AbZIeohF55DuhuwmgB/A5s+Q
         Xyhu+Oc1k2MP3lf8/z9XbJfcO/oUVOo7Ts5GPburhhxWIV3RDEO+y4JUF7Ok83amEHW5
         KSAj05LbnXdmLQ7GwzBxxuRpFjPQPsmYQRZRud2RImeYhF9NX4bbP0NRw6Ntgc4aCtN8
         AtqmfgxNjO8ASPtrNFf4CCUbpAfRlJB0LCgCg2ru6iH1+rp7Q7BlmH282EGDXjNyiTrm
         6a7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=Sw8V9bDn7QTKMld9EYLdEeoC4y9pSS5VgcZuqisuwyo=;
        b=tQtjV0d+WxvtemTxgoVej7DXXK4FaWfEYhbw6F7XQGxaihuXddvy75uKKXTQZHycYA
         dfg8tCClaCgOFa5LCYerZG8HxWbNOFTVrHsyIx2JB8B7eKfCOTVukYllHC0TZ4iGNc5N
         fH4Ev5XJx5VS6oXASP683H0uXHO/fcmyBvCRWNOvtgoMWqK5bpDMq+QuGUrfEgxe5n9W
         3kMWLA0tUCOopdB1ARhKWIbeToLwn5a8tF32TiGKvJN74Nk8xwNjhtRjyVG4HuHtSA4p
         19Efmb6ffpUlWr+hZXRUWFGbWRzajArDn1S7R5xgHReMuoExBg1jPrXcN6FRyiSx8tFD
         rKhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bTVjRsdM;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s14sor63170413pjb.11.2019.07.25.19.42.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 19:42:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bTVjRsdM;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=Sw8V9bDn7QTKMld9EYLdEeoC4y9pSS5VgcZuqisuwyo=;
        b=bTVjRsdMvx6I6p695BSxtsIrspfsdgKJAIPjsX2KdorpIuM2cpKeHRrzcV+z9YZy0/
         4lCEeSW6pC99wy9ByeHaZvvo1R6RXkH5DSdQY+HBDz1qJTDLV/C1jxXbrYU8dN15Bgqq
         wX/w/LHhkWAiZdYtFuxKWXnkULtBCnlDEwUnWEfh42gfoIQxwp7W/dZuw4fe+yiQOCQ5
         f+5PksssOh17UeARnHPOEYEPlzCPAO9KJLFqVYZPhLp77PpvMBy0d247PmB1Odlnbhj6
         Q7BFuYloZfpnnOD3BRABQA6P1AFUCCff9iOLmDCo8NXO7qFPfPjb+bKneMKrGIfaBC0W
         HSIg==
X-Google-Smtp-Source: APXvYqzZVWllWaYWh6ED7e60CUOsZLsTeByVz38ebxeCXI+kX7Glzvo1aB92EO2v3XVcEeYwmmRnLA==
X-Received: by 2002:a17:90a:ac14:: with SMTP id o20mr96850971pjq.114.1564108957648;
        Thu, 25 Jul 2019 19:42:37 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id q22sm46283450pgh.49.2019.07.25.19.42.32
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 19:42:36 -0700 (PDT)
Date: Fri, 26 Jul 2019 11:42:30 +0900
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v7 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190726024230.GA216222@google.com>
References: <20190726023435.214162-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190726023435.214162-1-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

It's the resend with fixing build errors kbuildbot reported.
Please take it this version to get more test coverage.

Thanks.

On Fri, Jul 26, 2019 at 11:34:30AM +0900, Minchan Kim wrote:
> This patch is part of previous series:
> https://lore.kernel.org/lkml/20190531064313.193437-1-minchan@kernel.org/
> Originally, it was created for external madvise hinting feature.
> 
> https://lkml.org/lkml/2019/5/31/463
> Michal wanted to separte the discussion from external hinting interface
> so this patchset includes only first part of my entire patchset
> 
>   - introduce MADV_COLD and MADV_PAGEOUT hint to madvise.
> 
> However, I keep entire description for others for easier understanding
> why this kinds of hint was born.
> 
> Thanks.
> 
> This patchset is against on mmotm-mmotm-2019-07-24-21-39.
> 
> Below is description of previous entire patchset.
> 
> ================= &< =====================
> 
> - Background
> 
> The Android terminology used for forking a new process and starting an app
> from scratch is a cold start, while resuming an existing app is a hot start.
> While we continually try to improve the performance of cold starts, hot
> starts will always be significantly less power hungry as well as faster so
> we are trying to make hot start more likely than cold start.
> 
> To increase hot start, Android userspace manages the order that apps should
> be killed in a process called ActivityManagerService. ActivityManagerService
> tracks every Android app or service that the user could be interacting with
> at any time and translates that into a ranked list for lmkd(low memory
> killer daemon). They are likely to be killed by lmkd if the system has to
> reclaim memory. In that sense they are similar to entries in any other cache.
> Those apps are kept alive for opportunistic performance improvements but
> those performance improvements will vary based on the memory requirements of
> individual workloads.
> 
> - Problem
> 
> Naturally, cached apps were dominant consumers of memory on the system.
> However, they were not significant consumers of swap even though they are
> good candidate for swap. Under investigation, swapping out only begins
> once the low zone watermark is hit and kswapd wakes up, but the overall
> allocation rate in the system might trip lmkd thresholds and cause a cached
> process to be killed(we measured performance swapping out vs. zapping the
> memory by killing a process. Unsurprisingly, zapping is 10x times faster
> even though we use zram which is much faster than real storage) so kill
> from lmkd will often satisfy the high zone watermark, resulting in very
> few pages actually being moved to swap.
> 
> - Approach
> 
> The approach we chose was to use a new interface to allow userspace to
> proactively reclaim entire processes by leveraging platform information.
> This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> that are known to be cold from userspace and to avoid races with lmkd
> by reclaiming apps as soon as they entered the cached state. Additionally,
> it could provide many chances for platform to use much information to
> optimize memory efficiency.
> 
> To achieve the goal, the patchset introduce two new options for madvise.
> One is MADV_COLD which will deactivate activated pages and the other is
> MADV_PAGEOUT which will reclaim private pages instantly. These new options
> complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
> gain some free memory space. MADV_PAGEOUT is similar to MADV_DONTNEED in a way
> that it hints the kernel that memory region is not currently needed and
> should be reclaimed immediately; MADV_COLD is similar to MADV_FREE in a way
> that it hints the kernel that memory region is not currently needed and
> should be reclaimed when memory pressure rises.
> 
> * v6 - http://lore.kernel.org/lkml/20190723062539.198697-1-minchan@kernel.org
> * v5 - http://lore.kernel.org/lkml/20190714233401.36909-1-minchan@kernel.org
> * v4 - http://lore.kernel.org/lkml/20190711012528.176050-1-minchan@kernel.org
> * v3 - http://lore.kernel.org/lkml/20190627115405.255259-1-minchan@kernel.org
> * v2 - http://lore.kernel.org/lkml/20190610111252.239156-1-minchan@kernel.org
> * v1 - http://lore.kernel.org/lkml/20190603053655.127730-1-minchan@kernel.org
> 
> Minchan Kim (5):
>   mm: introduce MADV_COLD
>   mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
>   mm: account nr_isolated_xxx in [isolate|putback]_lru_page
>   mm: introduce MADV_PAGEOUT
>   mm: factor out common parts between MADV_COLD and MADV_PAGEOUT
> 
>  arch/alpha/include/uapi/asm/mman.h     |   3 +
>  arch/mips/include/uapi/asm/mman.h      |   3 +
>  arch/parisc/include/uapi/asm/mman.h    |   3 +
>  arch/xtensa/include/uapi/asm/mman.h    |   3 +
>  include/linux/swap.h                   |   2 +
>  include/uapi/asm-generic/mman-common.h |   3 +
>  mm/compaction.c                        |   2 -
>  mm/gup.c                               |   7 +-
>  mm/internal.h                          |   2 +-
>  mm/khugepaged.c                        |   3 -
>  mm/madvise.c                           | 274 ++++++++++++++++++++++++-
>  mm/memory-failure.c                    |   3 -
>  mm/memory_hotplug.c                    |   4 -
>  mm/mempolicy.c                         |   3 -
>  mm/migrate.c                           |  37 +---
>  mm/oom_kill.c                          |   2 +-
>  mm/swap.c                              |  42 ++++
>  mm/vmscan.c                            |  83 +++++++-
>  18 files changed, 416 insertions(+), 63 deletions(-)
> 
> -- 
> 2.22.0.709.g102302147b-goog
> 

