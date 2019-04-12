Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34F52C282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 09:29:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D960221872
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 09:29:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K8nydP6q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D960221872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42F306B0008; Fri, 12 Apr 2019 05:29:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B7346B000A; Fri, 12 Apr 2019 05:29:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 280016B000C; Fri, 12 Apr 2019 05:29:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 033126B0008
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 05:29:42 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id z19so7201587ioc.22
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 02:29:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=aZZ6XxYYXIo0jQbZdWBEgSr5R8x+UZxy+ZSyhmSe5U8=;
        b=eamxsq+OCHNVf1NNyGjp2HjQrFHpiviCxFP0flbA7385YhiNS2VCIVINMMUcLUk4q5
         mt9V9YhAa3YXQ/5mSODhyw/tnJdOyHI+FSgb5UC3Bd3DPf2RBwaf+Vf7mIQcDMNy3kjA
         YP6+nwekRGarfuPTJiEwhgK7al49nPls0jcv3S+VHW9ShrBtWG6tSx3ATfD1Yij2d4q3
         d+kF6O1syHgUhXHrhJye0kkwYM/nmSW4kRpG0RcOP5bueqilEhRpf550WdH/w8rZZSB/
         8jupPjdtj16VklkgcDjG/ZWx4UyxGbnCiisHGzIMHlefPWYPoCGeBV1yZtgtJ99WRN8f
         L/aQ==
X-Gm-Message-State: APjAAAUgybGqLaT+/2LpysOI2ub13yamyNs3pEZKryvUzzTxbzcn+s4r
	6rsgMbW91mdvV7OU+B3cNsfTYtCpPWqf/IQkilf2uopxtFgafRsK2NPVc8kfTyTJuDLis7zyeoM
	PB9CLuYQae/hWD+ZHGvrvGsccu6AHFdfgXRQK8q90lTY90Y6JB0vPTz2U/UH2ao3MDw==
X-Received: by 2002:a24:f947:: with SMTP id l68mr11061545ith.128.1555061381739;
        Fri, 12 Apr 2019 02:29:41 -0700 (PDT)
X-Received: by 2002:a24:f947:: with SMTP id l68mr11061516ith.128.1555061380912;
        Fri, 12 Apr 2019 02:29:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555061380; cv=none;
        d=google.com; s=arc-20160816;
        b=oVsuY3TuOwKb+QMtVGCZdQlQ6CVLIWiOXVMf/N/6KBue204Uy6ArhfR4O9n6r4rwac
         7mP1A3wBL/ZAaiuqPPz51lvMPfPpvVKksBmVZdBox/lZ6zuWUkwODl7g48N1tEhw5bRz
         hymRWZeipq+8E6ChPbn0PS1BhJ8pSH2As8tqjvRXuA/MeylfZ9O+G6VkL8EFtrbZmp6k
         tB67e4/tT6l3Cjjxhbq7AHwj8HAwVxYGiMO8XuiChHVhjqYxOnpWmDRSx22ntUmIUjeE
         3xHcka3o6f+BxDRbXlMRlMzUiGHwJBau+BxeBtcT//AuQ/+kY9YJjbvLo3vSWKiUv1Lw
         jfkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=aZZ6XxYYXIo0jQbZdWBEgSr5R8x+UZxy+ZSyhmSe5U8=;
        b=BpWPT0ALgAIiiym0mltcYuC98bHxQPLvW0NthB5uzs/wxbYgVcrIEXW/wmAcOUt0DD
         +JQoP2HYgLd8Zs83uzjtDl16wOIN/5xWuCRSfCkG6zk6hu9bGvkCNEQ4uVYu7ZYwgs5B
         s99x/odWK5TgzRxhFGuRdZ5VdvXgnXo0m+bTclAV6jb7oZNFtGg6SoXA5ReVg47W2Xjt
         xBNqoZKCLvk00wbJFy6GQqoCR1H622K+5B1mUJhuEYLZRCeZD+43vMXndUr8B/B65Qc7
         hXr6bF7hseuqQ0vPM9eCagwlXmknkaS5agJ5rAtnJGbdqnwRuvXQAnGnPMPosp2D0W0y
         I5lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K8nydP6q;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w199sor13287357ita.15.2019.04.12.02.29.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 02:29:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K8nydP6q;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=aZZ6XxYYXIo0jQbZdWBEgSr5R8x+UZxy+ZSyhmSe5U8=;
        b=K8nydP6qmFFTSxaX+RK+nM/S4vrYLDeO5h6NO/Z/W5EI67Gtwf+7rjD8tc4pNZS6fu
         SDvWwHstyOm6lLNlznPDIS4q9YD9lyhtQ54M4O8pfvsu3BRL09Ila0gbey04b73gpQ37
         LDIPj+sPzJevtYanhlHLzdhs4kBzTbFh+tVyZkjvK+khaGtZVlcPEuXRpmqRdAWWoZD/
         8/+W67Glx5dvRpcKpzaqXXhZkndY1sx95EGP6pRka7ZiSHaU4yLxk/z/nh8QwJ6ZlkeZ
         Bld/E1PmjQwabeMjDXpP2y21Rc6686fc+xHfn5H1XaJhwfyIjyutvBZXrU06Q2vqcSGK
         rYXQ==
