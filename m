Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8457C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 07:02:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A39E20C01
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 07:02:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vz4ljGDC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A39E20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F8FF6B0007; Tue, 20 Aug 2019 03:02:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 183A46B0008; Tue, 20 Aug 2019 03:02:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 024466B000A; Tue, 20 Aug 2019 03:02:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0229.hostedemail.com [216.40.44.229])
	by kanga.kvack.org (Postfix) with ESMTP id D1A846B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 03:02:50 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6B409181AC9AE
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:02:50 +0000 (UTC)
X-FDA: 75841913700.15.linen19_52f37fdeb8241
X-HE-Tag: linen19_52f37fdeb8241
X-Filterd-Recvd-Size: 5564
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:02:49 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id p12so7563465iog.5
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 00:02:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pLAKaINj6tTKQE7T3UElIj0dhAaNdogazL5oMORpg6M=;
        b=Vz4ljGDCnmRTf7TiGKbbVBWe9EvMl9QWd4IqSQfUWXLfzjF2BFqVLiBI2ZiGsG/4MJ
         Pqve1xoA336LZKOJTy6464+W88uxHdlYWdQZDlzg0mJ6bbDGw+ROEO8Sd/VhlhMeTiFo
         L7x7RlwQnvQIjcIe9ki6O21cz5SpfOJci3dDQ1+X0PjXQ+/L1r/HhEpv/nzCcwdo14mt
         dBVVn6+aHq6QzMUFSN0refd6O+frZkt5+Ppoljh5HTtTmDJhXvDjrkCRYkl7p4qarvIx
         0yh2SniSDtEcCN2lzgJSUWMy33E1fpvhuc4C1f2i5doipDCih/y3eqodiI6TYv7Z+4MI
         vRGQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=pLAKaINj6tTKQE7T3UElIj0dhAaNdogazL5oMORpg6M=;
        b=kDsHx/ZGOK5MyluvFGb6CHN90f3Ajq/I1XWbC+/WtDa4sbB/J4TIGevfmMAYFq7kRB
         x+zuJJQcOaHBzy3rNh78UTxyANKwymlKzfsOdZB3T3kLEagFBDKIC+602X1Vyv0uJAQO
         ZPeCfLLzltRx8B7uGpb0IgrwLFITjjqUmIoLAW0Z4LEDfFKjT4FM/Q8pojS8EbD951lQ
         LrCj9ldq6x1XY4OSMiIYa6b9S6Zx9lu+JipqAJCAxHy8zUZodsxltWHsmWM5468XJiRL
         V7inO0D8twQgWM0+kdXQv5/ir3WmRhEz7NwfF4ymEf7DNHMIND7tHyZtowBmqe+abzqx
         U6Gg==
X-Gm-Message-State: APjAAAXgRdRSC++uxhnV1+bcYdwJ/AhCPlWLL/FxuKOnBzDJVfB9t2mL
	TbsOpJ/lKjkUA9J0CaWIuuQGgdhfuup2VQfmkL8=
X-Google-Smtp-Source: APXvYqzSQzdkr6B2OjlSUz7mi3rtuhrV5Yz0PhBe0T2TqzX5Ltl8PeLFuDk2r25qViTCJOq4rwyGTNPi9g853jNR2Bg=
X-Received: by 2002:a02:4047:: with SMTP id n68mr2228411jaa.10.1566284569235;
 Tue, 20 Aug 2019 00:02:49 -0700 (PDT)
MIME-Version: 1.0
References: <1566102294-14803-1-git-send-email-laoar.shao@gmail.com>
 <20190819073128.GB3111@dhcp22.suse.cz> <CALOAHbAo2MLkavFZz_5f5hvXE8BzYW8R-yjw5acnwT315TxoMQ@mail.gmail.com>
 <20190820063120.GD3111@dhcp22.suse.cz>
In-Reply-To: <20190820063120.GD3111@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 20 Aug 2019 15:02:13 +0800
Message-ID: <CALOAHbCwqWeZ4JdXpOMm-y2UdZafrU6-efbuE4iiPEC8-7ncUg@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: skip killing processes under memcg protection
 at first scan
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Roman Gushchin <guro@fb.com>, Randy Dunlap <rdunlap@infradead.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 2:31 PM Michal Hocko <mhocko@suse.com> wrote:
>
> [hmm the email got stuck on my send queue - sending again]
>
> On Mon 19-08-19 16:15:08, Yafang Shao wrote:
> > On Mon, Aug 19, 2019 at 3:31 PM Michal Hocko <mhocko@suse.com> wrote:
> > >
> > > On Sun 18-08-19 00:24:54, Yafang Shao wrote:
> > > > In the current memory.min design, the system is going to do OOM instead
> > > > of reclaiming the reclaimable pages protected by memory.min if the
> > > > system is lack of free memory. While under this condition, the OOM
> > > > killer may kill the processes in the memcg protected by memory.min.
> > >
> > > Could you be more specific about the configuration that leads to this
> > > situation?
> >
> > When I did memory pressure test to verify memory.min I found that issue.
> > This issue can be produced as bellow,
> >     memcg setting,
> >         memory.max: 1G
> >         memory.min: 512M
> >         some processes are running is this memcg, with both serveral
> > hundreds MB  file mapping and serveral hundreds MB anon mapping.
> >     system setting,
> >          swap: off.
> >          some memory pressure test are running on the system.
> >
> > When the memory usage of this memcg is bellow the memory.min, the
> > global reclaimers stop reclaiming pages in this memcg, and when
> > there's no available memory, the OOM killer will be invoked.
> > Unfortunately the OOM killer can chose the process running in the
> > protected memcg.
>
> Well, the memcg protection was designed to prevent from regular
> memory reclaim.  It was not aimed at acting as a group wide oom
> protection. The global oom killer (but memcg as well) simply cares only
> about oom_score_adj when selecting a victim.
>

OOM is a kind of memory reclaim, isn't it ?

> Adding yet another oom protection is likely to complicate the oom
> selection logic and make it more surprising. E.g. why should workload
> fitting inside the min limit be so special? Do you have any real world
> example?
>

The problem here is we want to use it ini the real world, but the
issuses we found  prevent us from using it in the real world.


> > In order to produce it easy, you can incease the memroy.min and set
> > -1000 to the oom_socre_adj of the processes outside of the protected
> > memcg.
>
> This sounds like a very dubious configuration to me. There is no other
> option than chosing from the protected group.
>

This is only an easy example to produce it.

> > Is this setting proper ?
> >
> > Thanks
> > Yafang
>
> --
> Michal Hocko
> SUSE Labs

