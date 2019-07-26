Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8A15C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:20:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67C34218D4
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:20:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67C34218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04BA86B0003; Fri, 26 Jul 2019 09:20:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3F1F6B0005; Fri, 26 Jul 2019 09:20:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2F0A8E0002; Fri, 26 Jul 2019 09:20:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE1426B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:20:30 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 21so33181345pfu.9
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:20:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=Dk4vQtmJTJwidyR9ji2Z1X/x/ODb/8xrAJ4pYnp3tso=;
        b=Y/d2tdAU8HKuTvob59bYqHQw18UYJiV15i9cXCfZWY4sTDaz4QRnwuleoGp8N1pEsH
         KY7R54BfHQVz6f2sby0xzMbrNpx6ltvwi9JUFdWuNGt1yHLHvZvkNKJT4ZEdm+7DNT8u
         dCjmAcpA49zSBdZr0AdVvauoduwXYbfQMm5TcOB05z/+EPsE5wotWMQMjuKqnzPXaRBB
         dzWTBs3Qte5sed49osZuTxoO1g7UBU0g5UKk0IKAZobi4Z5vaOjKg751HpTqqltaCfPP
         26ObeYTrahCaWmgt6Jg1d+/0cntSyVBcI6tmDeBveaWhD6GzbrIXWwHZHhLJ8smhb/1w
         f0vQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAWvYFXvy63U2xmBa22+4captYH6CwjR2uds8VHCq3l3nEGIrSlt
	ufqYvEZNz3MfrHhyBAtbe88fIklFnRdvDf34oJzrSxt/5OjTXnBxWQVdJtfHW94RR6JT96Ll7bk
	x1yqvz1YItRtIhyB+vhKATwKmP0AArvocXKjH4G5HhxE2ACjeStuRXZu65ihtQ0IweA==
X-Received: by 2002:a65:62d7:: with SMTP id m23mr91403781pgv.358.1564147230281;
        Fri, 26 Jul 2019 06:20:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbe84z47LX51SpUtjmFj9ucksOzaRd2Z6jHKoND/RF931ccse2+qbB91M5mCvW0EFmVvVv
X-Received: by 2002:a65:62d7:: with SMTP id m23mr91400787pgv.358.1564147190112;
        Fri, 26 Jul 2019 06:19:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564147190; cv=none;
        d=google.com; s=arc-20160816;
        b=B5fGukKeCfzRpdEO1wNhz6LyXgWBUtkCKGs/nIbPjwFWWWeMz8rF0+hwr+LZSQ0q4J
         QjGwV0RNFFGiH3NC2z0nxbBkAHRGmnKgNYfOkKm1ALSETNR2auNMxKqZ9A7kjYF0wwWH
         AgVOHlkmivWUNzEyxJjEerXUHuEPdbbXqMSMnUJ3FRLAQvwmlkpGuAYY9Dh8q1eJHQoG
         3YqJKn5iSzMawbJ/mbrlEVaFfPhyUJBLqB/tXnRD3j58snU2D/aaCOZbrdbn6xONuS0I
         /AQkWS7cn+nV4VNSDT/oM75GnFOAZ7Gx7ZWTmVYrbHEeSS4IJAegcoCGyj9XnB7XhTiZ
         UK3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=Dk4vQtmJTJwidyR9ji2Z1X/x/ODb/8xrAJ4pYnp3tso=;
        b=Uv6hQZ6x8p65RS9kCFS8ePCPlT6/9GglMBptBG1jBpACZ+M9cNAMAbr+z4oKwZJokS
         xLQiKiH8PHG83KzGwpoGMwmXfmi1KFna4Udqd9VsWf6/LqA6yWd8saXH7TzDnkyK3uL6
         Np/bCSbKWap6ZxkqiOozbwyakNi1X0fXw8FvSGApy607cgk7Mjc+7Teht/ssGHthS8ay
         SyxhC0Ux2xBTPInw07FgDJBOWa/9lsKTCUO+nXH0lbFpjMdIs94ux/Ci+sWZMq/hX1Fz
         ZYMyJtcJFTNiaP4aAn788BNdmm0QQqCCMpWKTHqlhJaLxiMyel3XCAx+Z/Z/wfDbvD7J
         ROow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTP id v71si20302371pgd.468.2019.07.26.06.19.27
        for <linux-mm@kvack.org>;
        Fri, 26 Jul 2019 06:19:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: 0811d90d0f9943609049e07c27e9d03e-20190726
