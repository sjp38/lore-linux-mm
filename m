Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42FA0C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:56:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAE3020881
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:56:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAE3020881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 867936B0006; Mon,  1 Jul 2019 05:56:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8165C8E0003; Mon,  1 Jul 2019 05:56:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 705BE8E0002; Mon,  1 Jul 2019 05:56:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f208.google.com (mail-pg1-f208.google.com [209.85.215.208])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1F46B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 05:56:43 -0400 (EDT)
Received: by mail-pg1-f208.google.com with SMTP id b10so7327357pgb.22
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 02:56:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=QB5uWgD3NO3VbFr/pONkbxLISPnIjp30M+44zmcUrV0=;
        b=qMjGcDRiUY02ew/eZV18iyzas86/5nqi4SX02yFWYJpDddt/B5GcCbW+lTKlmV3DaD
         WfKs7HEzWXKQkIhLNpSQBuZSZWc/UZp7WR66iNruZkSKJo4B02DkHWCrous5Jd1QmvlH
         02DtL891iQIivIZy5uAsnAcg9S9mA/ozVBqu7zU9ewQ7aY3BX1tLmTtmMf4fG9X2WwNe
         hhSm1NNwhIKRrOcxLUEmNny666COZCisTfRxK7oB7SCHnPhEAdbXzVKWUPlTG2NpEGdi
         n51vo4Hy9d3MvvD5nkL8vTiVEFBOqnQavs1EhDP46SOlYCjSt/UvIA0oBvmb3B6Z6hJd
         VgEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAW88KuSbcc06snP9I7ZDyjT/HhGlA3kjUyadYTFYtsM+RWck7Kk
	3zfstMt0lDbgyPGksZ6CQvYw4HV43GisiRtG3wJIszePi8JQn/iirUHpXbzLBv9lRhRvRjTXxg7
	5hSWSQEpanDuTWPqvUUp7ZhvwS3EFbufgmveDDKRj7BQljr0knd5guFe24OCKjA4+rw==
X-Received: by 2002:a17:90a:24ac:: with SMTP id i41mr29947591pje.124.1561975002727;
        Mon, 01 Jul 2019 02:56:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhn/EtPyqU+Om5P624wd30GcI0/DLAo/girogO7j7BT1I9UODe10S15faEiaW7QFNBLC56
X-Received: by 2002:a17:90a:24ac:: with SMTP id i41mr29947481pje.124.1561975001401;
        Mon, 01 Jul 2019 02:56:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561975001; cv=none;
        d=google.com; s=arc-20160816;
        b=w1ddVjfr0KthUlxhcr9GENSNWurQSYCWmkZIBD9LBoWtbobEYe+rFLQAAHQO1ir1KD
         MogpCUtLD2aucEFWMy0z649jAr+N8pjX71JtN7Wni03ZrIMnloa1iipWzqrHY/9vjkjP
         oRjMVdMB+IDG4Ya5pUPbuI1Ix6woeNThVJYLoIZmoWzQRukF/GR8GTLAr6ejiJeRf0db
         sP4tLvSAB/3SMUKIBQ4OPGM6NBn5wPrOBSc8XLo38r4M4/gCK0ZnV/2jcbTAyONhhcyT
         KehZWR9h9s9yzmXAy16a3iP7L7Ud6JVZ14ThIinfI7vtJCoKHnYlTOmBRMuVSucHMQb7
         4qlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=QB5uWgD3NO3VbFr/pONkbxLISPnIjp30M+44zmcUrV0=;
        b=xwHKKiJyFW+nDnxCZXH86o8iKf/t4OrGSKxeuVFRXVqN4VJeuuJ2fXBDGVXYPtqm0w
         tUWgDlt8mxWTzeOqcC+888WOca47F2a1qqTKwlfJTY0S5yg7oPrgUf18Sy+pmZ/h6vDC
         7FyhlT3Px8+qDFtoY+dbLkpcDmw0BV3zmQS9VNfizEJHsJ97gb9mdypYZz/4qDtLU40g
         GraTuWOZn+GIdhepm9t/HXV06Jlswutx240V4qFvumS1p70fTe7g1g028m3mZBfzKaE6
         SaWkBGzEMZ2hgnvCQxQyRW8Gcvs8xZaa8MO50nsiRNyVj1f9FDY1lyF++fkK2cEx1cPM
         FyYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id d13si9584516pgl.545.2019.07.01.02.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 02:56:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: 73d37207a7e94239abcbabbd212a7df5-20190701
