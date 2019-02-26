Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FAE9C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 05:47:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAC9C2147C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 05:47:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t1SDQ6RY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAC9C2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F1408E0003; Tue, 26 Feb 2019 00:47:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59FD88E0002; Tue, 26 Feb 2019 00:47:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48FE18E0003; Tue, 26 Feb 2019 00:47:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB8E8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 00:47:50 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id z14so9623645ioh.20
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 21:47:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DH6OmOhpK8WgxNk1LoNuyjA4n2qWxmN58P+jI2jwAgM=;
        b=q6PXXZDdp3RwrCN+DG/pJRxEWExgEzV+0iysuHouN235V7NdW1KH5OYW6VBKXLDW1Y
         aji7TMnoJCxoat6PEPemh05zwS+8u4tsZdcODnwOSryFwvWSPeLfE+KeIBk2w+9BZj2b
         ineNDRhknSyQ9DeQly0bAvzWmexygopJl+12uPcUXxT7aH9ksJlNeox9tlt6kfGYE6oG
         UwxououTqVVL1iulN676IvteYOUYPtXc2jpXMq1g+08b/fJk2bd6gX7jF1Cvu4CRW4zN
         fh6JEaZedcivxQeGdtSrLhIyX0wLzlnak1WFbzQ67yu/KioSLlahXPLSgMPe+MtCbPPU
         C+4g==
X-Gm-Message-State: APjAAAWJIiHuSgh3XUXGGcSFg3k4aSNe0o6hWmNPlKXoCcS+EpgDLkyu
	qeTud+Cd7uENWDigUPFLgIuhApXvY8fFKwc4ybhlzmjIsriiHOCs0QDDBtTjm+dSqiBYuRTziO1
	ZmHrHsovPrb1Sghh5HPG/bYNVcSkrDJJ4YLgsNx4mecI9s/hR5AVOilQBvLe5bQXpw+StziMzkB
	r9RsBwWkjZ8EHZpfyKRG/nfzvk67cUAc87HZAoIfYsbA1PqDwxk7VMFzF2DghJ3K6OgbNCPOrQz
	Q1sQh89sdDYf6iGW5OLjRJ3e3pIcEJJKqqIIpV3jRoIxLSE5S4PDvc9E6n+l2nON7qmdIxHHwMo
	v5ZfYoizbaN7d1n2CfB5nAPPH0ddaxv9iVroZv+3X4dAHbvHvXcVvuwD/eeYdQS1FM3BMes3Ld5
	b
X-Received: by 2002:a24:17:: with SMTP id 23mr1660397ita.158.1551160069466;
        Mon, 25 Feb 2019 21:47:49 -0800 (PST)
