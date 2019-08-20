Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9584C3A5A0
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:41:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5828B214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:41:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c7GSH96n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5828B214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA5E06B0007; Mon, 19 Aug 2019 22:41:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2D776B0008; Mon, 19 Aug 2019 22:41:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF4886B000A; Mon, 19 Aug 2019 22:41:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0251.hostedemail.com [216.40.44.251])
	by kanga.kvack.org (Postfix) with ESMTP id A8DD66B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:41:15 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 52496180AD801
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:41:15 +0000 (UTC)
X-FDA: 75841254510.02.bells98_7f51ec8d49959
X-HE-Tag: bells98_7f51ec8d49959
X-Filterd-Recvd-Size: 8368
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:41:14 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id e20so8928138iob.9
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:41:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Yh37rDMnWKyeuTG7c4nQddOkL3MsXhv1UkwaUPn8dSA=;
        b=c7GSH96ncOkZtRhtrq30bzO1pTUOcWGjRJgv7gzQDN0YY4YI2RCy0v+erOhYPw/bpX
         Dzito/M7HI5hwFfQsmDGHzjDfqppK2LT6GQsQDbWL3gbbo/W22EUk4q09Iov9eby4H0E
         xPUKEDfmAnG9GfaZOXThF1DCBM8twT7sJrzafTPo4oRxupo9eOLXGCrf01DNrXX2aUbI
         lQJIaVOF6Y2d6+bqIdkMueWmcY4evp+qi8AwnIQOTMdkUvdKsyDHRtk0MdQtsdE4z3u8
         Y8Himw1huIu5c6zbnlhMV7ngB6ITFyeRSaj0YRRAWp4nbJ5ZBGDsyDsF3EEjrJf8aIXL
         oNtQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Yh37rDMnWKyeuTG7c4nQddOkL3MsXhv1UkwaUPn8dSA=;
        b=a6gd49uLenyEvXE+SU2ZrXgPSAw/PU1LfdHuMBUJQdhPt1SsmZrlse+iqV0XYt0HvD
         AhaBg6EN0wJxO4UyJ1UkF+eTtxzkb5qWwn6I7P5m/cP+sSPbK20WeFMNOiV8WY9ye/2H
         rbd7sZ64dIR5c2izOJA0mOMx2rBDBsM+Hf3p9ZGIkJHHBB8AYIfTHCadyrS1LgVcpws4
         V1GDt/d+4GaDeXoq4ExK0/KoShPW58W0todePLWJkNGfj65EEDU5VXo/KhwddIe0sQqe
         JODxd+oWv1HLRe6Efm21AsGb5hCYdyanTMAdLkg+Yg+6tsAg1TA357weLwchpWB/M5RM
         Tjlg==
X-Gm-Message-State: APjAAAXlnNWVU6Cn8Ddwz86Ey4zaavOKK0kz96xVLf4DBZ3JlJNJiDYp
	yHzwBa2Rfk6Bt50qBVv2x1Uo+a6H3MfrlkaAIcY=
X-Google-Smtp-Source: APXvYqzu33LRv4vE57fkerZX02BDxUfxZK+xLZ7KjaSIsq9HfPs5DAQbH/Y3tH0bKHFv77+s09HvywhpxQfK4u181x4=
X-Received: by 2002:a5e:8a46:: with SMTP id o6mr16174206iom.36.1566268874177;
 Mon, 19 Aug 2019 19:41:14 -0700 (PDT)
MIME-Version: 1.0
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190819211200.GA24956@tower.dhcp.thefacebook.com> <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
 <20190820013951.GA12897@tower.DHCP.thefacebook.com> <CALOAHbDu7SkE4L36cZaaC8httd+UHyWzSjHqOmSa8S67p-kqEA@mail.gmail.com>
