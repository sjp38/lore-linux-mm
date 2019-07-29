Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E20E1C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 17:29:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0054206DD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 17:29:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oh54sUbq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0054206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24F5F8E0003; Mon, 29 Jul 2019 13:29:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FFCC8E0002; Mon, 29 Jul 2019 13:29:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EEB18E0003; Mon, 29 Jul 2019 13:29:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DBFF48E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 13:29:04 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c1so52397556qkl.7
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:29:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=udkUdoHD+/xDbjBugzOSQ54RdKcLOvg7mCBhGnLbrHY=;
        b=U2/qtzLZVdmrjcPJ9rxu8x5QVj38ffblcs9Wiof4zOXJUrPl/q7eBs70rUyI4o3Yky
         q/TNyad8ErS+EF2dgA/S+kxHtTVZoaiDS/ou9/CxCRul6W1FCM7RP9mTImhqnasX8gAw
         3a4x1wma3qKqSE31cBSJAE/7aXaoElHXSjwCnURsO34NGrItpICesCgO4eUpeI7DTqAa
         v55rLCdG0W862bwUt3nX9cIAHVVOq4eisXOENqJ5PKRorg43sqjrsIO/pmR5ekUMa3AW
         S83+boB8f9jEZuYVv2vg5AdcccrY3FXDh5kMMN3PwxvcyFpBDYAg5F5Wyy3pV/G2JUll
         7qOw==
X-Gm-Message-State: APjAAAVyhWebGRdx2jbiH4Eco/rjijgIb9S+nsxt8k6jwQOElTpqJCF+
	JmFWhQPg/9mo5giFe2mVf9NBsq9HfwLtz0IoCt2uFViT+oj8Lb/TVUmdeVUwr1RB16GHiadTomU
	mA7lhCi++8HwQ9USQHmkror0lNfsAHPp8/ebjSZsIem4K8Z+CFehJsOMU2F/cVgM+lw==
X-Received: by 2002:ac8:2763:: with SMTP id h32mr79730893qth.350.1564421344538;
        Mon, 29 Jul 2019 10:29:04 -0700 (PDT)
X-Received: by 2002:ac8:2763:: with SMTP id h32mr79730869qth.350.1564421343518;
        Mon, 29 Jul 2019 10:29:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564421343; cv=none;
        d=google.com; s=arc-20160816;
        b=C4ULSVUW2RIIf6qx6EJ5RO2K4lhSakefKaJW11pQdRm2lrKFUtrF7FKJzzk8iFHR1A
         lf/b2L/SshP/mCc3tOpz1sqJc24+ckrhPIwm6J806en2u3+k64L2eJ8F2Jj8z8efI817
         0/c/f1+P18ZATGoMbV8bUAhVXXzhnJHdUlU/dnwBil6L5h7KYAB7NekgNWAKl8oEJIOY
         PFkLUQS8X5pI5BNeqpmBI/LUWhuPMae109DTxssdhZGl+4md8la0q+B7IFzr9/1aM/wl
         G5wDngnzzGDA+8hgtQbjGdHTs+6w7xRJGZmRYnLR1PqhDALoJDa/B9BP9sd/5CUIKB7W
         AQZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=udkUdoHD+/xDbjBugzOSQ54RdKcLOvg7mCBhGnLbrHY=;
        b=RfJoJDhpfvFZpWZUJCQ4plmLnfsFoGf6bGWV2bZ86JdXM3Ep5g8ugHDq3LBoovLbsa
         Yp3yd5bUM5kQ7fHBeUG6Ck2YqcZTPSb5S5e7QP8R357vMCFOmAkFT3YllXEbs812a6Nj
         vZ9tAZvZporfXoCVfsKfN55hsubTDAo6OinLqhhsV9RcSwNEGDiFJCGV3ecCe38qQXj/
         SCm9Q28cfUZaYjAhSsUZvMdFs/4+HmpAElSuLF+RHeJrdaXoQzKXncX6tiWXZ4sAgmpW
         Wpn16sqmS5Aj2O9DPE1fGOcXB3Jte8IhUYyRn0hcX7K1lMnoBULfDb1t7zs8M8eF9YFt
         8pqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oh54sUbq;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8sor52308054qvi.5.2019.07.29.10.29.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 10:29:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oh54sUbq;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=udkUdoHD+/xDbjBugzOSQ54RdKcLOvg7mCBhGnLbrHY=;
        b=oh54sUbqobJwz9lD8GsJU9GCOWfnXwfAsAG3K9yMfohPeWmqap0o2gqLB8B0e1ky8U
         e37WLWqIOD4v3QcbJqyhfmeWrigLZi9lTlOFjRshdB47i0McihHUiSXOYW72erAwtW4h
         4iYG5Vr7nO39ZaUSHgdLVNVGU8KH4sndynjs91oJgtSid4bkhglmXffKyl834QaAngdA
         DvOzpuLJrSTw8N+ZfdutrFul1SB6i21Sh1z00FSZXNcN8yDkXB57LOljJuo6w3lWRwWv
         ICyERxp9m8QwB3gS882QmH14NabvmB3IbdMoSsfCm0Mu2j77FzN4DCmP5/f75wALlMW6
         ffaw==
