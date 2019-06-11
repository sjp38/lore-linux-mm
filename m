Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 664C2C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:44:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 253DF20645
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:44:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 253DF20645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C11C26B0005; Tue, 11 Jun 2019 06:44:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC19C6B0006; Tue, 11 Jun 2019 06:44:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A89F26B0007; Tue, 11 Jun 2019 06:44:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 741476B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:44:56 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l184so8874559pgd.18
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 03:44:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=sPWSgbnNjYhV7F10nlBB1fjN0kdnLPE2A/+eob6NAdY=;
        b=Q+LFc0iakFduXxS6AyTMYvoeByR6JIW+e6OVKjAq+OwFFEKN1lLKIbRQQST8IZROiY
         CN+LyOhGLgzc0+LW9UDZvliKYNXdyjy+dPCmnEpd6RI0YR9ni7AoqBdIItzfFHDfMc8p
         L+86UFVm1RCQ3t6HoJrFhrxZRTlxi1ZGUlnNxxdfqKEfUZeWTiY9z8ytxjwZt+cB4xxI
         eYvSW8ZG/RtLpyTVG+JeSpb4VIppa//Y4C7rMhePqcdlLT+2I08Axget4BJ6ELK09nvs
         AyZXg4xH092yw1eL1T+CuZwhL8trRgF7RftrgNpJZIT0SztqGdLA7eBsd9nSJGtatEAa
         K3lQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAUOvMEmJ6aFWmQ59FtXAUcVlXx0N/J16WuZhECdG/5rE9ksQpv/
	hyzpvrSPYXPA1BhZqbv3kaZqgW1mypZk9VNDkwHXq7mKKc+souhK/Zd+I/n5gcXBiYgV5HJFA0y
	iLBP040Y5F5wfUmiZ9eOHdYhsQysV4RCcbLQu3pFrXQEudJX5g8Q4Sq2DVndyl5cOQQ==
X-Received: by 2002:a63:1622:: with SMTP id w34mr19881288pgl.45.1560249895898;
        Tue, 11 Jun 2019 03:44:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwp7xk5pSD0/UraO94YgJH5BrVM+NnhUfWF8x68oSzeJVGPxceHrkuHnC3Zr9mrsFYu+kou
X-Received: by 2002:a63:1622:: with SMTP id w34mr19881232pgl.45.1560249894934;
        Tue, 11 Jun 2019 03:44:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560249894; cv=none;
        d=google.com; s=arc-20160816;
        b=chaHeqRDlhViOJS7XbXRQXMq/xTs7Z0JSyLteQvBu/F/J7SjiqxrSx84n37BPjr17b
         LbY9AQgzI8StXfaUYHVDfnvIhE2/A7UTUmOBjYWSY/3jIGqnlgwrAU27XyD1ELC2ID6d
         BaVKHTEQuKDlCVtmtPk9yaEqpsJbo8aWbTlep49r44bkJYWnz99elxCddGqS4EOvf6qC
         Dm/1fHV7EA/x926hMCKWaBRADZV+TXY4/HwLwC2Kl5JHabq9ypbKhOJxFxIf8Xa29HG0
         YJcq8EficyDZUNE8vzqL4o+ZdYc9a+tzmY3ydShXrhLCKstzJ9MIUnhlIyyb/Oa2qL3+
         mvRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=sPWSgbnNjYhV7F10nlBB1fjN0kdnLPE2A/+eob6NAdY=;
        b=XyPnETnUEn/UkXFIpr12gyocdtMLplfZ+3Dl1s0QxRvgcQFwmlZTfK+d5n4V6zVqLC
         EOBYu8vW03/lNht3WSoL9dcNTZpttnv2TRKshueZdHwH571P6UZzMhjMxMXoDX3tnak7
         p86VyREIAFmbA7AOstS7xTvDevYs8roczXfKcAuT6wKT92mL3jK0SL5FWOn0iPwN1dXy
         OOOR2+WAy2kSr7ONju4U/NZRAy3rPwQMMVvSkoSuxiQWpHAKmB4DRnDg56J/ASrDmtbn
         1f+XJmeWIUsAwAR7cry9GPxdCOcsm8eQ8KOeomvHn6DdW+0DO73J+/3Bfbnqaudx8QZX
         Cqmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id 30si13790352plb.30.2019.06.11.03.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 03:44:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: 6438f1b0b6e14368a23e04b08d3231a8-20190611
