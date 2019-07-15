Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A758C73C66
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 03:06:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A0D020868
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 03:06:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A0D020868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E3476B0007; Sun, 14 Jul 2019 23:06:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96C476B0008; Sun, 14 Jul 2019 23:06:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E6716B000A; Sun, 14 Jul 2019 23:06:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 431A36B0007
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 23:06:46 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a21so9787314pgh.11
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 20:06:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=EjusoFySDJ4oOrd0QsyomBUcAt2tgctPtdTv2+1Q2o4=;
        b=Kw2Y51dr/XQnku+91r5XjwMzx/0i68Tae/OKS5iHaKlEfmZv/VVQ2Z4d8wLTZqHHgl
         Vr+0KTRcmS0d9R5Oy/Pss7r4r4ulwGoqCZ5wX/A4yelLns7RCwRaWDkgTFWCxoy9LxFq
         sNqfU2V5ujiwjRkv3hUuwMXSRIOKQJocyNGnNdZsRhgcp15J/u25Q6gbuC+oPbMtGEL5
         clp7Jssms7iscf1qKg3DpNnKin8ai7dMrn7bh0+5RtbfC5Z0EFh5RPv1Lrsygh2v+osz
         H0oBCkbMD44C3SeOOwbbJROhghf+74SmngctskgB1p91ixwwf4tW0/ISlWPno/92LxRA
         yP8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAUmZ0AnLE29odmx1Wsbks/WvJdJ4OpgAujiV/3AwzGXCS/a73ko
	2DG3X7VSoZiHnQ8iLNVxpwAFaZeF3H0oWhqlmByKMEZtEKhD7L88nPn5Yl0FjFB+6s6/LuHzaoR
	tfPj5ZTQ/D7Oj1DpAqo4fcmlg4tAQsyZLbgALhvoufOTlyiDmfYm3yundGbudz0feZg==
X-Received: by 2002:a17:90a:cb8e:: with SMTP id a14mr26265060pju.124.1563160005925;
        Sun, 14 Jul 2019 20:06:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqQ59j428p6GW7tbiM59oje2fW5oIyvTsczFZQKDmWrb6/nXhTqhaKrag34ZeFrjH+GNWm
X-Received: by 2002:a17:90a:cb8e:: with SMTP id a14mr26265012pju.124.1563160005003;
        Sun, 14 Jul 2019 20:06:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563160004; cv=none;
        d=google.com; s=arc-20160816;
        b=GUtx3ExZFyslOFL+q15I/EZXtaAGsx4d1eBy0qtg45a3iarS2K0BKBjiG0X+YHAwOl
         i/xIDUwSchvpYp++JjxIeR7ZH78+HWHs5ytWndfOb0Pi1j7uXJJ8JFYY6OM8buFh+41I
         VSpqeeeZgaktGLVIaRcfRJukOO9JcOtu8TitZJ+cs8o8rqNj8ATNg0oYcKN7+1Js6Iqj
         fc58UBjTQwgX9XMZQn588P60hhcttQwnaHO0KMs1XLQ+MfG3Lb80VOgmEEvx4KkiW9x3
         LxYWGgDnk+ZWWYgoDPluKPyRr21dteWuMdomMIXU4KDrlDb75Kbm2l9xv7gQCSViEheR
         bMTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=EjusoFySDJ4oOrd0QsyomBUcAt2tgctPtdTv2+1Q2o4=;
        b=HqgkhYfca4Z1bIuYnsS8R3fGapbyclbWW4xu7TxIIYtgiAgaK95zqwF9mI/BMQSYvI
         4+4qc9ZaEXckwOl25Xy3dzoxPn1fOUd8PcWFH/d+2Zpu6SNI2HV6q5ufnyRKvUIxi0VL
         s3iKmo7wikIo/nrYc9WOzfo20g8+YE7akbjb+4auXHvFyqsZYiBsGYs3Q2Oc1utDs5Ea
         LGq1Du7GXESec1kUu8LJSJA/O7ayb3yOqB88dPAvQxlTezJu+gd9Vof5yJhPBlZSgSsI
         JI645cxOrI1EN9etRrG1QFuWG4wf6PFXE45vOMomEwWla/59r2vq6xDZf8YwmKHJF3k6
         IV7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id d12si13867392plo.68.2019.07.14.20.06.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 20:06:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: d5814ede6d58453e95a0b6c0fcd31521-20190715
