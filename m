Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FF2DC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60C02206A2
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:24:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="si46cByK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60C02206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E698C6B0005; Tue,  6 Aug 2019 04:24:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF3606B0008; Tue,  6 Aug 2019 04:24:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBC046B000A; Tue,  6 Aug 2019 04:24:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9396B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:24:07 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id h12so48475280otn.18
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:24:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4TafmbL0Q/NgLabIQNToGEAZ2JWkHWsiwx7ruxH9mdw=;
        b=bFnU+Zdmbt98Fhxe6ON5H4YWp6yViNqzStNQqgfd85R2/EVuaOqE6/y8L0TDPlUrNq
         9yLkSq3EFPT0Sa1PKLoe4q79GzR7O93uipNH5nAnqNLMRKFIy//6cKUCKmB2+fLl48kb
         7BhL52eIZu/ab3fLog+J8fQye8xVOjYha9msdYLLqgm0ixAQ4XQK8pZrRgyMeE3HnyDj
         O01Xc1LJSSAW3sjl1c3841LWO6/K6KrAA7dru2dDi6N8i1xOWbBpvHtbnTBLwBLhiKQA
         m+V+Ve5z/VwZ9VItn6MDxI1YHuAD+DNl0H9Y5kVf7gqGZBHPfMXaW2KxiP9pzodpQHgf
         pk5A==
X-Gm-Message-State: APjAAAWyKYPPcQYxywhG1MYbNeyIoW5BPUsd9d2CqsymfEKzE8QG8T+l
	aR4TawH/e2rhFyt4bWbfIrgJrzh4SNnVwH/49Zfwkvty3LupuQ0qqPE5QR52mWu2Ts2OI52WMu9
	AA/fzgmJBx4zC8+6VeltMGHN8bCAV4F0pq4nGtYjVXp8DRvPAAE6QtTTRzcX2etL9Lw==
X-Received: by 2002:a02:1c0a:: with SMTP id c10mr3003279jac.69.1565079847300;
        Tue, 06 Aug 2019 01:24:07 -0700 (PDT)
X-Received: by 2002:a02:1c0a:: with SMTP id c10mr3003230jac.69.1565079846502;
        Tue, 06 Aug 2019 01:24:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565079846; cv=none;
        d=google.com; s=arc-20160816;
        b=gmacyrUFDbITakCLMxaVTZQkl9J/U3lROIjTy1EfUL+OPn6uh+qWuyj4oINOQbI81g
         RhXRoBprnZ4SZ7Uo3msUw4iPcEHkuCLxX9XchwfEV2os7xxuhsY+zQ1njImuygPSiojg
         U+tWg3A0ZUq3u8iGXwljzp+/zTa4iRY0h6ydMAmxdEYFFT+oR5JH5ZvWKJb1F+J5Lw+e
         Uo9ehpPyURWsJRd6g72lHdxciT1zxuGgD0TSFPUIiSVnkgsuNFKKitgfaHp5stEAcqJ8
         jfUe2HCC3/qQrdMLZBQgWq+r5bEfaRva1XbTRg6tDSYTlGrbXShlFmt5zseKpsEq92Bq
         tTVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4TafmbL0Q/NgLabIQNToGEAZ2JWkHWsiwx7ruxH9mdw=;
        b=oTbY+gmWcSIhO1Vz+xliW8yNEL32SkDPq6qREMoSjjkKV6Qzi13J1A6a4t4/2+LD/u
         kSy9q7NcTRWWPsOPO2KMHmSD/AYhxYvGCko4+Emv/RGDtS+ba49Hdw5lCw5UYhRsjch9
         mwXUUuOOfckskgRMebnzSO+QGd0HnWr+X8Uo/aHZ7EIu7wlUjIkzBD+1cPJznuNIxZ6c
         EZ0RCyOBKDL/2ujzX9qr3ZfhxVRfLAeXV+q3uAukQs20lGNNiR385KuFa8opLRBI7bUW
         dL2OvY5D5brtXljmcC1pSiH6AR8Wb2jH/zXLsqOS9HuknR3PFaphNs4OOsHjrywGCznS
         V3qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=si46cByK;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c19sor58260648iod.22.2019.08.06.01.24.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 01:24:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=si46cByK;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4TafmbL0Q/NgLabIQNToGEAZ2JWkHWsiwx7ruxH9mdw=;
        b=si46cByKJ94AK2EJXpCvhtQF/qsZfxqvYK0vv5GVmibr0NWJ5CwPh50it6gj4NByo7
         NkrC+zhQdtieYpp/194VciKrN/8KikpkusuFLDMzrPblM+atEKtLZDbZjiOL8fRncj/g
         XPcPK6IHxY8yjx8J9EjJEupxhjcTD6MB+ibc+IIRESC/vRqOwd4yr9qshGWG0UjXXJJL
         2cMZ7+CWMT6pX7CUiDO+OCoKJDr/yoj0Xva6MfCam79XVAAOC8HLCfAzMRpS/dlq3rgg
         WftJizHf7KnnWBZ7j6S+wt/3IiTQLITCIh0HxaSM65G1kO/t+CpsPu7sqtlSRcS5657X
         Sd8g==
