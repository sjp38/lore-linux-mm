Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC351C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:26:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DF2A20673
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:26:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DF2A20673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C5E36B000A; Tue, 11 Jun 2019 08:26:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 078046B000D; Tue, 11 Jun 2019 08:26:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED0046B0010; Tue, 11 Jun 2019 08:26:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5C866B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:26:02 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u7so9507960pfh.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:26:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=Jyb8YM8lArG+/Y8fk24IqbWjw81Z+P7IptrzCzYSy4Y=;
        b=LUXLiexdwVOYxDDCp/U2KjPKy61+qd/4TlKdIXFLD942rM2t/meHyCwy4G4I9D5ZUG
         IUObQnGaGtqcs/fRtl/7uSkEB0D6TYrjmxQtpdDIMjZkpiiDSJ50TqbcOlbWuksef9xF
         JuP/0p0WfuD5PUciQCRN9cT2ltrKfZKRCWXOVyq4mqgbBOf9or1EBDtUxAQyuHoDws2B
         XPEXIEsFdMNXiECqMIEz86JZgdIs5zi0lrrYR9EyC+MKc5EMfUGvqQFhsupENoTI93n4
         8i26Bj6gDWId7B2vdJKSEvDGTUCh8EDbT56Qv1QXQz+KbV2L1Bb/51XeVCHmX8llX2nb
         c71Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAU1XkqczYzYai6ITpqw2BzGQMVwa2g0NAJJ7MDdhN3s2RlOwx2/
	2F8MSorK3ohNHugJrJvemPJqlPF/o5oPGXXoPAJlCNM+1iBWNsKvcgG31uXR2ndjIse5ApWsOBk
	4Ww8lpR571CgWf6b+ASj9cnxVVCq3ewISsgqkGytQBQWmiduruuCtSFdWrdBW2p4/ZA==
X-Received: by 2002:a17:902:9b94:: with SMTP id y20mr60779062plp.260.1560255962338;
        Tue, 11 Jun 2019 05:26:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9jp7HccYX4xZdUaVa+0ijLYYgkecO6+8O2hRZsfzkik1WXPBfiHEsLtqvFtxD3lWMps+H
X-Received: by 2002:a17:902:9b94:: with SMTP id y20mr60779014plp.260.1560255961549;
        Tue, 11 Jun 2019 05:26:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560255961; cv=none;
        d=google.com; s=arc-20160816;
        b=lO+cc30caVTACUIMaEMh/mNmmYu/vfhjPGPNiESZrcKf/PVg03LSeQ7YHeJP8gJxwQ
         IdvvgAQFUUCuMAT/sHs36E9cFV/8nev2mW6G6biPfzz/BlrJx5LsF3KVG/fTz0eoBxx6
         iYLi1ZQ7FNLzxCnlIigQqFgHz8aPtDc3T3SnEISL+QGZOvXFdtO3cHRv2qhzyeaGwYlX
         v+AxkXbi3Mv1JTWCCernHp96igeZO87/uamTkK7/Md5Mgh/J+yeRWmX2sh/E3yUvROLn
         q5f9ganFDnqwok0EG8aTTlETziJkm53/HXCvMRp05ihFBhI/1a1uYgNL0E/17ElLI2me
         btdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=Jyb8YM8lArG+/Y8fk24IqbWjw81Z+P7IptrzCzYSy4Y=;
        b=MX8cdusbWc7qByl6sK3WekUobiRtyipl6Tz7wKg+Uk6Cio93USBhqbU9dKcshjpvGN
         IGaaZZ62QP9tg6rGH8C6mWniP+o1fdwkkqBnyvLDWiFYzGRWcOwhUv375M2sjoThXE6B
         vD7KZb2n8xeVxBp0QBzab8i7G6qIvJJ9AFeHLnxNZ0K8GxAqVXttHq0ndKEgQrPX8xIW
         95ZQXkJsNVQfXlxVgSviXOPcr8UGlrAKoD8Kyebqmqzrg00uHODkox3/i55jZnvf38Dj
         q7yWrxAeJ4lTJvD1fPWzNIOuZjOSw1VfeHtY6W4dle5ZaAkd/vfqKrHSVhcv+Xzi2Y5D
         xnWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id d31si5185002pla.84.2019.06.11.05.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 05:26:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: 8fc4afafc8034cc59a92651ab0d17e0e-20190611
