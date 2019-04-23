Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CF9BC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:35:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B35F214AE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:35:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Nj76MHae"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B35F214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94E9E6B0003; Tue, 23 Apr 2019 13:35:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FCEB6B0005; Tue, 23 Apr 2019 13:35:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 817876B0007; Tue, 23 Apr 2019 13:35:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 390C26B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:35:02 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id h13so512864wmb.6
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:35:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qzFuDLbrnGh5wznnk+v0n5g8UB/75JWXjUeYUHwmbCE=;
        b=opP8Jw7Yvl6RAEOfDkPInjt7a1BvWIUEuzoNO2gg9raRNWTV399udUY6npZS2ju52m
         et+dpwFH7M44M3Mmje9Gi19yZRu6RmsT01sh3aB26FmlQAfMp5X7dndA9yX1Hx+WLrwY
         P2tJDNrTWsn8uWjSRNvFv1hrk8/9M+1sAoJK2U4AQoxq7HLCWzkxUlspMWaZQx8Rfiwi
         mwtw3+UOwyyPLuyflFyJm+/bYVtGtOYaEEV3ARhQfGTFQrl5A44A3IGct6peTS/IkmMG
         26EQWnP8Gmna+Fr30QvMz7SKWtxFt1D5X9Fq3+qXR7GMB0qNy54yQo7Olb4asa3EaF2n
         gwcA==
X-Gm-Message-State: APjAAAVowPCaphSaIwcoYQlhjQoeeau0MdHfk4QQja8LrjFjYymUbJAc
	8GUftcuUziyZnXQVw/a0ZhzQ7/UDxAc6RhXGu+EErgEp2Az0O1pMTfPxtjqJGzkSak/eL6ACF59
	GN+l/Av2JKsIEWuS0Dvb/YWrmEybZntKC2zpgwrSQhkThu9UEJeV2UkenfYwUaMEcGQ==
X-Received: by 2002:adf:dc83:: with SMTP id r3mr18044505wrj.179.1556040901495;
        Tue, 23 Apr 2019 10:35:01 -0700 (PDT)
X-Received: by 2002:adf:dc83:: with SMTP id r3mr18044469wrj.179.1556040900850;
        Tue, 23 Apr 2019 10:35:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556040900; cv=none;
        d=google.com; s=arc-20160816;
        b=A6nT/lSVQ35aO6ElfSKrKSG2WLmoUQrom8GJMP8GNZnFljynOxG077DvL2jlfhYHTY
         YrL7tHKSRbDSU+fCfzsczGdoxmKNioysm4kOzZGww1vnwIz126F1yX3ShlxdpAP9DNoQ
         dKRKh/bCk825MVRSpDFXzQXakLwkJSQURwC9RbvKaUH/DdDqHcHSY9i97JeqTsTeLERK
         gIWdtdafuE9aGxmg2x8E4Mftmiz2TNUd1lts/4dUflkuB3pXeKKUZWWhwCjwEVFQtOy6
         mfX3zGrx03W27GylSGw32JzYqUNSU0EUbwYfpYzf2kYJlhIpaW0kaUY3AFVSIjBfKAhJ
         FDxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qzFuDLbrnGh5wznnk+v0n5g8UB/75JWXjUeYUHwmbCE=;
        b=q6M2iAvDHT7bDs+yb1FU5k7YXoVLKdh+LjmpJ12ypn87ltxCOt+MGBkYo88U9MeYPU
         cs0e07vtEq8OQbcenrCnFasdak55V21q4HCSzKNqAT2AVk7C5kUDxhPqH+zBEyFHZ7wd
         rMUF2gLRBDQcvfHvKigHrUnpInkC3zfmRVVgoX306ouSdorbvdDJsptuD+00/UGgxrCt
         2VINU7dHyjazbUPEvdo7knn63bs4Li434hJks04fWVLlWqkxMD93oOZOCe2C9L2ye3yc
         8irIm//ZayVcuhuMmBMg8Ff/tZOTwIu1WdjMnIAepk3VsMGWKj+jI1WPCB47F2OSO0uT
         tKPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Nj76MHae;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l184sor8698613wml.4.2019.04.23.10.35.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 10:35:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Nj76MHae;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qzFuDLbrnGh5wznnk+v0n5g8UB/75JWXjUeYUHwmbCE=;
        b=Nj76MHaeVYnJlpOz01FrSjWdpGajpTvndjXJq98V79klCSQQyWgKBusKQWVC/pC8og
         Y276I6V3wWzCMX9Vkz8kq/gUI9wwGPyhWCHYdlmzpy70N4GH/efGT2liK/zizfDVdiLY
         LD+3PUH2XEDOt6XoNK5i2NLz7vEOULMz+LqF5DrhuVkWKlDDzQtFxzx1g8K6nuPQCJnS
         LiXMTV5R+PWF/6HY0Wl218k28FvgeTbDarw76RtmnNsYyj9GLfDmSfuJNZ8OXP9VHIp9
         XUE1OumEEfLoDOLu4zI7lpkd8Sb+kwdIA6ywU0GU31Rtck6wQkqUFyujwyGR3tTbM77q
         3rxg==
X-Google-Smtp-Source: APXvYqwXRBuAEtzf0CNNqpbtc7maxOPyCk6Zh4FAIhAuQsGSKFwibWJ0lSOUKD3t9myjUj/+PF6nF+m+3JItNjc5ls4=
X-Received: by 2002:a1c:1f46:: with SMTP id f67mr286948wmf.74.1556040900069;
 Tue, 23 Apr 2019 10:35:00 -0700 (PDT)
MIME-Version: 1.0
References: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
 <8588314f167c9525e134ade91afdbebcd9e62eb1.camel@surriel.com>
In-Reply-To: <8588314f167c9525e134ade91afdbebcd9e62eb1.camel@surriel.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 23 Apr 2019 10:34:48 -0700
Message-ID: <CAJuCfpF2OVp=161ADh+XkrH_WjMHCmPDpLJSsqcstz9a5AV90A@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
To: Rik van Riel <riel@surriel.com>
Cc: Shakeel Butt <shakeelb@google.com>, lsf-pc@lists.linux-foundation.org, 
	Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tim Murray <timmurray@google.com>, 
	Minchan Kim <minchan@kernel.org>, Sandeep Patil <sspatil@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 9:08 AM Rik van Riel <riel@surriel.com> wrote:
>
> On Tue, 2019-04-23 at 08:30 -0700, Shakeel Butt wrote:
>
> > Topic: Proactive Memory Reclaim
> >
> > Motivation/Problem: Memory overcommit is most commonly used technique
> > to reduce the cost of memory by large infrastructure owners. However
> > memory overcommit can adversely impact the performance of latency
> > sensitive applications by triggering direct memory reclaim. Direct
> > reclaim is unpredictable and disastrous for latency sensitive
> > applications.
>
> This sounds similar to a project Johannes has
> been working on, except he is not tracking which
> memory is idle at all, but only the pressure on
> each cgroup, through the PSI interface:
>
> https://facebookmicrosites.github.io/psi/docs/overview
>
> Discussing the pros and cons, and experiences with
> both approaches seems like a useful topic. I'll add
> it to the agenda.

This topic sounds interesting and in line with some experiments being
done on Android. Looking forward to this discussion. CC'ing Android
folks that might be interested as well.

> --
> All Rights Reversed.