X-UUID: d5814ede6d58453e95a0b6c0fcd31521-20190715
Received: from mtkexhb01.mediatek.inc [(172.21.101.102)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1205297470; Mon, 15 Jul 2019 11:06:42 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Mon, 15 Jul 2019 11:06:41 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Mon, 15 Jul 2019 11:06:40 +0800
Message-ID: <1563160001.4793.4.camel@mtksdccf07>
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
Date: Mon, 15 Jul 2019 11:06:41 +0800
In-Reply-To: <37897fb7-88c1-859a-dfcc-0a5e89a642e0@virtuozzo.com>
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
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-07-12 at 13:52 +0300, Andrey Ryabinin wrote:
> 
> On 7/11/19 1:06 PM, Walter Wu wrote:
> > On Wed, 2019-07-10 at 21:24 +0300, Andrey Ryabinin wrote:
> >>
> >> On 7/9/19 5:53 AM, Walter Wu wrote:
> >>> On Mon, 2019-07-08 at 19:33 +0300, Andrey Ryabinin wrote:
> >>>>
> >>>> On 7/5/19 4:34 PM, Dmitry Vyukov wrote:
> >>>>> On Mon, Jul 1, 2019 at 11:56 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> >>
> >>>>>
> >>>>> Sorry for delays. I am overwhelm by some urgent work. I afraid to
> >>>>> promise any dates because the next week I am on a conference, then
> >>>>> again a backlog and an intern starting...
> >>>>>
> >>>>> Andrey, do you still have concerns re this patch? This change allows
> >>>>> to print the free stack.
> >>>>
> >>>> I 'm not sure that quarantine is a best way to do that. Quarantine is made to delay freeing, but we don't that here.
> >>>> If we want to remember more free stacks wouldn't be easier simply to remember more stacks in object itself?
> >>>> Same for previously used tags for better use-after-free identification.
> >>>>
> >>>
> >>> Hi Andrey,
> >>>
> >>> We ever tried to use object itself to determine use-after-free
> >>> identification, but tag-based KASAN immediately released the pointer
> >>> after call kfree(), the original object will be used by another
> >>> pointer, if we use object itself to determine use-after-free issue, then
> >>> it has many false negative cases. so we create a lite quarantine(ring
> >>> buffers) to record recent free stacks in order to avoid those false
> >>> negative situations.
> >>
> >> I'm telling that *more* than one free stack and also tags per object can be stored.
> >> If object reused we would still have information about n-last usages of the object.
> >> It seems like much easier and more efficient solution than patch you proposing.
> >>
> > To make the object reused, we must ensure that no other pointers uses it
> > after kfree() release the pointer.
> > Scenario:
> > 1). The object reused information is valid when no another pointer uses
> > it.
> > 2). The object reused information is invalid when another pointer uses
> > it.
> > Do you mean that the object reused is scenario 1) ?
> > If yes, maybe we can change the calling quarantine_put() location. It
> > will be fully use that quarantine, but at scenario 2) it looks like to
> > need this patch.
> > If no, maybe i miss your meaning, would you tell me how to use invalid
> > object information? or?
> > 
> 
> 
> KASAN keeps information about object with the object, right after payload in the kasan_alloc_meta struct.
> This information is always valid as long as slab page allocated. Currently it keeps only one last free stacktrace.
> It could be extended to record more free stacktraces and also record previously used tags which will allow you
> to identify use-after-free and extract right free stacktrace.

Thanks for your explanation.

For extend slub object, if one record is 9B (sizeof(u8)+ sizeof(struct
kasan_track)) and add five records into slub object, every slub object
may add 45B usage after the system runs longer. 
Slub object number is easy more than 1,000,000(maybe it may be more
bigger), then the extending object memory usage should be 45MB, and
unfortunately it is no limit. The memory usage is more bigger than our
patch.

We hope tag-based KASAN advantage is smaller memory usage. If it’s
possible, we should spend less memory in order to identify
use-after-free. Would you accept our patch after fine tune it?