X-UUID: 0811d90d0f9943609049e07c27e9d03e-20190726
Received: from mtkmrs01.mediatek.inc [(172.21.131.159)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 1211687384; Fri, 26 Jul 2019 21:19:23 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs06n1.mediatek.inc (172.21.101.129) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Fri, 26 Jul 2019 21:19:24 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Fri, 26 Jul 2019 21:19:24 +0800
Message-ID: <1564147164.515.10.camel@mtksdccf07>
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
CC: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko
	<glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Vasily
 Gorbik" <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, "Jason
 A . Donenfeld" <Jason@zx2c4.com>, Miles Chen <miles.chen@mediatek.com>,
	kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, Linux ARM
	<linux-arm-kernel@lists.infradead.org>, <linux-mediatek@lists.infradead.org>,
	wsd_upstream <wsd_upstream@mediatek.com>
Date: Fri, 26 Jul 2019 21:19:24 +0800
In-Reply-To: <71df2bd5-7bc8-2c82-ee31-3f68c3b6296d@virtuozzo.com>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
	 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
	 <1560447999.15814.15.camel@mtksdccf07>
	 <1560479520.15814.34.camel@mtksdccf07>
	 <1560744017.15814.49.camel@mtksdccf07>
	 <CACT4Y+Y3uS59rXf92ByQuFK_G4v0H8NNnCY1tCbr4V+PaZF3ag@mail.gmail.com>
	 <1560774735.15814.54.camel@mtksdccf07>
	 <1561974995.18866.1.camel@mtksdccf07>
	 <CACT4Y+aMXTBE0uVkeZz+MuPx3X1nESSBncgkScWvAkciAxP1RA@mail.gmail.com>
	 <ebc99ee1-716b-0b18-66ab-4e93de02ce50@virtuozzo.com>
	 <1562640832.9077.32.camel@mtksdccf07>
	 <d9fd1d5b-9516-b9b9-0670-a1885e79f278@virtuozzo.com>
	 <1562839579.5846.12.camel@mtksdccf07>
	 <37897fb7-88c1-859a-dfcc-0a5e89a642e0@virtuozzo.com>
	 <1563160001.4793.4.camel@mtksdccf07>
	 <9ab1871a-2605-ab34-3fd3-4b44a0e17ab7@virtuozzo.com>
	 <1563789162.31223.3.camel@mtksdccf07>
	 <e62da62a-2a63-3a1c-faeb-9c5561a5170c@virtuozzo.com>
	 <1564144097.515.3.camel@mtksdccf07>
	 <71df2bd5-7bc8-2c82-ee31-3f68c3b6296d@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-07-26 at 15:52 +0300, Andrey Ryabinin wrote:
> 
> On 7/26/19 3:28 PM, Walter Wu wrote:
> > On Fri, 2019-07-26 at 15:00 +0300, Andrey Ryabinin wrote:
> >>
> >
> >>>
> >>>
> >>> I remember that there are already the lists which you concern. Maybe we
> >>> can try to solve those problems one by one.
> >>>
> >>> 1. deadlock issue? cause by kmalloc() after kfree()?
> >>
> >> smp_call_on_cpu()
> > 
> >>> 2. decrease allocation fail, to modify GFP_NOWAIT flag to GFP_KERNEL?
> >>
> >> No, this is not gonna work. Ideally we shouldn't have any allocations there.
> >> It's not reliable and it hurts performance.
> >>
> > I dont know this meaning, we need create a qobject and put into
> > quarantine, so may need to call kmem_cache_alloc(), would you agree this
> > action?
> > 
> 
> How is this any different from what you have now?

I originally thought you already agreed the free-list(tag-based
quarantine) after fix those issue. If no allocation there, i think maybe
only move generic quarantine into tag-based kasan, but its memory
consumption is more bigger our patch. what do you think?

