Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B5F1C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 09:09:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C73C320850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 09:09:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C73C320850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C91F6B0266; Fri, 12 Apr 2019 05:09:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3782D6B026A; Fri, 12 Apr 2019 05:09:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 290036B026B; Fri, 12 Apr 2019 05:09:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CF4246B0266
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 05:09:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d2so4451148edo.23
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 02:09:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Cttv2IKU7z/oTX+NA+ULzPtN2GJIK09M88JGVRDrKnI=;
        b=keMdH5NaRkRzoX030lxgUWDRAZ7SfqSusysKqKv3mjJGxsJ8Yznx1AHntxeQfCpi90
         MIHXWHVD1GRRyf58XFhAT6s+6KRD/sqH3byb8BQh2dS8OwRne3fAhUWxuHxK8Wl9yVuZ
         Hbuy50+HE2PmqekZLQRHnL+Vghqt/2z7OKPtwFvEylbcPXmHhj9ZOS9w+7zYkicgvcT2
         bMlm73RTsKny89gk02QF5mjMv2ujlMVtCHYXBK7tvmp3rF4ifDDgkrinFgFfX1sHjxs1
         +g9YDr010bG11EVvnc6nZ4RjvfcTgsuVqcKiDLNTYJW9khUyREUTX+6TJtyn1ccLf+AI
         XGsA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVeFOhNG++ay3bZNi5hz1L0ee8AOsSr4AtgFYv01RgKjbJNpXj3
	dTJmElRMCEwuvyTHt2BhI1hQzKdlJoz+ItuIVL4R6K6Qkha5q3bSZLcGchyl2J8uyvizdb9CK+q
	HDokR+T/kTXC5/QagPIop4P8sGwJ5U1ULIDb34OjeB+u25f4XNXUhUmGxiXHwdI0=
X-Received: by 2002:a17:906:25d1:: with SMTP id n17mr30099230ejb.257.1555060172316;
        Fri, 12 Apr 2019 02:09:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLRPh1ET2JQ1+taPYXROPBo48qFqByNMnyU3738VWBcKhv7xJixclUpnutC22rVuOLJ/u6
X-Received: by 2002:a17:906:25d1:: with SMTP id n17mr30099190ejb.257.1555060171361;
        Fri, 12 Apr 2019 02:09:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555060171; cv=none;
        d=google.com; s=arc-20160816;
        b=bY7jJR0rMamddpSPVK01kqERPy/n70DkMdqLnitYhkGEWwWvWTb9hcQ01iX1ZQ5rAX
         8RefhZHWCE5sPxc63Kt1qGoUrYEn9Vekz107dq5hbdnyRQMPKcVVIPq5Vqm33jYtmtc9
         SSGpgKtcZfO18Wd/HsC+NA8reDveOtwsyi6p3e4R8ZyUidg7kccETpsD+z23SpOG8rDW
         NgS2o8aYocUG8oVfdYgSVkYBgnJpMjinsu4ET8hzE/EA4ruq6aokjY6G1twIrEl/QBOm
         MScCsvkv3ohuAAurozBuXr+1vxFc3rL7eAy6x3xsGJ54sfzCDdZuwlacRe0Vh+NJdKMu
         8Bpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Cttv2IKU7z/oTX+NA+ULzPtN2GJIK09M88JGVRDrKnI=;
        b=GKXf1tY1kamfgMuqHC1iCKV2NoNKOESclJOHVbCSGcQZsQ3j3DGBicNMpWqavWQL6r
         LCb7SgaxppdXakz6MTQGvAFtcDsI2M3PUTiyGIhScKIvVLstQ0HBCT2E/Q4WEoH7rQIA
         tHNbSSwaHWkdbGAc/sqK0MSwLCF6I7p7ylxUigfrIMLJe4TPlunm7L8OSCGVoA+/T4U8
         E7lajwNln7ewaotC2sygbkcOAmARQSBdeiiV7/EcoUWx3hvoLs2yfq5Itpt+K9Ex403Q
         x0vJl1fB1cTTU10obW8RpeGWM2ShtovWU+WdwP9z2TFYWtx27k6sVG7n6Oy7tuKOKFT+
         /fdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4si3842789edp.3.2019.04.12.02.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 02:09:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 94066AE1B;
	Fri, 12 Apr 2019 09:09:30 +0000 (UTC)
