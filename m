Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 046D3C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:04:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB85F21850
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:04:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DCTsz4ZE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB85F21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D7206B0007; Tue, 23 Apr 2019 13:04:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2852F6B0008; Tue, 23 Apr 2019 13:04:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 150646B000A; Tue, 23 Apr 2019 13:04:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id E20CD6B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:04:32 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id d2so12717818ybs.10
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:04:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yaH/Jtr8tMiskxFbQwX+zOBm6Mn7KRGOr50Ku4KtuQo=;
        b=U4C8cpSjZgkcNjafWzUuJsIUubE4QRXgcDfNWsg5EUTXejPvyZ4WfM2bWwIJnJfJL2
         AyJQ9FdufERUVNOaqdtB63dmt0LedCcZrJzAzOZwr9YNIi7qsUk4qCrve0eXMH2lFtK+
         pNzdBbBBLtn7UV7KPDmHnrxQzZePRGuLB+ncEA8WaBjax2vqhXhbIWEmFIdFskv+U02x
         l+D4OxaKcu+rn5kYO0YxLSNBgQuk3RGCgkiyBQGGCozXX9TrBz0h3vglqTxxm8H0k7qO
         l+qMdwAbylfPKLYqyvfohvU0nietWlYKhUnY2tqlhujo3VgwybISQnsZ55B3tGXJ+izi
         IWFw==
X-Gm-Message-State: APjAAAXl2ZVCq6wFWIwrsO5tD6X0G/VgmqR1fDSG0N453aruJVLUouO9
	gAbfESVOlnJkHXoTN4cxN49qbl+xps2VGn4n15TU/4NMkjsNWWoWYUQtCzFfwPigguwsWcUWmJU
	UBClnKXh1DLro+jtAvMxbgs2WLm7b1egU/ZCVBaYbB6NmDM3FKi7ahvQ/j3nY7bTICA==
X-Received: by 2002:a25:6c45:: with SMTP id h66mr22405498ybc.371.1556039072409;
        Tue, 23 Apr 2019 10:04:32 -0700 (PDT)
X-Received: by 2002:a25:6c45:: with SMTP id h66mr22405409ybc.371.1556039071644;
        Tue, 23 Apr 2019 10:04:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556039071; cv=none;
        d=google.com; s=arc-20160816;
        b=Ot7YTsGW9aZsLAfvsM2PndYWftIZddu/L0aUVQx0yM2hBeoUuSI9QtzJFtrgHaREmo
         mfamnR5juPz3ngzDMkaLfNsovE06Bqx9MAgwa2Aow1XacmBNmmoB3VlE5ZlIBa1aF4Q2
         bR36Pu8zUBkeBvXxh3VFqVQ0KZeaGxlrMMvdHE4UmrN6iPC7sNHRMG6Z8otX4d9So47z
         Js01EnHdTvSsDlw/xwgA0EClsKaQuOuP270BBaXaQj3o1WD+L6XsqDAl6Cz22xvh8JWb
         8H5vfv6XUY/n/9A/fb1LXT2xuiA9uxMbPe+TO5aoDW1FwBRaqSpeW1d2DbPUEQkv3fxK
         2+1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yaH/Jtr8tMiskxFbQwX+zOBm6Mn7KRGOr50Ku4KtuQo=;
        b=N3xkmgrrhmg+TqYu1bwODrhDzdipGqZI5vA7jfG2MSjG3FE0CeiNLuHylhyWdWS6zd
         oH+KroqiK4OwtCzYUgU0Znb6gUyWGobS4IHMctCZ9i9M7yHgVbaTfubClWqwjPP/lUkn
         CrlOTTYeI0j/M5RZdz/PyuPn8MfLlg1Eg5XcMemyXyhXF2btiZD2kIlUtJptsmRR8z+5
         XzjymB2lqyxrKdIxYHz4idV9VtWkqvF/pbTNk00vsf6fMxbpcMCbwo8lA2YU+iX+caa9
         5NtMIwS5OfCKur8OaYO2BLf7w1HsoImJuAR279kgzAFDIjChS5K0barVkWeZLmpiSmMa
         hDuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DCTsz4ZE;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g126sor494905ywf.186.2019.04.23.10.04.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 10:04:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DCTsz4ZE;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yaH/Jtr8tMiskxFbQwX+zOBm6Mn7KRGOr50Ku4KtuQo=;
        b=DCTsz4ZE7uVWRiOwnOvv0HcrH39zGQFPIxBeD1sx6fSP7WcXqvt0bjW0/FpJoDp2Vc
         8O1C5uG+FrdQcDA5QYQmjw/dYXrMvsMP7Mp+LnXtbVgNShZ259b/FbNjVmS/KFFb2gmt
         h7dtUUeB3mgNLUyTvAtBLCQAhCNQ+23ihYw/hpj/E5Udf11kPD8WVrp4RLSNPlmsIUoR
         K3xIuoMWT+wX1a5Dt7xRiBoE2+uF81nmT+USa59DL6EnKg4z3AfsE1rIlIVqHECxQvWl
         o7DWsNJAATAFHnm4qbK4jEEgw83Fc+IIMdXbvhoy2MqtXW8Wb+YZJmwPC2cBWPER3Aam
         dXIA==
X-Google-Smtp-Source: APXvYqxmNPMtDOm+YD3Z1SgA6Ois8TlE789lHwyWD15Oq4G2sI+luU3ffSDjWkpPLkgRwCD0yWG+JNZTIaCPEU+32DU=
X-Received: by 2002:a81:78c6:: with SMTP id t189mr22873227ywc.27.1556039070992;
 Tue, 23 Apr 2019 10:04:30 -0700 (PDT)
MIME-Version: 1.0
References: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
 <8588314f167c9525e134ade91afdbebcd9e62eb1.camel@surriel.com>
In-Reply-To: <8588314f167c9525e134ade91afdbebcd9e62eb1.camel@surriel.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 23 Apr 2019 10:04:19 -0700
Message-ID: <CALvZod44yAJTLuvg9jtqHF9uKuKNtXL9p_=3Ld+eakSijAbo1A@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
To: Rik van Riel <riel@surriel.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>
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

I think both techniques are orthogonal and can be used concurrently.
This technique proactively reclaims memory and hopes that we don't go
to direct reclaim but in the worst case if we trigger direct reclaim
then we can use PSI to early detect when to give up on reclaim and
trigger oom-kill.

Another thing I want to point out is our usage model: this proactive
memory reclaim is transparent to the jobs. The admin (infrastructure
owner) is using proactive reclaim to create more schedulable memory
transparently to the job owners.

> Discussing the pros and cons, and experiences with
> both approaches seems like a useful topic. I'll add
> it to the agenda.
>

Thanks a lot.
Shakeel

