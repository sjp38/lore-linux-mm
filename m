Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23F9AC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 08:11:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBD1120818
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 08:11:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q1gEUhdP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBD1120818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EFF06B0008; Fri, 12 Apr 2019 04:11:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5796F6B000A; Fri, 12 Apr 2019 04:11:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41AAD6B000C; Fri, 12 Apr 2019 04:11:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9716B0008
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 04:11:07 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id v193so7943598itv.9
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 01:11:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZHfN9HC9KjO69uoWFU8xq3oAmqPFxlHUhLDi5aTBC/o=;
        b=S05KwjOKTwMmyWVgYlsFFbO3pW6O8xWCyg2WwhVvdA01B3NTwgBQ8m0zjJtxPycz0r
         M+EW6l4cD2ljIA/ksC5G/wyXpORvwFQHYq/jzXealva5F14U99FV0WsQLYs39VDPeUZ4
         SpYREovvklT5irYqYUD/Da1NfxEhwT8BImYZ0NbGLRBcUP475HYyFe9VyPnXWsH1n3yR
         xqnLmgCshHcn/qMqJRxExGTNCGSbd6tOPowGTJc8PSMwcFRilW4KKhdlycNhoavZJlqs
         Te0cIef0GHYN6MCb3rbCOIQwmz6pNDQUYGIBjZ6yfAdJdAFRnyzhFVMPy7C2SaXGPM4F
         w28g==
X-Gm-Message-State: APjAAAWb6802AC4mF9WuQ/vz0uAUyvcpHU6fwRwBNCEX5OZ5AzSVGv3v
	LvJZ44msXXks6z1oWj0gNAkfMXiE8RwcZKepXFezenHzeN6zu/9BQLTaOmavZ426VqTB7bd6WBi
	HuFdqWm51iDo9RWTL/kjxTmfPBOhd0XnDyu2KKpJlKAwJhNL4bsKqu7HfDJjRUOKLsw==
X-Received: by 2002:a02:2949:: with SMTP id p70mr28185597jap.48.1555056666853;
        Fri, 12 Apr 2019 01:11:06 -0700 (PDT)
X-Received: by 2002:a02:2949:: with SMTP id p70mr28185553jap.48.1555056666118;
        Fri, 12 Apr 2019 01:11:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555056666; cv=none;
        d=google.com; s=arc-20160816;
        b=YIRbspU1gawprVi2bnkwnC731xHk1q9B0nZMBKm3UcBym05z/nwERK8SpMpiXzrFUi
         e8BV9M6BayAuDhnTLq6epHFl6s8lRqWCzxxa9yS1AxzoGh1IrMqg6fAVSG1GUjSYKPYt
         sul+3iuyC33HqX++cadgXeUqyEGNuwJ8xwtzp4PHFuSzI084dVq/NwJJ+u/SXzSiyGzw
         fyaM2IYI3a+qpo3p48ebCc1q9fDir2/rXZodQWgQvNY/6iRbFQHMebq3YSWdoS92Q6JF
         2STfuyLfrKpL+JSTbM9eyFVqdeads0jPCZQBJJVS+xfQfup98PDQ4KMXHZprCOsGSf9j
         bCKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZHfN9HC9KjO69uoWFU8xq3oAmqPFxlHUhLDi5aTBC/o=;
        b=F3hc7v+4gs8dmZH+qVJCdyN6R/oLF1fpwMTS0HN2yFtnhZz1lh5/cA1s61NOAcNTPE
         O25O03HwtDFuTuEp0x/DYo1+B0UBwiggCi7hvz88qyCdry34fIn8bhXc7HngV1RC2YG2
         NGMxNYVqbLUwNYAs/S88JOQjpfjCxQ41K0uPIBqDmEwKrUpXtCQxL4Q1Hy3lrUbAesXz
         1kAWDJPujZs6zzju8rYyyGjDySdTwizcBAwmYtadVEp1aErumK42wKJIVPWQcVi75oaT
         3n11aKEXt1uEubDfUVYP3o5SCFQ/d7HvvdHsHLDJathp53jkAKRx6bS167jscU0cXl9V
         rkCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Q1gEUhdP;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j192sor11757965itj.28.2019.04.12.01.11.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 01:11:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Q1gEUhdP;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZHfN9HC9KjO69uoWFU8xq3oAmqPFxlHUhLDi5aTBC/o=;
        b=Q1gEUhdPktabF84Zr34eCuqua2XyGAzusJ/GSPPFPWZ43YfAg+86TID91GE6vN0mYC
         g0r9Gs+Wj7Sy7BJUIMoX0DySH+EumhBvN0hmaZuBU8zBOJYh221oXsQYLrgKZm77dNlj
         tIqLrFX9LxfjSBr3ypPi5q9nR0EXRJGdbUcxQDNdAW2p5dnXHuNV3SNic6dreGCBKbhb
         v0SreAk1EBClzHZdzm5tyeBKpggS+STzC0LcE6Suy5Au5DnWYqz0hTiICP95pOkGX6Xd
         SfqV+Rj+tmbAGx/8ckvBDdv0kjrPz+Ju/nvZ8Fy4xH3otpIGUe0W7Wr+YC0zi379+Mn+
         /O2A==
