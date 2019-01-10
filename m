Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7FE7C43612
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 19:20:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 849E02177B
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 19:20:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UYhj3bBg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 849E02177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA1FC8E0002; Thu, 10 Jan 2019 14:20:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C51C98E0001; Thu, 10 Jan 2019 14:20:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B19408E0002; Thu, 10 Jan 2019 14:20:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 815CD8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:20:12 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id w9so6046496ybe.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 11:20:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=B/RiC2GtO9byIkMsVaaUkbqYI1Ft50zQDgpxIfbE+0k=;
        b=AEo7IerFqZfvNx8AfZe0IkS1SaxLNT8ItBpiNm4kFH96xp4YZBXruiG4JLuXIam2wY
         8tz6MejYq5u8deI12PnqrzVGg5nTWyAH9N86wG4pVBiAkl0tRYEUVQxv422NsB+kebR2
         QDsBysQU1bvFU/vFEqD+A+SpGJb86knG06kgbcSG0ZuGoQSICEKdrWUgb5cmTz73v+Uj
         +T8wFo2FXbMJRMPR8uGRg4ZFazIlsYF1pdIeT1aOfJGdaELpFLfktvwsOIeLf+MRpT+D
         m6zS3mAoP4XPhjuRZvD9ffmAXL9BTOJ02XeYNftdkdWo0RdjKKxPqmFE7KUnigfTxIlN
         uF6A==
X-Gm-Message-State: AJcUukemK94yUvNeU5/ySvvg8wODDWhx3ZJzYMNmm3Zvb7U8zaHaMOVB
	lGboCtCzQxvdeKh04AmdFYmJinwbKOojpXiY5FGvN8IGYMelsGpF14mzvinXCb3q1XeLDQkpez7
	5cdcnc9jqyzdaKULuqmTVRJj0MhQJIi7EqL+e9cnh0CtXZAyVBHuX2TthBg2D1REdO2yHcxGv9g
	mJO18rouHZ3yTs+l8GRsUsj9CCkf4VykNE6K48gZS9eZKZxfX9Y/c+pyuGpn+bBlQltEh1DQOv/
	+TSZEl1gxr9gx5mBOUcr2UnFDcI9o/WzLMN7YHMWCibRZQIAGlCPQ8wcwGGCQgeOYfkY+/UlOyl
	dBxox+rszSguQ897Jp7GJgqO0PlbYCDVT5SBvWqi4y6UzOKxtPmql2nbsz80UfnG5vIZMQhCEyz
	B
X-Received: by 2002:a0d:ea8e:: with SMTP id t136mr11476199ywe.376.1547148011988;
        Thu, 10 Jan 2019 11:20:11 -0800 (PST)
X-Received: by 2002:a0d:ea8e:: with SMTP id t136mr11476131ywe.376.1547148010858;
        Thu, 10 Jan 2019 11:20:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547148010; cv=none;
        d=google.com; s=arc-20160816;
        b=JoYpfRkp4Csih0VuFRWeds1WBi6utLCZXlbMdslWyalhUtBBzvG86NN77kMKxjUVDt
         AysoB+CCoGRDwDvCQjkVZa1hI92q2X6a8Eni27vHSnzMHK3JLcGgMZ4YX+ITZscNPJD0
         NzNRV8J+0ELEgp4ZmJ/Pof37pF4R9wWtZt1GzSpe/RxjbBRKbMR00mXgWTQ73woCKLJZ
         KtYTqz5tZh32BL2l87hvzbwsbTy5Eooihy6APa54yngCoX7rNdxCWCpWBcw8AKk046lt
         EHjJTaGSew/Pp7ATOuZvWAPPEECaBX2xYucD89+0qF7CGpEnMW5/glHmwvmHffSsUq3Z
         WplQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=B/RiC2GtO9byIkMsVaaUkbqYI1Ft50zQDgpxIfbE+0k=;
        b=Q3vAhPiyDvx5bgTvkMAH61cCR6OSn9C0yw5LEx+HugGBZhkiFX1hR/A6WNDHOKcg4p
         JB2vRGvemkqEQclm0K4GuOkL1zub/+Z2CRxXX/QtDrX4LBWPX01e7M99i4kX/GtyL6Pi
         FojE71mdumlvgvtNw+o3Eyp2ljyK/01O29KxzLaPra7h1R2qsfdEWmzci5UOtAi7tEIi
         Fbpx0E6LMJXtMFgt6H+f8Y7QdGYcAwDxs8rQ5D44BrGyLqm/x6u2177Mo+EI4b8BK/R+
         +rgpLOCzP/bblq1c1wiQNBelId2/Sq/MXPLhJ6b4ctXny/RHZnKdvG9/BUZNwXL+99I7
         Pu2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UYhj3bBg;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f124sor9930376ywe.27.2019.01.10.11.20.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 11:20:10 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UYhj3bBg;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=B/RiC2GtO9byIkMsVaaUkbqYI1Ft50zQDgpxIfbE+0k=;
        b=UYhj3bBg4xOKRWFncUKG0IUL+OsRuRiGBFWxKr2FmdmReLaXYbPoGGxXvJI7Nd6m6+
         iFowsmlv67/XLIhtEd+nmUZ8PgfxplsSiA9lRuqbmth4nD/dwvaS++HJNmFd/m6udM6w
         1SFQK1ES7jEHEmS0d0AfcWAVtvi0kssrjcZOvIc0BvtGgfoHswx0ERE38VlxpfhVhhOK
         CljDPVOY4sThGdJRyaKqzZJG4rKCIbGG69a9KoTcGpJJveIVpGPRkfE1jdOKp+NSpD+l
         Tway70LpLM1hbRJYNs3mAH09DfUpYRJiF9UpH8Lk1X4lRBXV8+yhBI+jN5uYFBH50Qhz
         JFPw==
