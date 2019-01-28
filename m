Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7F16C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:26:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95EAE2171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:26:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="CoGlOMn7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95EAE2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 439B68E0003; Mon, 28 Jan 2019 16:26:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E8B18E0001; Mon, 28 Jan 2019 16:26:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D90A8E0003; Mon, 28 Jan 2019 16:26:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id F01888E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:26:34 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id l9so10144967ywl.11
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:26:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=doeprTD75a3wN3TW5uXx5DNXAT9rchfp4Kk5IuJTQxU=;
        b=V9v1LFr9LspMamb4q6uU3VwFN37R+ZyRuXIHWHVKqfAaKxn6jMSfNtcCPvxgOQJwU9
         eUNaUARuA6JVJGKSPZWYLzqvmdFxA4QQeFYLk062w/mOJnm9fC4IdTfB5CVsSfyfLQvB
         epiB6chAb76frv9xqZAunOJ4t4A7W1cUJ3j6XR/aqRh4bwYpppWxobp8+ogzbgBdEWd5
         3SqMWxg4XrzprPH6V0PmcbEy1Y6NlVvpJAjL6u6/NaaMjz+EjsufalafaeTu+feEMHkD
         Pv/NMS9jAOwYpkL6VlvFsBmAsozrgcLY2iKT0nNlEZxQU7ceD6gq+gGFUx1Lm4EimPb8
         Jo6w==
X-Gm-Message-State: AJcUukc/svEQqqt2yaGMwNRI1GHpbXpA5U327WR878OIC3MvZl5vWecp
	Cb8h9x2Zegib/mc2jY4yxW+ms8/zFWcys0KHfqFCHYfdemRxPGgPiXGx29FWbPr9b343yuMy5g6
	IxTSpml+pMv8pnDXsG4oH0Zs+p7l0eqtoVNOf/VVyMVqt1sp3r8w/WqXyWP23nplV6/HuIemWIl
	x+sunhuKkkgGzfO3ow38aIj4xqmyQ7o5/4aFOP29+uNao2yC4WJabJR0gt4pDiddIprNGaSQABW
	6tCeHYr+xFXyAcHw0uHppugE7peObt9uqd9pjcEb1vZqqYusRXHXL81+yhbGdaC5cp55JtMHU6s
	3dJPKmz3Hd8OB+COJj+8isO/dfhrgTjBEx3hXR1L3dEGWYmoklpkzCIzgTfoQ2gYJdv6eZuZXhn
	v
X-Received: by 2002:a81:4609:: with SMTP id t9mr22673516ywa.456.1548710794719;
        Mon, 28 Jan 2019 13:26:34 -0800 (PST)