X-Received: by 2002:a24:17:: with SMTP id 23mr1660371ita.158.1551160068646;
        Mon, 25 Feb 2019 21:47:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551160068; cv=none;
        d=google.com; s=arc-20160816;
        b=VX4yiAqrPy/jc/EzRrgPUephbw+93134hGCnntRcj99GLvlFdt1uPaylL8G3MDSntQ
         ZcRDIEXlhnocQjS9At+8Oog7Vb8zMtVbOhZZZ2xviEb9GTEvQhZlAI/qUKxZSXkR9BZL
         EclliNf2SIWEFlTWMkG+tDHEJsEDFAV6dhbC/W4AqFISlijMUGVgjbClKGWpv9QKcV2u
         +VRajX4/cWP+pPfb1xC3QW7PDdXS918bXhQb3FGfisab07uaSVpUdIVE5P4BGGqp/HSw
         jYhc3W4sVwQqYLDmwxPJyspf96yhvg3gLInpTmoM+reE33OyBxCU8KNbaYNCZtaSxoy9
         mN9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DH6OmOhpK8WgxNk1LoNuyjA4n2qWxmN58P+jI2jwAgM=;
        b=0xDSFZaDFPQj65nobmCmR7y+ewOA6LnmrqCD2QUbpQSlrooV4VELpIaczo4Qy4KxR1
         htjKBfckj4Fh5mWbP2IGoE+ntVgzO8lG4J1/LKaZgj1j7LL+25URCuSWKkQ5oWZlpW5+
         mbBHbbxxjIoZ8xewXbat7Xv33KXwjSGtspoYhbzfIFdy3nQIdABwIQwpK9nbRScoe20+
         TvqubQqj6CeSt2vIBK4DMtaBT6zUQCTQwJiCJy8ijHx1nA8fpfHiRVVxnD8mw/5ZxOMx
         1u+2GCuwLO8XIh/x4+n4hcYpnfwiXucYEmbSSkQjKEn0O1coJOEqXMGqoqgOoMPZiNjP
         ohww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t1SDQ6RY;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m200sor4419238itm.33.2019.02.25.21.47.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 21:47:48 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t1SDQ6RY;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DH6OmOhpK8WgxNk1LoNuyjA4n2qWxmN58P+jI2jwAgM=;
        b=t1SDQ6RY9H+7oBQfzulejsUdCOh5LzYK3hfMJ1duuFr1BYKc5iwKxllIUrfA7ww+4A
         1/qlOvRqvfxXlzDtDs98stby4xlGTpRSqX8n0TRi70vbkbuC+EHZkBBl5TwOFIYMoHnt
         FOk2hX0BbDozu3Ph/9ZlruXfUzLbTsNQ0KLEDdYW7CzIoIMuM66JbJm4T7fPIpDSBpAe
         mvJsSE4nZ+KHhTqOmVh+12wT62T/pVxsO32D4ek9VC3Ixn68HFoMKcJPiVCxAZiOsZvP
         9/g3DqBDoxOe9qiGlnXt7UvbtFE5XRBDzGAOhMUMwgAoGnuiihD2giMbHxFO5P5sfR0e
         kxTg==
X-Google-Smtp-Source: AHgI3IaOM6lhYu7Ut6XAju3LJS/9hGEbwXMQiyJSieRYahzFibEcaiYEEWRQF4PHCaHRe49ZNLYnKpoIhwYdq7FjZS4=
X-Received: by 2002:a24:4650:: with SMTP id j77mr1506587itb.6.1551160068374;
 Mon, 25 Feb 2019 21:47:48 -0800 (PST)
MIME-Version: 1.0
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com> <20190225160358.GW10588@dhcp22.suse.cz>
In-Reply-To: <20190225160358.GW10588@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 26 Feb 2019 13:47:37 +0800
Message-ID: <CAFgQCTuD9MMdXRjyu1w5s3QSupWWtdcCOR6LhdSEP=1xGONWjQ@mail.gmail.com>
Subject: Re: [PATCH 0/6] make memblock allocator utilize the node's fallback info
To: Michal Hocko <mhocko@kernel.org>
Cc: x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andy Lutomirski <luto@kernel.org>, Andi Kleen <ak@linux.intel.com>, Petr Tesarik <ptesarik@suse.cz>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Jonathan Corbet <corbet@lwn.net>, 
	Nicholas Piggin <npiggin@gmail.com>, Daniel Vacek <neelx@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 12:04 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sun 24-02-19 20:34:03, Pingfan Liu wrote:
> > There are NUMA machines with memory-less node. At present page allocator builds the
> > full fallback info by build_zonelists(). But memblock allocator does not utilize
> > this info. And for memory-less node, memblock allocator just falls back "node 0",
> > without utilizing the nearest node. Unfortunately, the percpu section is allocated
> > by memblock, which is accessed frequently after bootup.
> >
> > This series aims to improve the performance of per cpu section on memory-less node
> > by feeding node's fallback info to memblock allocator on x86, like we do for page
> > allocator. On other archs, it requires independent effort to setup node to cpumask
> > map ahead.
>
> Do you have any numbers to tell us how much does this improve the
> situation?

Not yet. At present just based on the fact that we prefer to allocate
per cpu area on local node.

Thanks,
Pingfan