X-UUID: 6438f1b0b6e14368a23e04b08d3231a8-20190611
Received: from mtkexhb02.mediatek.inc [(172.21.101.103)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1585980236; Tue, 11 Jun 2019 18:44:53 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs08n1.mediatek.inc (172.21.101.55) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Tue, 11 Jun 2019 18:44:51 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Tue, 11 Jun 2019 18:44:51 +0800
Message-ID: <1560249891.29153.4.camel@mtksdccf07>
Subject: Re: [PATCH v2] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Dmitry Vyukov <dvyukov@google.com>
CC: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
	<glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Vasily
 Gorbik" <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, "Jason
 A. Donenfeld" <Jason@zx2c4.com>, Miles Chen
 =?UTF-8?Q?=28=E9=99=B3=E6=B0=91=E6=A8=BA=29?= <Miles.Chen@mediatek.com>,
	kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, Linux ARM
	<linux-arm-kernel@lists.infradead.org>, "linux-mediatek@lists.infradead.org"
	<linux-mediatek@lists.infradead.org>, wsd_upstream
	<wsd_upstream@mediatek.com>
Date: Tue, 11 Jun 2019 18:44:51 +0800
In-Reply-To: <CACT4Y+YNG0OGT+mCEms+=SYWA=9R3MmBzr8e3QsNNdQvHNt9Fg@mail.gmail.com>
References: <1559651172-28989-1-git-send-email-walter-zh.wu@mediatek.com>
	 <CACT4Y+Y9_85YB8CCwmKerDWc45Z00hMd6Pc-STEbr0cmYSqnoA@mail.gmail.com>
	 <1560151690.20384.3.camel@mtksdccf07>
	 <CACT4Y+aetKEM9UkfSoVf8EaDNTD40mEF0xyaRiuw=DPEaGpTkQ@mail.gmail.com>
	 <1560236742.4832.34.camel@mtksdccf07>
	 <CACT4Y+YNG0OGT+mCEms+=SYWA=9R3MmBzr8e3QsNNdQvHNt9Fg@mail.gmail.com>
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

On Tue, 2019-06-11 at 10:47 +0200, Dmitry Vyukov wrote:
> On Tue, Jun 11, 2019 at 9:05 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> >
> > On Mon, 2019-06-10 at 13:46 +0200, Dmitry Vyukov wrote:
> > > On Mon, Jun 10, 2019 at 9:28 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> > > >
> > > > On Fri, 2019-06-07 at 21:18 +0800, Dmitry Vyukov wrote:
> > > > > > diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> > > > > > index b40ea104dd36..be0667225b58 100644
> > > > > > --- a/include/linux/kasan.h
> > > > > > +++ b/include/linux/kasan.h
> > > > > > @@ -164,7 +164,11 @@ void kasan_cache_shutdown(struct kmem_cache *cache);
> > > > > >
> > > > > >  #else /* CONFIG_KASAN_GENERIC */
> > > > > >
> > > > > > +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> > > > > > +void kasan_cache_shrink(struct kmem_cache *cache);
> > > > > > +#else
> > > > >
> > > > > Please restructure the code so that we don't duplicate this function
> > > > > name 3 times in this header.
> > > > >
> > > > We have fixed it, Thank you for your reminder.
> > > >
> > > >
> > > > > >  static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
> > > > > > +#endif
> > > > > >  static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
> > > > > >
> > > > > >  #endif /* CONFIG_KASAN_GENERIC */
> > > > > > diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> > > > > > index 9950b660e62d..17a4952c5eee 100644
> > > > > > --- a/lib/Kconfig.kasan
> > > > > > +++ b/lib/Kconfig.kasan
> > > > > > @@ -134,6 +134,15 @@ config KASAN_S390_4_LEVEL_PAGING
> > > > > >           to 3TB of RAM with KASan enabled). This options allows to force
> > > > > >           4-level paging instead.
> > > > > >
> > > > > > +config KASAN_SW_TAGS_IDENTIFY
> > > > > > +       bool "Enable memory corruption idenitfication"
> > > > >
> > > > > s/idenitfication/identification/
> > > > >
> > > > I should replace my glasses.
> > > >
> > > >
> > > > > > +       depends on KASAN_SW_TAGS
> > > > > > +       help
> > > > > > +         Now tag-based KASAN bug report always shows invalid-access error, This
> > > > > > +         options can identify it whether it is use-after-free or out-of-bound.
> > > > > > +         This will make it easier for programmers to see the memory corruption
> > > > > > +         problem.
> > > > >
> > > > > This description looks like a change description, i.e. it describes
> > > > > the current behavior and how it changes. I think code comments should
> > > > > not have such, they should describe the current state of the things.
> > > > > It should also mention the trade-off, otherwise it raises reasonable
> > > > > questions like "why it's not enabled by default?" and "why do I ever
> > > > > want to not enable it?".
> > > > > I would do something like:
> > > > >
> > > > > This option enables best-effort identification of bug type
> > > > > (use-after-free or out-of-bounds)
> > > > > at the cost of increased memory consumption for object quarantine.
> > > > >
> > > > I totally agree with your comments. Would you think we should try to add the cost?
> > > > It may be that it consumes about 1/128th of available memory at full quarantine usage rate.
> > >
> > > Hi,
> > >
> > > I don't understand the question. We should not add costs if not
> > > necessary. Or you mean why we should add _docs_ regarding the cost? Or
> > > what?
> > >
> > I mean the description of option. Should it add the description for
> > memory costs. I see KASAN_SW_TAGS and KASAN_GENERIC options to show the
> > memory costs. So We originally think it is possible to add the
> > description, if users want to enable it, maybe they want to know its
> > memory costs.
> >
> > If you think it is not necessary, we will not add it.
> 
> Full description of memory costs for normal KASAN mode and
> KASAN_SW_TAGS should probably go into
> Documentation/dev-tools/kasan.rst rather then into config description
> because it may be too lengthy.
> 
Thanks your reminder.

> I mentioned memory costs for this config because otherwise it's
> unclear why would one ever want to _not_ enable this option. If it
> would only have positive effects, then it should be enabled all the
> time and should not be a config option at all.

Sorry, I don't get your full meaning.
You think not to add the memory costs into the description of config ?
or need to add it? or make it not be a config option(default enabled)?