In-Reply-To: <CALOAHbDu7SkE4L36cZaaC8httd+UHyWzSjHqOmSa8S67p-kqEA@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 20 Aug 2019 10:40:38 +0800
Message-ID: <CALOAHbD2-x8PbNSWcWyEf6dSOozRTEAEd7hSmHYNMNwKRtAXXA@mail.gmail.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
To: Roman Gushchin <guro@fb.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	Randy Dunlap <rdunlap@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 10:01 AM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> On Tue, Aug 20, 2019 at 9:40 AM Roman Gushchin <guro@fb.com> wrote:
> >
> > On Tue, Aug 20, 2019 at 09:16:01AM +0800, Yafang Shao wrote:
> > > On Tue, Aug 20, 2019 at 5:12 AM Roman Gushchin <guro@fb.com> wrote:
> > > >
> > > > On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> > > > > In the current memory.min design, the system is going to do OOM instead
> > > > > of reclaiming the reclaimable pages protected by memory.min if the
> > > > > system is lack of free memory. While under this condition, the OOM
> > > > > killer may kill the processes in the memcg protected by memory.min.
> > > > > This behavior is very weird.
> > > > > In order to make it more reasonable, I make some changes in the OOM
> > > > > killer. In this patch, the OOM killer will do two-round scan. It will
> > > > > skip the processes under memcg protection at the first scan, and if it
> > > > > can't kill any processes it will rescan all the processes.
> > > > >
> > > > > Regarding the overhead this change may takes, I don't think it will be a
> > > > > problem because this only happens under system  memory pressure and
> > > > > the OOM killer can't find any proper victims which are not under memcg
> > > > > protection.
> > > >
> > > > Hi Yafang!
> > > >
> > > > The idea makes sense at the first glance, but actually I'm worried
> > > > about mixing per-memcg and per-process characteristics.
> > > > Actually, it raises many questions:
> > > > 1) if we do respect memory.min, why not memory.low too?
> > >
> > > memroy.low is different with memory.min, as the OOM killer will not be
> > > invoked when it is reached.
> > > If memory.low should be considered as well, we can use
> > > mem_cgroup_protected() here to repclace task_under_memcg_protection()
> > > here.
> > >
> > > > 2) if the task is 200Gb large, does 10Mb memory protection make any
> > > > difference? if so, why would we respect it?
> > >
> > > Same with above, only consider it when the proctecion is enabled.
> >
> > Right, but memory.min is a number, not a boolean flag. It defines
> > how much memory is protected. You're using it as an on-off knob,
> > which is sub-optimal from my point of view.
> >
>
> I mean using mem_cgroup_protected(), sam with memory.min is
> implementad in the global reclaim path.
>
> > >
> > > > 3) if it works for global OOMs, why not memcg-level OOMs?
> > >
> > > memcg OOM is when the memory limit is reached and it can't find
> > > something to relcaim in the memcg and have to kill processes in this
> > > memcg.
> > > That is different with global OOM, because the global OOM can chose
> > > processes outside the memcg but the memcg OOM can't.
> >
> > Imagine the following hierarchy:
> >      /
> >      |
> >      A         memory.max = 10G, memory.min = 2G
> >     / \
> >    B   C       memory.min = 1G, memory.min = 0
> >
> > Say, you have memcg OOM in A, why B's memory min is not respected?
> > How it's different to the system-wide OOM?
> >
>
> Ah, this should be considered as well. Thanks for pointing out.
>
> > >
> > > > 4) if the task is prioritized to be killed by OOM (via oom_score_adj),
> > > > why even small memory.protection prevents it completely?
> > >
> > > Would you pls. show me some examples that when we will set both
> > > memory.min(meaning the porcesses in this memcg is very important) and
> > > higher oom_score_adj(meaning the porcesses in this memcg is not
> > > improtant at all) ?
> > > Note that the memory.min don't know which processes is important,
> > > while it only knows is if this process in this memcg.
> >
> > For instance, to prefer a specific process to be killed in case
> > of memcg OOM.
> > Also, memory.min can be used mostly to preserve the pagecache,
> > and an OOM kill means nothing but some anon memory leak.
> > In this case, it makes no sense to protect the leaked task.
> >
>
> But actually what memory.min protected is the memory usage, instead of
> pagecache,
> e.g. if the anon memory is higher than memory.min, then memroy.min
> can't protect file memory when swap is off.
>
> Even there is no anon memory leak, the OOM killer can also be invoked
> due to excess use of memroy.
> Plus, the memory.min can also protect the leaked anon memroy in
> current implementation.
>

BTW, if there are two different memcgs open the same file, the memcg
proection will not work if one memcg is protected while another memcg
is not protected.
But that may be a rare case.

> > >
> > > > 5) if there are two tasks similar in size and both protected,
> > > > should we prefer one with the smaller protection?
> > > > etc.
> > >
> > > Same with the answer in 1).
> >
> > So the problem is not that your patch is incorrect (or the idea is bad),
> > but you're defining a new policy, which will be impossible or very hard
> > to change further (as any other policy).
> >
> > So it's important to define it very well. Using the memory.min
> > number as a binary flag for selecting tasks seems a bit limited.
> >
> >
> > Thanks!