X-Google-Smtp-Source: APXvYqxuavWGmBIa7fuWdaqqo8q5jLiydV2mlSWytS+t6ZwCQjB9ya7RWgHAQGn+NC3zbLz47GWsLGPkZJklFWX3nk0=
X-Received: by 2002:a24:ba15:: with SMTP id p21mr10413200itf.66.1555056665796;
 Fri, 12 Apr 2019 01:11:05 -0700 (PDT)
MIME-Version: 1.0
References: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
 <20190411122659.GW10383@dhcp22.suse.cz> <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
 <20190411133300.GX10383@dhcp22.suse.cz> <CALOAHbBq8p63rxr5wGuZx5fv5bZ689A=wbioRn8RXfLYvbxCdw@mail.gmail.com>
 <20190411151039.GY10383@dhcp22.suse.cz> <CALOAHbBCGx-d-=Z0CdL+tzWRCCQ7Hd9CFqjMhLKbEofDfFpoMw@mail.gmail.com>
 <20190412063417.GA13373@dhcp22.suse.cz>
In-Reply-To: <20190412063417.GA13373@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 12 Apr 2019 16:10:29 +0800
Message-ID: <CALOAHbBKkznCUG39se2wcGt9PZYiGFhCm9t2t-X+CL5yipT8cQ@mail.gmail.com>
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

On Fri, Apr 12, 2019 at 2:34 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 12-04-19 09:32:55, Yafang Shao wrote:
> > On Thu, Apr 11, 2019 at 11:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Thu 11-04-19 21:54:22, Yafang Shao wrote:
> > > > On Thu, Apr 11, 2019 at 9:39 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Thu 11-04-19 20:41:32, Yafang Shao wrote:
> > > > > > On Thu, Apr 11, 2019 at 8:27 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > > >
> > > > > > > On Thu 11-04-19 19:59:51, Yafang Shao wrote:
> > > > > > > > The current item 'pgscan' is for pages in the memcg,
> > > > > > > > which indicates how many pages owned by this memcg are scanned.
> > > > > > > > While these pages may not scanned by the taskes in this memcg, even for
> > > > > > > > PGSCAN_DIRECT.
> > > > > > > >
> > > > > > > > Sometimes we need an item to indicate whehter the tasks in this memcg
> > > > > > > > under memory pressure or not.
> > > > > > > > So this new item allocstall is added into memory.stat.
> > > > > > >
> > > > > > > We do have memcg events for that purpose and those can even tell whether
> > > > > > > the pressure is a result of high or hard limit. Why is this not
> > > > > > > sufficient?
> > > > > > >
> > > > > >
> > > > > > The MEMCG_HIGH and MEMCG_LOW may not be tiggered by the tasks in this
> > > > > > memcg neither.
> > > > > > They all reflect the memory status of a memcg, rather than tasks
> > > > > > activity in this memcg.
> > > > >
> > > > > I do not follow. Can you give me an example when does this matter? I
> > > >
> > > > For example, the tasks in this memcg may encounter direct page reclaim
> > > > due to system memory pressure,
> > > > meaning it is stalling in page alloc slow path.
> > > > At the same time, maybe there's no memory pressure in this memcg, I
> > > > mean, it could succussfully charge memcg.
> > >
> > > And that is exactly what those events aim for. They are measuring
> > > _where_ the memory pressure comes from.
> > >
> > > Can you please try to explain what do you want to achieve again?
> >
> > To know the impact of this memory pressure.
> > The current events can tell us the source of this pressure, but can't
> > tell us the impact of this pressure.
>
> Can you give me a more specific example how you are going to use this
> counter in a real life please?

When we find this counter is higher, we know that the applications in
this memcg is suffering memory pressure.
Then we can do some trace for this memcg, i.e. to trace how long the
applicatons may stall via tracepoint.
(but current tracepoints can't trace a specified cgroup only, that's
another point to be improved.)
I'm not sure whether it is a good practice, but it can help us.

Thanks
Yafang

