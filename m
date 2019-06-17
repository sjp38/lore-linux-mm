Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BAA5C31E59
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:32:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5174620657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:32:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5174620657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02B638E0005; Mon, 17 Jun 2019 08:32:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0029E8E0004; Mon, 17 Jun 2019 08:32:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E32DA8E0005; Mon, 17 Jun 2019 08:32:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABCC78E0004
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:32:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h15so6985631pfn.3
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:32:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=VvSYcK6eQX6u/sd5ArJc1SHarZ4lDgJFax/GOUSk0hY=;
        b=OLufYlAGMvtBxSrOKcRZu2M1YgHU3EDhLXU2m5Vk+yVEEVmCvtcqIjheNzo1NEtTlZ
         5McgzlI1xjAMmYNsRBoe0kmMG5N1hJ4uGvVGq5XqKSlNNWbJDO7KLhB6z7GNBDslJvG5
         upi9xFQ4kVd3t7JiFGXr3ggULZB3y1o7lBNa9Jx4Dy39Xba/SbJi0U3WHlu0E07/kSGB
         nks9KrHeaRhcfkSEBeo3e1ZeU9WNkcZrBT1FydpPZ05egJQpb70TUexPYj1lr8S9I7C3
         ZAFWix8ia4sGifGvWZjMe8DpXKEumQXrfG7liZdzUPLID/yih/UsIbHZtLmADD5DERu3
         kILQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAW0lNL26Q3yoPXarPTWUYRqHPj3LfFymJiHzpPwa3kpBFDRHd8Q
	rwLQ3MnFw/Lkm4wildQ4oAhCh1jLDBTbiHS3bENJ9flWwEUXp+4UvGkatdrGYtJfjgYIiqlaQJi
	fUbaJa89NF1oEnvdFGz2VBCK1vVRhL9PHj/HC04bgs8vfsAyp4GkWDlnQReI9WxdCdg==
X-Received: by 2002:a17:902:868b:: with SMTP id g11mr104332156plo.183.1560774741303;
        Mon, 17 Jun 2019 05:32:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVrNJ2Y6IxSNG4ELmuSpqnZK4e7dRq7hFYWRIpo/AJ0/JHUoPtM/MLGtx8ij3hxrwXwvzT
X-Received: by 2002:a17:902:868b:: with SMTP id g11mr104332087plo.183.1560774740459;
        Mon, 17 Jun 2019 05:32:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774740; cv=none;
        d=google.com; s=arc-20160816;
        b=PUi8kWtcrtcB9f3NpmguM/ZLW5QgdNwdrhNigeV1zMeuF+xu8tc3NnKfs//Z06A+Az
         zDlOKFsJlzsC3x8h2Mvz5Y3lFX1uTC3mfuEyQgmcIRjHqicRbwPE4iaN13IAaftkewYM
         eruzPSRNdRFzH4UxAbMRPnk5QhBd+6YSDG5GOmh4rpJ5zYB9WBeDu4txpO8L80UWd4UV
         ZC3iK/eppOIRkWFGP2TCV+XLg2Yu1L3BW90Su6aOvSw+fzQhmUzYbJZA1UfcOeRMA/dh
         P089XzWwZnchcIOeF6m3rAWEgmL7wtH42I7+A5WVCK3PDTaPcPk5x4ksM9y25zdiZxts
         gdRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=VvSYcK6eQX6u/sd5ArJc1SHarZ4lDgJFax/GOUSk0hY=;
        b=XvrA6+aqQEZkdMg+1HH+9ESA3iaDTPZ8z6Dau34rmyGzYkoYSmjJ0k2kh2FaWT4R5s
         pfpEwQLdPYjDjwFMfJkFOVC1ZaGJ9hZ61sEZga2/BH6IIzKF1B4w2okxSHqBPbgMIDVH
         Zn3OLBjqNhqhHfPplOEytafQCLotVJbWT65x6MHxZ8sFpeN3jb+SL4FZAHowxLHNLyeG
         G9/F3RhIGBtb0SG+gKtZHpirFemX66rbgp4mFQUAqrmATHeScplB/Jd2C/xA0f6lREGN
         LvemsEkBykhKLJHpHgw1Eky1N01OHOl9D9ruO/4hP5fwaPTNyQtpsG3h46JvtPnSRsgZ
         oJIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id e11si10205509plb.407.2019.06.17.05.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 05:32:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: f6edc7ac94bd449186c8b83a503b53db-20190617