X-Google-Smtp-Source: APXvYqz19nEJwzZPl0Rc1pBiSuYwxF86on9CogNKuQGhaTvySkOxalyFhl01uTOEKTeFdMf1rKYufS3N7KlFpgwpIYQ=
X-Received: by 2002:a0c:ae50:: with SMTP id z16mr78170781qvc.60.1564421343160;
 Mon, 29 Jul 2019 10:29:03 -0700 (PDT)
MIME-Version: 1.0
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729091738.GF9330@dhcp22.suse.cz> <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
 <20190729103307.GG9330@dhcp22.suse.cz>
In-Reply-To: <20190729103307.GG9330@dhcp22.suse.cz>
From: Yang Shi <shy828301@gmail.com>
Date: Mon, 29 Jul 2019 10:28:43 -0700
Message-ID: <CAHbLzkrdj-O2uXwM8ujm90OcgjyR4nAiEbFtRGe7SOoY_fs=BA@mail.gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
To: Michal Hocko <mhocko@kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 3:33 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 29-07-19 12:40:29, Konstantin Khlebnikov wrote:
> > On 29.07.2019 12:17, Michal Hocko wrote:
> > > On Sun 28-07-19 15:29:38, Konstantin Khlebnikov wrote:
> > > > High memory limit in memory cgroup allows to batch memory reclaiming and
> > > > defer it until returning into userland. This moves it out of any locks.
> > > >
> > > > Fixed gap between high and max limit works pretty well (we are using
> > > > 64 * NR_CPUS pages) except cases when one syscall allocates tons of
> > > > memory. This affects all other tasks in cgroup because they might hit
> > > > max memory limit in unhandy places and\or under hot locks.
> > > >
> > > > For example mmap with MAP_POPULATE or MAP_LOCKED might allocate a lot
> > > > of pages and push memory cgroup usage far ahead high memory limit.
> > > >
> > > > This patch uses halfway between high and max limits as threshold and
> > > > in this case starts memory reclaiming if mem_cgroup_handle_over_high()
> > > > called with argument only_severe = true, otherwise reclaim is deferred
> > > > till returning into userland. If high limits isn't set nothing changes.
> > > >
> > > > Now long running get_user_pages will periodically reclaim cgroup memory.
> > > > Other possible targets are generic file read/write iter loops.
> > >
> > > I do see how gup can lead to a large high limit excess, but could you be
> > > more specific why is that a problem? We should be reclaiming the similar
> > > number of pages cumulatively.
> > >
> >
> > Large gup might push usage close to limit and keep it here for a some time.
> > As a result concurrent allocations will enter direct reclaim right at
> > charging much more frequently.
>
> Yes, this is indeed prossible. On the other hand even the reclaim from
> the charge path doesn't really prevent from that happening because the
> context might get preempted or blocked on locks. So I guess we need a
> more detailed information of an actual world visible problem here.
>
> > Right now deferred recalaim after passing high limit works like distributed
> > memcg kswapd which reclaims memory in "background" and prevents completely
> > synchronous direct reclaim.
> >
> > Maybe somebody have any plans for real kswapd for memcg?
>
> I am not aware of that. The primary problem back then was that we simply
> cannot have a kernel thread per each memcg because that doesn't scale.
> Using kthreads and a dynamic pool of threads tends to be quite tricky -
> e.g. a proper accounting, scaling again.

We did discuss this topic in last year's LSF/MM, please see:
https://lwn.net/Articles/753162/. We (Alibaba) do have the memcg
kswapd thing work in our production environment for a while, and it
works well for our 11.11 shopping festival flood.

I did plan to post the patches to upstream, but I was distracted by
something else for a long time, now I already redesigned it and
already had some preliminary patches work, if you are interested in
this I would like post the patches soon to gather some comments early.

However, some of the issues mentioned by Michal does still exist, i.e.
accounting. I have not thought too much about accounting yet. I
recalled Johannes mentioned they were working on accounting kswapd
back then. But, I'm not sure if they are still working on that or not,
or he just meant some throttling solved by commit
2cf855837b89d92996cf264713f3bed2bf9b0b4f ("memcontrol: schedule
throttling if we are congested")? But, I recalled vaguely accounting
sounds not very critical.

I don't worry too much about scale since the scale issue is not unique
to background reclaim, direct reclaim may run into the same problem.
If you run into extreme memory pressure, a lot memcgs run into direct
relcaim and global reclaim is also running at the mean time, your
machine is definitely already not usable. And, our usecase is memcg
backgroup reclaim is mainly used by some latency sensitive memcgs
(running latency sensitive applications) to try to minimize direct
reclaim, for other memcgs they'd better be throttled by direct reclaim
if they consume too much memory.

Regards,
Yang

>
> > I've put mem_cgroup_handle_over_high in gup next to cond_resched() and
> > later that gave me idea that this is good place for running any
> > deferred works, like bottom half for tasks. Right now this happens
> > only at switching into userspace.
>
> I am not against pushing high memory reclaim into the charge path in
> principle. I just want to hear how big of a problem this really is in
> practice. If this is mostly a theoretical problem that might hit then I
> would rather stick with the existing code though.
>
> --
> Michal Hocko
> SUSE Labs
>