Date: Fri, 12 Apr 2019 11:09:29 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcg: add allocstall to memory.stat
Message-ID: <20190412090929.GE13373@dhcp22.suse.cz>
References: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
 <20190411122659.GW10383@dhcp22.suse.cz>
 <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
 <20190411133300.GX10383@dhcp22.suse.cz>
 <CALOAHbBq8p63rxr5wGuZx5fv5bZ689A=wbioRn8RXfLYvbxCdw@mail.gmail.com>
 <20190411151039.GY10383@dhcp22.suse.cz>
 <CALOAHbBCGx-d-=Z0CdL+tzWRCCQ7Hd9CFqjMhLKbEofDfFpoMw@mail.gmail.com>
 <20190412063417.GA13373@dhcp22.suse.cz>
 <CALOAHbBKkznCUG39se2wcGt9PZYiGFhCm9t2t-X+CL5yipT8cQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBKkznCUG39se2wcGt9PZYiGFhCm9t2t-X+CL5yipT8cQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-04-19 16:10:29, Yafang Shao wrote:
> On Fri, Apr 12, 2019 at 2:34 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 12-04-19 09:32:55, Yafang Shao wrote:
> > > On Thu, Apr 11, 2019 at 11:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Thu 11-04-19 21:54:22, Yafang Shao wrote:
> > > > > On Thu, Apr 11, 2019 at 9:39 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > >
> > > > > > On Thu 11-04-19 20:41:32, Yafang Shao wrote:
> > > > > > > On Thu, Apr 11, 2019 at 8:27 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > > > >
> > > > > > > > On Thu 11-04-19 19:59:51, Yafang Shao wrote:
> > > > > > > > > The current item 'pgscan' is for pages in the memcg,
> > > > > > > > > which indicates how many pages owned by this memcg are scanned.
> > > > > > > > > While these pages may not scanned by the taskes in this memcg, even for
> > > > > > > > > PGSCAN_DIRECT.
> > > > > > > > >
> > > > > > > > > Sometimes we need an item to indicate whehter the tasks in this memcg
> > > > > > > > > under memory pressure or not.
> > > > > > > > > So this new item allocstall is added into memory.stat.
> > > > > > > >
> > > > > > > > We do have memcg events for that purpose and those can even tell whether
> > > > > > > > the pressure is a result of high or hard limit. Why is this not
> > > > > > > > sufficient?
> > > > > > > >
> > > > > > >
> > > > > > > The MEMCG_HIGH and MEMCG_LOW may not be tiggered by the tasks in this
> > > > > > > memcg neither.
> > > > > > > They all reflect the memory status of a memcg, rather than tasks
> > > > > > > activity in this memcg.
> > > > > >
> > > > > > I do not follow. Can you give me an example when does this matter? I
> > > > >
> > > > > For example, the tasks in this memcg may encounter direct page reclaim
> > > > > due to system memory pressure,
> > > > > meaning it is stalling in page alloc slow path.
> > > > > At the same time, maybe there's no memory pressure in this memcg, I
> > > > > mean, it could succussfully charge memcg.
> > > >
> > > > And that is exactly what those events aim for. They are measuring
> > > > _where_ the memory pressure comes from.
> > > >
> > > > Can you please try to explain what do you want to achieve again?
> > >
> > > To know the impact of this memory pressure.
> > > The current events can tell us the source of this pressure, but can't
> > > tell us the impact of this pressure.
> >
> > Can you give me a more specific example how you are going to use this
> > counter in a real life please?
> 
> When we find this counter is higher, we know that the applications in
> this memcg is suffering memory pressure.

We do have pgscan/pgsteal counters that tell you that the memcg is being
reclaimed. If you see those numbers increasing then you know there is a
memory pressure. Along with reclaim events you can tell wehther this is
internal or external memory pressure. Sure you cannot distinguish
kaswapd from the direct reclaim but is this really so important? You have
other means to find out that the direct reclaim is happening and more
importantly a higher latency might be a result of kswapd reclaiming
memory as well (swap in or an expensive pagein from a remote storage
etc.).

The reason why I do not really like the new counter as you implemented
it is that it mixes task/memcg scopes. Say you are hitting the memcg
direct reclaim in a memcg A but the task is deeper in the A's hierarchy.
Unless I have misread your patch it will be B to account for allocstall
while it is the A's hierarchy to get directly reclaimed. B doesn't even
have to be reclaimed at all if we manage to reclaim other others. So
this is really confusing.

> Then we can do some trace for this memcg, i.e. to trace how long the
> applicatons may stall via tracepoint.
> (but current tracepoints can't trace a specified cgroup only, that's
> another point to be improved.)

It is a task that is stalled, not a cgroup.

-- 
Michal Hocko
SUSE Labs