X-UUID: f6edc7ac94bd449186c8b83a503b53db-20190617
Received: from mtkcas09.mediatek.inc [(172.21.101.178)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 904270075; Mon, 17 Jun 2019 20:32:16 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs08n2.mediatek.inc (172.21.101.56) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Mon, 17 Jun 2019 20:32:14 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Mon, 17 Jun 2019 20:32:14 +0800
Message-ID: <1560774735.15814.54.camel@mtksdccf07>
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
Date: Mon, 17 Jun 2019 20:32:15 +0800
In-Reply-To: <CACT4Y+Y3uS59rXf92ByQuFK_G4v0H8NNnCY1tCbr4V+PaZF3ag@mail.gmail.com>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
	 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
	 <1560447999.15814.15.camel@mtksdccf07>
	 <1560479520.15814.34.camel@mtksdccf07>
	 <1560744017.15814.49.camel@mtksdccf07>
	 <CACT4Y+Y3uS59rXf92ByQuFK_G4v0H8NNnCY1tCbr4V+PaZF3ag@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-TM-SNTS-SMTP:
	792F3DD2252100ED132A309A0254155715B3B58D81E671EBE2156836FF5FF2582000:8
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-17 at 13:57 +0200, Dmitry Vyukov wrote:
> On Mon, Jun 17, 2019 at 6:00 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> >
> > On Fri, 2019-06-14 at 10:32 +0800, Walter Wu wrote:
> > > On Fri, 2019-06-14 at 01:46 +0800, Walter Wu wrote:
> > > > On Thu, 2019-06-13 at 15:27 +0300, Andrey Ryabinin wrote:
> > > > >
> > > > > On 6/13/19 11:13 AM, Walter Wu wrote:
> > > > > > This patch adds memory corruption identification at bug report for
> > > > > > software tag-based mode, the report show whether it is "use-after-free"
> > > > > > or "out-of-bound" error instead of "invalid-access" error.This will make
> > > > > > it easier for programmers to see the memory corruption problem.
> > > > > >
> > > > > > Now we extend the quarantine to support both generic and tag-based kasan.
> > > > > > For tag-based kasan, the quarantine stores only freed object information
> > > > > > to check if an object is freed recently. When tag-based kasan reports an
> > > > > > error, we can check if the tagged addr is in the quarantine and make a
> > > > > > good guess if the object is more like "use-after-free" or "out-of-bound".
> > > > > >
> > > > >
> > > > >
> > > > > We already have all the information and don't need the quarantine to make such guess.
> > > > > Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
> > > > > otherwise it's use-after-free.
> > > > >
> > > > > In pseudo-code it's something like this:
> > > > >
> > > > > u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));
> > > > >
> > > > > if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
> > > > >   // out-of-bounds
> > > > > else
> > > > >   // use-after-free
> > > >
> > > > Thanks your explanation.
> > > > I see, we can use it to decide corruption type.
> > > > But some use-after-free issues, it may not have accurate free-backtrace.
> > > > Unfortunately in that situation, free-backtrace is the most important.
> > > > please see below example
> > > >
> > > > In generic KASAN, it gets accurate free-backrace(ptr1).
> > > > In tag-based KASAN, it gets wrong free-backtrace(ptr2). It will make
> > > > programmer misjudge, so they may not believe tag-based KASAN.
> > > > So We provide this patch, we hope tag-based KASAN bug report is the same
> > > > accurate with generic KASAN.
> > > >
> > > > ---
> > > >     ptr1 = kmalloc(size, GFP_KERNEL);
> > > >     ptr1_free(ptr1);
> > > >
> > > >     ptr2 = kmalloc(size, GFP_KERNEL);
> > > >     ptr2_free(ptr2);
> > > >
> > > >     ptr1[size] = 'x';  //corruption here
> > > >
> > > >
> > > > static noinline void ptr1_free(char* ptr)
> > > > {
> > > >     kfree(ptr);
> > > > }
> > > > static noinline void ptr2_free(char* ptr)
> > > > {
> > > >     kfree(ptr);
> > > > }
> > > > ---
> > > >
> > > We think of another question about deciding by that shadow of the first
> > > byte.
> > > In tag-based KASAN, it is immediately released after calling kfree(), so
> > > the slub is easy to be used by another pointer, then it will change
> > > shadow memory to the tag of new pointer, it will not be the
> > > KASAN_TAG_INVALID, so there are many false negative cases, especially in
> > > small size allocation.
> > >
> > > Our patch is to solve those problems. so please consider it, thanks.
> > >
> > Hi, Andrey and Dmitry,
> >
> > I am sorry to bother you.
> > Would you tell me what you think about this patch?
> > We want to use tag-based KASAN, so we hope its bug report is clear and
> > correct as generic KASAN.
> >
> > Thanks your review.
> > Walter
> 
> Hi Walter,
> 
> I will probably be busy till the next week. Sorry for delays.

It's ok. Thanks your kindly help.
I hope I can contribute to tag-based KASAN. It is a very important tool
for us.

