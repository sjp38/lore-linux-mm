Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA424C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:07:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6371E20850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:07:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LP65T9uo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6371E20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 056116B000D; Fri, 12 Apr 2019 16:07:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1EBF6B0010; Fri, 12 Apr 2019 16:07:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE8056B026A; Fri, 12 Apr 2019 16:07:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC46B6B000D
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 16:07:29 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id j63so7764681ywb.15
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:07:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=cWy39L110bpl90KlTOYN36nnj0m9Og8hXJw1+zoZDKk=;
        b=DnkL81Sf/sAIGuxIfGw0ihNytlhjIvxut4QEAST/mfuFi+a20EK0b61yaAH9WxBhJv
         MUnW9yaQmBHlxxUUra2tmsLKRN1t8HVSK/jfC0TwNFdEQc6d5NjB/mwauBGt1RmG8jO4
         cvlzQifGOQL31t00vf/nyXzVo+U7eZAeaG/yZa62kZilW7CX91xKIAnqpYzXBP7kZ4G/
         CD7dx7DZEzw/2gErU1IziJv+9fX09DxU4z1nlMBFxYuHfR+k35ylJL1N28W6f/50Poey
         2wD8jRbVjPu56JWwcrRz5+wxrvM59XnfTQAY3AQQvhoWuzZI4sreZyNW1iClWwlruHQL
         iEgQ==
X-Gm-Message-State: APjAAAUtBWVI520Za9XG3L8HS/DkWnI1eGyQHmnNmSMpV/VmeFXzj6I1
	tg92Y8bcxdOzkNGk+fctmfF2+l9t5bBiqunQj+8j6ve5nh5eKAxoC/RzGu5CkELsCUaQg9PXU5l
	fUey2GlF4iUyzYkIGGY744zPsFavyFUXHI/rHraETC7CPAcOEaK4xEvno0Du5lcJLHw==
X-Received: by 2002:a25:2417:: with SMTP id k23mr3790411ybk.430.1555099649537;
        Fri, 12 Apr 2019 13:07:29 -0700 (PDT)
X-Received: by 2002:a25:2417:: with SMTP id k23mr3790365ybk.430.1555099648974;
        Fri, 12 Apr 2019 13:07:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555099648; cv=none;
        d=google.com; s=arc-20160816;
        b=CQinOLvee3w11/DmzVE3xV3cBVBK4a6EVXDariTvI8DmquBNjAo4sH+Z9kfFBkHVaW
         rSM2a0//QKB3Z3vG3es28dSxzWMFdAiix9T/a9rbQJcTk6qYFxH5GOjZVAL6UJqo0gmE
         ltWY9BJkNxmKE382rnzUjBRKjc2hHaKvH8KIzzI0P8+rAZJGgbJFdTUmUCYy4WuSPWbO
         UCcFXM7snXRNOInTqR+Z/wb2eqmzbNvUAVen/2FMR6yyEvb5aSj4Ea4dlrmibK6hWlzE
         2yV/vyRJYbg/X+q8EqUYKunH3GrJ7a1RBj6NbNgxvhnSfVZG8l1UnihvGslm+/rfJtkh
         iThg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cWy39L110bpl90KlTOYN36nnj0m9Og8hXJw1+zoZDKk=;
        b=q6gnE+JMSfeOAZVuFThyElnM0Z4P9CloA13sIwG8/TwbHwbBTLteiHHwQ878JX98bl
         MH4AJbftNS6r+1yysPqZsfgc318PdAkf+TZ2BjXXkw0p04tJPUjZeAJNq4bLX4mJNZOl
         g1TuqWh63sMpGZhTR+DOIYJQffc+FLDifSrzspnm3+8bT73GxOWokqA3b9a/zEYMRzXO
         Xb2i3ilZUAll6t0ezyOXYC4Vg4DZVl4Sid+bJ0kAO4MSzZ+KBrVCJzgOkvq6R+OisCP4
         oao/BelUD34Idp9gBdRtyDMIRsU9Ft6WuQ//NTuA8yaGqr1wRzBULsT56w+INMlr67Ss
         N5pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LP65T9uo;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2sor6355923ywf.51.2019.04.12.13.07.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 13:07:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LP65T9uo;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cWy39L110bpl90KlTOYN36nnj0m9Og8hXJw1+zoZDKk=;
        b=LP65T9uo0dVn2Y5omvF5mxvXGRfAgu6NngtzQkPAnlMx95MzRaoxUddWsZp48rD13D
         DVYmLNGVWFeqmVnvvMAV+nlf+frio4tA488tODN1HVqEvHfhTW5BOunil70RJ/PsIhYE
         AVgukhQXhJcaGfW/bxdzEpdpiwIo/iM6ZGTv3XE8Y3RuPKBM4A8WyrvK4tDNZUmeWYl9
         wLKIa898nv5rY6FJxM+Z2Bz1Tk8gGszZttNaJ7iQfD4v9jr1wIsYMwMZhHPbEWz/2gJT
         zl199wVxdgncig7ajSNj8hQEX/RicdcdKS2ywd0YJfPSMTtbNXfvLGLH43wX3vF0nHyC
         CWiA==
X-Google-Smtp-Source: APXvYqznZO7Qm/QhFUfHKm3tnghM46ifrr9A348bqIDJYnm/2sGPr6e7rkOfkOAFCHIVkOnCoZYMtWSNR8ycH5WBDbs=
X-Received: by 2002:a81:9ad0:: with SMTP id r199mr46915127ywg.310.1555099648342;
 Fri, 12 Apr 2019 13:07:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190412151507.2769-1-hannes@cmpxchg.org>
In-Reply-To: <20190412151507.2769-1-hannes@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 12 Apr 2019 13:07:17 -0700
Message-ID: <CALvZod4-7a1aCELqWb+6xJ=-cPtfntNipAG634PA6UEQcN3Lag@mail.gmail.com>
Subject: Re: [PATCH 0/4] mm: memcontrol: memory.stat cost & correctness
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team@fb.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 8:15 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> The cgroup memory.stat file holds recursive statistics for the entire
> subtree. The current implementation does this tree walk on-demand
> whenever the file is read. This is giving us problems in production.
>
> 1. The cost of aggregating the statistics on-demand is high. A lot of
> system service cgroups are mostly idle and their stats don't change
> between reads, yet we always have to check them. There are also always
> some lazily-dying cgroups sitting around that are pinned by a handful
> of remaining page cache; the same applies to them.
>
> In an application that periodically monitors memory.stat in our fleet,
> we have seen the aggregation consume up to 5% CPU time.
>
> 2. When cgroups die and disappear from the cgroup tree, so do their
> accumulated vm events. The result is that the event counters at
> higher-level cgroups can go backwards and confuse some of our
> automation, let alone people looking at the graphs over time.
>
> To address both issues, this patch series changes the stat
> implementation to spill counts upwards when the counters change.
>
> The upward spilling is batched using the existing per-cpu cache. In a
> sparse file stress test with 5 level cgroup nesting, the additional
> cost of the flushing was negligible (a little under 1% of CPU at 100%
> CPU utilization, compared to the 5% of reading memory.stat during
> regular operation).

For whole series:

Reviewed-by: Shakeel Butt <shakeelb@google.com>

>
>  include/linux/memcontrol.h |  96 +++++++-------
>  mm/memcontrol.c            | 290 +++++++++++++++++++++++++++----------------
>  mm/vmscan.c                |   4 +-
>  mm/workingset.c            |   7 +-
>  4 files changed, 234 insertions(+), 163 deletions(-)
>
>