X-Google-Smtp-Source: APXvYqxPrzS8OYIzLCTQQXW3bSOixsAbT0KoM4Xfajo5ht0Z6E5Yg4jO5jqwMIFfFhE18UAPH+sfYkmIyXbby9hcJFA=
X-Received: by 2002:a05:660c:111:: with SMTP id w17mr12338572itj.62.1555061380558;
 Fri, 12 Apr 2019 02:29:40 -0700 (PDT)
MIME-Version: 1.0
References: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
 <20190411122659.GW10383@dhcp22.suse.cz> <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
 <20190411133300.GX10383@dhcp22.suse.cz> <CALOAHbBq8p63rxr5wGuZx5fv5bZ689A=wbioRn8RXfLYvbxCdw@mail.gmail.com>
 <20190411151039.GY10383@dhcp22.suse.cz> <CALOAHbBCGx-d-=Z0CdL+tzWRCCQ7Hd9CFqjMhLKbEofDfFpoMw@mail.gmail.com>
 <20190412063417.GA13373@dhcp22.suse.cz> <CALOAHbBKkznCUG39se2wcGt9PZYiGFhCm9t2t-X+CL5yipT8cQ@mail.gmail.com>
 <20190412090929.GE13373@dhcp22.suse.cz>
In-Reply-To: <20190412090929.GE13373@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 12 Apr 2019 17:29:04 +0800
Message-ID: <CALOAHbAcXDDdq_XO+hvwTq6PMNjFFgHAY2OPmkAReKV8-wR6sg@mail.gmail.com>
Subject: Re: [PATCH] mm/memcg: add allocstall to memory.stat
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, 
	Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 12-04-19 16:10:29, Yafang Shao wrote:
> > On Fri, Apr 12, 2019 at 2:34 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Fri 12-04-19 09:32:55, Yafang Shao wrote:
> > > > On Thu, Apr 11, 2019 at 11:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Thu 11-04-19 21:54:22, Yafang Shao wrote:
> > > > > > On Thu, Apr 11, 2019 at 9:39 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > > >
> > > > > > > On Thu 11-04-19 20:41:32, Yafang Shao wrote:
> > > > > > > > On Thu, Apr 11, 2019 at 8:27 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > > > > >
> > > > > > > > > On Thu 11-04-19 19:59:51, Yafang Shao wrote:
> > > > > > > > > > The current item 'pgscan' is for pages in the memcg,
> > > > > > > > > > which indicates how many pages owned by this memcg are scanned.
> > > > > > > > > > While these pages may not scanned by the taskes in this memcg, even for
> > > > > > > > > > PGSCAN_DIRECT.
> > > > > > > > > >
> > > > > > > > > > Sometimes we need an item to indicate whehter the tasks in this memcg
> > > > > > > > > > under memory pressure or not.
> > > > > > > > > > So this new item allocstall is added into memory.stat.
> > > > > > > > >
> > > > > > > > > We do have memcg events for that purpose and those can even tell whether
> > > > > > > > > the pressure is a result of high or hard limit. Why is this not
> > > > > > > > > sufficient?
> > > > > > > > >
> > > > > > > >
> > > > > > > > The MEMCG_HIGH and MEMCG_LOW may not be tiggered by the tasks in this
> > > > > > > > memcg neither.
> > > > > > > > They all reflect the memory status of a memcg, rather than tasks
> > > > > > > > activity in this memcg.
> > > > > > >
> > > > > > > I do not follow. Can you give me an example when does this matter? I
> > > > > >
> > > > > > For example, the tasks in this memcg may encounter direct page reclaim
> > > > > > due to system memory pressure,
> > > > > > meaning it is stalling in page alloc slow path.
> > > > > > At the same time, maybe there's no memory pressure in this memcg, I
> > > > > > mean, it could succussfully charge memcg.
> > > > >
> > > > > And that is exactly what those events aim for. They are measuring
> > > > > _where_ the memory pressure comes from.
> > > > >
> > > > > Can you please try to explain what do you want to achieve again?
> > > >
> > > > To know the impact of this memory pressure.
> > > > The current events can tell us the source of this pressure, but can't
> > > > tell us the impact of this pressure.
> > >
> > > Can you give me a more specific example how you are going to use this
> > > counter in a real life please?
> >
> > When we find this counter is higher, we know that the applications in
> > this memcg is suffering memory pressure.
>
> We do have pgscan/pgsteal counters that tell you that the memcg is being
> reclaimed. If you see those numbers increasing then you know there is a
> memory pressure. Along with reclaim events you can tell wehther this is
> internal or external memory pressure. Sure you cannot distinguish
> kaswapd from the direct reclaim but is this really so important? You have
> other means to find out that the direct reclaim is happening and more
> importantly a higher latency might be a result of kswapd reclaiming
> memory as well (swap in or an expensive pagein from a remote storage
> etc.).
>
> The reason why I do not really like the new counter as you implemented
> it is that it mixes task/memcg scopes. Say you are hitting the memcg
> direct reclaim in a memcg A but the task is deeper in the A's hierarchy.
> Unless I have misread your patch it will be B to account for allocstall
> while it is the A's hierarchy to get directly reclaimed. B doesn't even
> have to be reclaimed at all if we manage to reclaim other others. So
> this is really confusing.
>

I have to admire that it really mixes task/memcg scopes,
so let's drop this part.

> > Then we can do some trace for this memcg, i.e. to trace how long the
> > applicatons may stall via tracepoint.
> > (but current tracepoints can't trace a specified cgroup only, that's
> > another point to be improved.)
>
> It is a task that is stalled, not a cgroup.
>

But these tracepoints can't filter a speficied task neither.

Thanks
Yafang