X-Google-Smtp-Source: APXvYqwsxkHAQDoTNQ09nbiwWJ34yXvkNqrvy9KjIO2snXp141h8+tvVR6uFkYagkZy/6FHrqKWeXCOed3fQM+I1tss=
X-Received: by 2002:a5e:8a46:: with SMTP id o6mr2277051iom.36.1565079845875;
 Tue, 06 Aug 2019 01:24:05 -0700 (PDT)
MIME-Version: 1.0
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com> <20190806073525.GC11812@dhcp22.suse.cz>
In-Reply-To: <20190806073525.GC11812@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 6 Aug 2019 16:23:29 +0800
Message-ID: <CALOAHbD6ick6gnSed-7kjoGYRqXpDE4uqBAnSng6nvoydcRTcQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Daniel Jordan <daniel.m.jordan@oracle.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Christoph Lameter <cl@linux.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 3:35 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 06-08-19 03:19:00, Yafang Shao wrote:
> > In the node reclaim, may_shrinkslab is 0 by default,
> > hence shrink_slab will never be performed in it.
> > While shrik_slab should be performed if the relcaimable slab is over
> > min slab limit.
> >
> > Add scan_control::no_pagecache so shrink_node can decide to reclaim page
> > cache, slab, or both as dictated by min_unmapped_pages and min_slab_pages.
> > shrink_node will do at least one of the two because otherwise node_reclaim
> > returns early.
> >
> > __node_reclaim can detect when enough slab has been reclaimed because
> > sc.reclaim_state.reclaimed_slab will tell us how many pages are
> > reclaimed in shrink slab.
> >
> > This issue is very easy to produce, first you continuously cat a random
> > non-exist file to produce more and more dentry, then you read big file
> > to produce page cache. And finally you will find that the denty will
> > never be shrunk in node reclaim (they can only be shrunk in kswapd until
> > the watermark is reached).
> >
> > Regarding vm.zone_reclaim_mode, we always set it to zero to disable node
> > reclaim. Someone may prefer to enable it if their different workloads work
> > on different nodes.
>
> Considering that this is a long term behavior of a rarely used node
> reclaim I would rather not touch it unless some _real_ workload suffers
> from this behavior. Or is there any reason to fix this even though there
> is no evidence of real workloads suffering from the current behavior?
> --

When we do performance tuning on some workloads(especially if this
workload is NUMA sensitive), sometimes we may enable it on our test
environment and then do some benchmark to  dicide whether or not
applying it on the production envrioment. Although the result is not
good enough as expected, it is really a performance tuning knob.

Thanks
Yafang