X-UUID: 73d37207a7e94239abcbabbd212a7df5-20190701
Received: from mtkcas09.mediatek.inc [(172.21.101.178)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1208537169; Mon, 01 Jul 2019 17:56:37 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Mon, 1 Jul 2019 17:56:36 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Mon, 1 Jul 2019 17:56:35 +0800
Message-ID: <1561974995.18866.1.camel@mtksdccf07>
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Dmitry Vyukov <dvyukov@google.com>
CC: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
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
Date: Mon, 1 Jul 2019 17:56:35 +0800
In-Reply-To: <1560774735.15814.54.camel@mtksdccf07>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
	 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
	 <1560447999.15814.15.camel@mtksdccf07>
	 <1560479520.15814.34.camel@mtksdccf07>
	 <1560744017.15814.49.camel@mtksdccf07>
	 <CACT4Y+Y3uS59rXf92ByQuFK_G4v0H8NNnCY1tCbr4V+PaZF3ag@mail.gmail.com>
	 <1560774735.15814.54.camel@mtksdccf07>
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

On Mon, 2019-06-17 at 20:32 +0800, Walter Wu wrote:
> On Mon, 2019-06-17 at 13:57 +0200, Dmitry Vyukov wrote:
> > On Mon, Jun 17, 2019 at 6:00 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> > >
> > > On Fri, 2019-06-14 at 10:32 +0800, Walter Wu wrote:
> > > > On Fri, 2019-06-14 at 01:46 +0800, Walter Wu wrote:
> > > > > On Thu, 2019-06-13 at 15:27 +0300, Andrey Ryabinin wrote:
> > > > > >
> > > > > > On 6/13/19 11:13 AM, Walter Wu wrote:
> > > > > > > This patch adds memory corruption identification at bug report for
> > > > > > > software tag-based mode, the report show whether it is "use-after-free"
> > > > > > > or "out-of-bound" error instead of "invalid-access" error.This will make
> > > > > > > it easier for programmers to see the memory corruption problem.
> > > > > > >
> > > > > > > Now we extend the quarantine to support both generic and tag-based kasan.
> > > > > > > For tag-based kasan, the quarantine stores only freed object information
> > > > > > > to check if an object is freed recently. When tag-based kasan reports an
> > > > > > > error, we can check if the tagged addr is in the quarantine and make a
> > > > > > > good guess if the object is more like "use-after-free" or "out-of-bound".
> > > > > > >
> > > > > >
> > > > > >
> > > > > > We already have all the information and don't need the quarantine to make such guess.
> > > > > > Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
> > > > > > otherwise it's use-after-free.
> > > > > >
> > > > > > In pseudo-code it's something like this:
> > > > > >
> > > > > > u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));
> > > > > >
> > > > > > if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
> > > > > >   // out-of-bounds
> > > > > > else
> > > > > >   // use-after-free
> > > > >
> > > > > Thanks your explanation.
> > > > > I see, we can use it to decide corruption type.
> > > > > But some use-after-free issues, it may not have accurate free-backtrace.
> > > > > Unfortunately in that situation, free-backtrace is the most important.
> > > > > please see below example
> > > > >
> > > > > In generic KASAN, it gets accurate free-backrace(ptr1).
> > > > > In tag-based KASAN, it gets wrong free-backtrace(ptr2). It will make
> > > > > programmer misjudge, so they may not believe tag-based KASAN.
> > > > > So We provide this patch, we hope tag-based KASAN bug report is the same
> > > > > accurate with generic KASAN.
> > > > >
> > > > > ---
> > > > >     ptr1 = kmalloc(size, GFP_KERNEL);
> > > > >     ptr1_free(ptr1);
> > > > >
> > > > >     ptr2 = kmalloc(size, GFP_KERNEL);
> > > > >     ptr2_free(ptr2);
> > > > >
> > > > >     ptr1[size] = 'x';  //corruption here
> > > > >
> > > > >
> > > > > static noinline void ptr1_free(char* ptr)
> > > > > {
> > > > >     kfree(ptr);
> > > > > }
> > > > > static noinline void ptr2_free(char* ptr)
> > > > > {
> > > > >     kfree(ptr);
> > > > > }
> > > > > ---
> > > > >
> > > > We think of another question about deciding by that shadow of the first
> > > > byte.
> > > > In tag-based KASAN, it is immediately released after calling kfree(), so
> > > > the slub is easy to be used by another pointer, then it will change
> > > > shadow memory to the tag of new pointer, it will not be the
> > > > KASAN_TAG_INVALID, so there are many false negative cases, especially in
> > > > small size allocation.
> > > >
> > > > Our patch is to solve those problems. so please consider it, thanks.
> > > >
> > > Hi, Andrey and Dmitry,
> > >
> > > I am sorry to bother you.
> > > Would you tell me what you think about this patch?
> > > We want to use tag-based KASAN, so we hope its bug report is clear and
> > > correct as generic KASAN.
> > >
> > > Thanks your review.
> > > Walter
> > 
> > Hi Walter,
> > 
> > I will probably be busy till the next week. Sorry for delays.
> 
> It's ok. Thanks your kindly help.
> I hope I can contribute to tag-based KASAN. It is a very important tool
> for us.

Hi, Dmitry,

Would you have free time to discuss this patch together?
Thanks.

Walter