X-Received: by 2002:a81:4609:: with SMTP id t9mr22673486ywa.456.1548710794223;
        Mon, 28 Jan 2019 13:26:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548710794; cv=none;
        d=google.com; s=arc-20160816;
        b=mxnrv3ZnVcoGS6KiW5waPd7SgpDTWFPMplTV+pNq+6KVHPWflvklwDNTOazLs+yNPj
         tfk3zxOVh52VKyWH325mdd/ediekP0TdzKiACicQ8SUKuO5hKUiQjfxWESWj7GPlX53s
         8Hh1Hlm01Kgke+odJtKZ4mEaQ2CULQjXftmTUzwUKiA3II2G1J/eO6/S0XW+W/jSFF41
         BMIUSAIL/Yz0+p2Gl6DxiT+5zefvGOSSfiiS2M6DNeh1v256jvG6E8tz0A+asEIzC2Ej
         pF4Axj9y6T0PmMx4u0g1ndHNS2nTUHpP9b4X4kMj1/d0GXg2DBYzws9wYtsMkv+rDvDE
         pV1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=doeprTD75a3wN3TW5uXx5DNXAT9rchfp4Kk5IuJTQxU=;
        b=iw6j3nfSNSHybadAePCfbL7i04sf4oQSxuVPtspUYWZcpv3W5YACBmfpuFBXWKmoNE
         xC8NjahtS9Mx9EHXXQKnDF2wyFTieQL88cufTaeVWhQVWZEUdzdqBRwA8BV+UnXRpLSR
         bGSCy2TntDcivuelagmD7jzhEKCXFkoZp96uz72zHy3KSmwXcyJYO7w9EVbKhuwanEm/
         ykab2yIEu4xG/BnBuUXuTCKoL968huZwlauiInNYXL0j5XkFj6RTvqueboK9MwhREHCR
         unGCP0zUOJ4m3K9ZTEqGhOkG0xGAfcafPr/NCkQL0aGy4BV9qIlt3aGq/Ib4CCCDxv0Z
         PfPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=CoGlOMn7;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o67sor4508019ywe.200.2019.01.28.13.26.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 13:26:34 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=CoGlOMn7;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=doeprTD75a3wN3TW5uXx5DNXAT9rchfp4Kk5IuJTQxU=;
        b=CoGlOMn7uIwWJDcMJfm+Rj/Qm/gD747PAjoLMDuaAsDCqLhZQSn/JpFhVuDGuDVsjF
         ZCc8zkEIpRrNHtUDlnkc1025YEepn5whj5fHLPPzwg/nGaOXJ4pD5bxCR2wI5TuxUC48
         BWSV8pZ8PCO4Myh5kKyI+tOm9WAx/oi7OMNMgHZUxJn7ycktWfXZZsol5OtiRFtjo1HM
         WCiToVrQxB7D49DqB2cfga9Imv1GfrUhMWjHVChx4ubG1zTMX4qOhNIsAbTi2dC5vikw
         xTOivor07e6gs17gDt22abifNO9qMz2FPPi8SCfL2ZFPvFyjHEY7VVO+xC22K209SvVq
         OA/g==
X-Google-Smtp-Source: ALg8bN44vJXUgSafJIwnnLviacYE7rvHH/Jn6crYS91qDV9NBrrZWH6O6kmvBO1Sv1E4zJ1C7+B4zg==
X-Received: by 2002:a81:3d3:: with SMTP id 202mr22391227ywd.18.1548710793942;
        Mon, 28 Jan 2019 13:26:33 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:42c8])
        by smtp.gmail.com with ESMTPSA id e3sm14662632ywe.63.2019.01.28.13.26.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 13:26:33 -0800 (PST)
Date: Mon, 28 Jan 2019 16:26:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com,
	mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v3 5/5] psi: introduce psi monitor
Message-ID: <20190128212632.GD1416@cmpxchg.org>
References: <20190124211518.244221-1-surenb@google.com>
 <20190124211518.244221-6-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124211518.244221-6-surenb@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

One thought on the v3 delta that I missed earlier:

On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
> +/*
> + * psi_update_work represents slowpath accounting part while psi_group_change
> + * represents hotpath part. There are two potential races between them:
> + * 1. Changes to group->polling when slowpath checks for new stall, then hotpath
> + *    records new stall and then slowpath resets group->polling flag. This leads
> + *    to the exit from the polling mode while monitored state is still changing.
> + * 2. Slowpath overwriting an immediate update scheduled from the hotpath with
> + *    a regular update further in the future and missing the immediate update.
> + * Both races are handled with a retry cycle in the slowpath:
> + *
> + *    HOTPATH:                         |    SLOWPATH:
> + *                                     |
> + * A) times[cpu] += delta              | E) delta = times[*]
> + * B) start_poll = (delta[poll_mask] &&|    if delta[poll_mask]:
> + *      cmpxchg(g->polling, 0, 1) == 0)| F)   polling_until = now + grace_period
> + *    if start_poll:                   |    if now > polling_until:
> + * C)   mod_delayed_work(1)            |      if g->polling:

With the polling flag being atomic now, this "if g->polling" line
isn't accurate anymore. Since this diagram is specifically about
memory ordering, this should move the g->polling load up to where
delta is read and then refer to unordered local variables down here.