X-Google-Smtp-Source: ALg8bN7ggYVATESbolrfvITxljTH6xr5lhCa7qXwk/qZoJi1EJrrGQmndLhHVq7Nmwg15scow1ojxwkTQoLTucoiNX4=
X-Received: by 2002:a81:30d6:: with SMTP id w205mr11368287yww.27.1547148009842;
 Thu, 10 Jan 2019 11:20:09 -0800 (PST)
MIME-Version: 1.0
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
 <CALvZod63z5_m-izxFh4XQvjcALqffkZ5G91-KsyOuAC4wvN3Wg@mail.gmail.com> <a1dbe366-43bd-e3ee-6133-f6179b2f2278@virtuozzo.com>
In-Reply-To: <a1dbe366-43bd-e3ee-6133-f6179b2f2278@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 10 Jan 2019 11:19:58 -0800
Message-ID:
 <CALvZod62A+EpGF6UVGjBhuDfwPd2b7c0M9mR86jP-3GGGT1T6g@mail.gmail.com>
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Josef Bacik <josef@toxicpanda.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, 
	"Darrick J. Wong" <darrick.wong@oracle.com>, Michal Hocko <mhocko@suse.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Gushchin <guro@fb.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110191958.IVZoKzfAs_t-ZWc2SnHkeoOi1VBxLIzHgS-gRLbhZGU@z>

On Thu, Jan 10, 2019 at 1:46 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> Hi, Shakeel,
>
> On 09.01.2019 20:37, Shakeel Butt wrote:
> > Hi Kirill,
> >
> > On Wed, Jan 9, 2019 at 4:20 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> >>
> >> On nodes without memory overcommit, it's common a situation,
> >> when memcg exceeds its limit and pages from pagecache are
> >> shrinked on reclaim, while node has a lot of free memory.
> >> Further access to the pages requires real device IO, while
> >> IO causes time delays, worse powerusage, worse throughput
> >> for other users of the device, etc.
> >>
> >> Cleancache is not a good solution for this problem, since
> >> it implies copying of page on every cleancache_put_page()
> >> and cleancache_get_page(). Also, it requires introduction
> >> of internal per-cleancache_ops data structures to manage
> >> cached pages and their inodes relationships, which again
> >> introduces overhead.
> >>
> >> This patchset introduces another solution. It introduces
> >> a new scheme for evicting memcg pages:
> >>
> >>   1)__remove_mapping() uncharges unmapped page memcg
> >>     and leaves page in pagecache on memcg reclaim;
> >>
> >>   2)putback_lru_page() places page into root_mem_cgroup
> >>     list, since its memcg is NULL. Page may be evicted
> >>     on global reclaim (and this will be easily, as
> >>     page is not mapped, so shrinker will shrink it
> >>     with 100% probability of success);
> >>
> >>   3)pagecache_get_page() charges page into memcg of
> >>     a task, which takes it first.
> >>
> >
> > From what I understand from the proposal, on memcg reclaim, the file
> > pages are uncharged but kept in the memory and if they are accessed
> > again (either through mmap or syscall), they will be charged again but
> > to the requesting memcg. Also it is assumed that the global reclaim of
> > such uncharged file pages is very fast and deterministic. Is that
> > right?
>
> Yes, this was my assumption. But Michal, Josef and Johannes pointed a diving
> into reclaim in general is not fast. So, maybe we need some more creativity
> here to minimize the effect of this diving..
>

I kind of disagree that this patchset is breaking the API semantics as
the charged memory of a memcg will never go over max/limit_in_bytes.
However the concern I have is the performance isolation. The
performance of a pagecache heavy job with a private mount can be
impacted by other jobs running on the system. This might be fine for
some customers but not for Google. One use-case I can tell is the
auto-tuner which adjusts the limits of the jobs based on their
performance and history. So, to make the auto-tuning deterministic we
have to disable the proposed optimization for the jobs with
auto-tuning enabled. Beside that there are internal non-auto-tuned
customers who prefer deterministic performance.

Also I am a bit skeptical that the allocation from the pool of such
(clean unmapped uncharged) file pages can be made as efficient as
fastpath of page allocator. Even if these pages are stored in a
separate list instead of root's LRU, on allocation, the pages need to
be unlinked from their mapping and has to be cleared.

BTW does this optimization have any impact on workingset mechanism?

thanks,
Shakeel