X-UUID: 8fc4afafc8034cc59a92651ab0d17e0e-20190611
Received: from mtkexhb02.mediatek.inc [(172.21.101.103)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1205233393; Tue, 11 Jun 2019 20:25:56 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Tue, 11 Jun 2019 20:25:55 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Tue, 11 Jun 2019 20:25:55 +0800
Message-ID: <1560255955.29153.20.camel@mtksdccf07>
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
Date: Tue, 11 Jun 2019 20:25:55 +0800
In-Reply-To: <CACT4Y+aXqjCMaJego3yeSG1eR1+vkJkx5GB+xsy5cpGvAtTnDA@mail.gmail.com>
References: <1559651172-28989-1-git-send-email-walter-zh.wu@mediatek.com>
	 <CACT4Y+Y9_85YB8CCwmKerDWc45Z00hMd6Pc-STEbr0cmYSqnoA@mail.gmail.com>
	 <1560151690.20384.3.camel@mtksdccf07>
	 <CACT4Y+aetKEM9UkfSoVf8EaDNTD40mEF0xyaRiuw=DPEaGpTkQ@mail.gmail.com>
	 <1560236742.4832.34.camel@mtksdccf07>
	 <CACT4Y+YNG0OGT+mCEms+=SYWA=9R3MmBzr8e3QsNNdQvHNt9Fg@mail.gmail.com>
	 <1560249891.29153.4.camel@mtksdccf07>
	 <CACT4Y+aXqjCMaJego3yeSG1eR1+vkJkx5GB+xsy5cpGvAtTnDA@mail.gmail.com>
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

On Tue, 2019-06-11 at 13:32 +0200, Dmitry Vyukov wrote:
> On Tue, Jun 11, 2019 at 12:44 PM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> >
> > On Tue, 2019-06-11 at 10:47 +0200, Dmitry Vyukov wrote:
> > > On Tue, Jun 11, 2019 at 9:05 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> > > >
> > > > On Mon, 2019-06-10 at 13:46 +0200, Dmitry Vyukov wrote:
> > > > > On Mon, Jun 10, 2019 at 9:28 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> > > > > >
> > > > > > On Fri, 2019-06-07 at 21:18 +0800, Dmitry Vyukov wrote:
> > > > > > > > diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> > > > > > > > index b40ea104dd36..be0667225b58 100644
> > > > > > > > --- a/include/linux/kasan.h
> > > > > > > > +++ b/include/linux/kasan.h
> > > > > > > > @@ -164,7 +164,11 @@ void kasan_cache_shutdown(struct kmem_cache *cache);
> > > > > > > >
> > > > > > > >  #else /* CONFIG_KASAN_GENERIC */
> > > > > > > >
> > > > > > > > +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> > > > > > > > +void kasan_cache_shrink(struct kmem_cache *cache);
> > > > > > > > +#else
> > > > > > >
> > > > > > > Please restructure the code so that we don't duplicate this function
> > > > > > > name 3 times in this header.
> > > > > > >
> > > > > > We have fixed it, Thank you for your reminder.
> > > > > >
> > > > > >
> > > > > > > >  static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
> > > > > > > > +#endif
> > > > > > > >  static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
> > > > > > > >
> > > > > > > >  #endif /* CONFIG_KASAN_GENERIC */
> > > > > > > > diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> > > > > > > > index 9950b660e62d..17a4952c5eee 100644
> > > > > > > > --- a/lib/Kconfig.kasan
> > > > > > > > +++ b/lib/Kconfig.kasan
> > > > > > > > @@ -134,6 +134,15 @@ config KASAN_S390_4_LEVEL_PAGING
> > > > > > > >           to 3TB of RAM with KASan enabled). This options allows to force
> > > > > > > >           4-level paging instead.
> > > > > > > >
> > > > > > > > +config KASAN_SW_TAGS_IDENTIFY
> > > > > > > > +       bool "Enable memory corruption idenitfication"
> > > > > > >
> > > > > > > s/idenitfication/identification/
> > > > > > >
> > > > > > I should replace my glasses.
> > > > > >
> > > > > >
> > > > > > > > +       depends on KASAN_SW_TAGS
> > > > > > > > +       help
> > > > > > > > +         Now tag-based KASAN bug report always shows invalid-access error, This
> > > > > > > > +         options can identify it whether it is use-after-free or out-of-bound.
> > > > > > > > +         This will make it easier for programmers to see the memory corruption
> > > > > > > > +         problem.
> > > > > > >
> > > > > > > This description looks like a change description, i.e. it describes
> > > > > > > the current behavior and how it changes. I think code comments should
> > > > > > > not have such, they should describe the current state of the things.
> > > > > > > It should also mention the trade-off, otherwise it raises reasonable
> > > > > > > questions like "why it's not enabled by default?" and "why do I ever
> > > > > > > want to not enable it?".
> > > > > > > I would do something like:
> > > > > > >
> > > > > > > This option enables best-effort identification of bug type
> > > > > > > (use-after-free or out-of-bounds)
> > > > > > > at the cost of increased memory consumption for object quarantine.
> > > > > > >
> > > > > > I totally agree with your comments. Would you think we should try to add the cost?
> > > > > > It may be that it consumes about 1/128th of available memory at full quarantine usage rate.
> > > > >
> > > > > Hi,
> > > > >
> > > > > I don't understand the question. We should not add costs if not
> > > > > necessary. Or you mean why we should add _docs_ regarding the cost? Or
> > > > > what?
> > > > >
> > > > I mean the description of option. Should it add the description for
> > > > memory costs. I see KASAN_SW_TAGS and KASAN_GENERIC options to show the
> > > > memory costs. So We originally think it is possible to add the
> > > > description, if users want to enable it, maybe they want to know its
> > > > memory costs.
> > > >
> > > > If you think it is not necessary, we will not add it.
> > >
> > > Full description of memory costs for normal KASAN mode and
> > > KASAN_SW_TAGS should probably go into
> > > Documentation/dev-tools/kasan.rst rather then into config description
> > > because it may be too lengthy.
> > >
> > Thanks your reminder.
> >
> > > I mentioned memory costs for this config because otherwise it's
> > > unclear why would one ever want to _not_ enable this option. If it
> > > would only have positive effects, then it should be enabled all the
> > > time and should not be a config option at all.
> >
> > Sorry, I don't get your full meaning.
> > You think not to add the memory costs into the description of config ?
> > or need to add it? or make it not be a config option(default enabled)?
> 
> Yes, I think we need to include mention of additional cost into _this_
> new config.

Thanks your response.
We will fix v2 patch into next version.

Thanks.
Walter


