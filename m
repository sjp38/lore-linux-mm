Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AFD7C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 10:15:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49867206B8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 10:15:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="NB0yJ7s+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49867206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C49708E0003; Mon, 29 Jul 2019 06:15:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF9598E0002; Mon, 29 Jul 2019 06:15:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE91C8E0003; Mon, 29 Jul 2019 06:15:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 789778E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 06:15:27 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s21so32845266plr.2
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 03:15:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:in-reply-to
         :references:date:message-id:mime-version;
        bh=TeABIY9Sypa15BDJaEG/kpYb1fIC9bRaLEhXhSyew+g=;
        b=PAhkhRSkaMheXLfTieiGt6Gk8Ss9pxsdVs+r6eWKsj2SAEDzzebq1quEk4yr6t+wZF
         WtNwC33+53ZmZGOFWQOgQXVlf7IU7nPeJb/EkrtoUKFQBVaZSKoViCe2/MoIn2oIv3dQ
         Yc1vKdd3dGwUYsd/W74O4sVuLWiclwWRy/lPjQjPQZRMSSk252a8HqDp/j6Y7UxzqqGr
         T31TXJHEFVH5p+ij0KifEuqRfWt8/RgcbyOLUh7d43QGxeOf2z7uJY8/2PcKNiGIYZ58
         UXG6bFFuGDONEYeui3Z/EMP+heAnQiC8cG1jMGa3Hdc5iaW8mA7AGvoZ9EMC2erwVWXH
         hUwQ==
X-Gm-Message-State: APjAAAVOSbTJdgkgzz85DEyZF7CS5bYRax8AsImW2v6zcsmgNLdgqj72
	tIO7YNeNYKLrZWzvuq3RCoyHyo85nhmTDmbGN+q+h1gzNDXk+maYWwofdtpoKg0dtq2cSGqedgC
	5VLYjd4U8fxz1JdURQKYr/yC7TSBwhL4qTEBHbSXfruoJJ77yf13FHDJc9N+J1PBUKA==
X-Received: by 2002:a62:be04:: with SMTP id l4mr34578998pff.77.1564395327049;
        Mon, 29 Jul 2019 03:15:27 -0700 (PDT)
X-Received: by 2002:a62:be04:: with SMTP id l4mr34578890pff.77.1564395325709;
        Mon, 29 Jul 2019 03:15:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564395325; cv=none;
        d=google.com; s=arc-20160816;
        b=erz6Uc8sY+crxKjceL1s8wekqUX31ydfDkWugRsRtrLyW2kTvNV1mI3abDdtSf/hLl
         Q2KRRyn5lQgB5uvj2guQT47+u/zv04ZeHTwlgDnmbiBN7mU8jtq8XV4GyfwTwFv3wczc
         6lzdjYZf94xh8SVmM9++s+Yx63Zc6bSoql6Ylzq1Hh9WzR6XZ6FQ28Wya9RdEN205QUH
         wciyeSizi1nDdsnVy/47HOn2/MhBmR3wLzrExmUpzgzui60UT28V1X72DAafkGipYWsn
         imd9VOEE/yuHp03/IuJj+4bb+a/NcuD0LRDt191GXA3+vOg1PsN4oJTV31TVSo1M/gCh
         bSsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:dkim-signature;
        bh=TeABIY9Sypa15BDJaEG/kpYb1fIC9bRaLEhXhSyew+g=;
        b=fXXjTqeXpZ/GnvIJXEIqypeVGaO/vwhzLQHMGy8bWVuSWHEwvDsBrbvOkYNeW0A9aA
         2C6Y1FK+GLru5H6HLcpsvao10cz46VyPLaQThdJ/aXdGakTRkVBWDNvEFxR+EXEADEw8
         8/N6tGRK0KdfVGfGAb8BltOorpkZ03u7+XyU5MxEmUg2Of4h9eGKzcwsA0e+9JFB6pbd
         UvcvfostMyBMUf+kiAPZPq5Xa9srcm5ZXbSSsqc2P7MQa2PEsxsuFjezoVSZHh8mB+Rw
         J2pkXwrCq87FPijs/WGtLMTjYpC885WD0oOchjZs6rbaYOW/GFFH9XM6Asp7fQxwrgBq
         LQIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=NB0yJ7s+;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l13sor38949555pgq.30.2019.07.29.03.15.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 03:15:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=NB0yJ7s+;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=TeABIY9Sypa15BDJaEG/kpYb1fIC9bRaLEhXhSyew+g=;
        b=NB0yJ7s+Rq3AK4iAXWMhDl3Wo7jK4/OQ1FA01kgUxal3KU1kgVq4crsqMVAy1RPa2/
         ebP+iYjuTpfp1llSvU7s5JDFT2O432XRgz0P1pHj4N2pYLL5aVPrXcS7YBvnK2OwzC5M
         k8RgMl/SgyJ5KtyqYnlx7krXijff+SqelEGK8=
X-Google-Smtp-Source: APXvYqxjbZy2lgb0ubjbnXkdOKq5C5KYoNMZrD/VdVhfikBTQ63E4bO4q7HL8z+OYC89Z4j7IEPwHw==
X-Received: by 2002:a63:3203:: with SMTP id y3mr104769085pgy.191.1564395325067;
        Mon, 29 Jul 2019 03:15:25 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id o3sm113898745pje.1.2019.07.29.03.15.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 03:15:24 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH 1/3] kasan: support backing vmalloc space with real shadow memory
In-Reply-To: <CACT4Y+Yw74otyk9gASfUyAW_bbOr8H5Cjk__F7iptrxRWmS9=A@mail.gmail.com>
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-2-dja@axtens.net> <CACT4Y+Yw74otyk9gASfUyAW_bbOr8H5Cjk__F7iptrxRWmS9=A@mail.gmail.com>
Date: Mon, 29 Jul 2019 20:15:19 +1000
Message-ID: <87blxdgn9k.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dmitry,

Thanks for the feedback!

>> +       addr = shadow_alloc_start;
>> +       do {
>> +               pgdp = pgd_offset_k(addr);
>> +               p4dp = p4d_alloc(&init_mm, pgdp, addr);
>
> Page table allocations will be protected by mm->page_table_lock, right?

Yes, each of those alloc functions take the lock if they end up in the
slow-path that does the actual allocation (e.g. __p4d_alloc()).

>> +               pudp = pud_alloc(&init_mm, p4dp, addr);
>> +               pmdp = pmd_alloc(&init_mm, pudp, addr);
>> +               ptep = pte_alloc_kernel(pmdp, addr);
>> +
>> +               /*
>> +                * we can validly get here if pte is not none: it means we
>> +                * allocated this page earlier to use part of it for another
>> +                * allocation
>> +                */
>> +               if (pte_none(*ptep)) {
>> +                       backing = __get_free_page(GFP_KERNEL);
>> +                       backing_pte = pfn_pte(PFN_DOWN(__pa(backing)),
>> +                                             PAGE_KERNEL);
>> +                       set_pte_at(&init_mm, addr, ptep, backing_pte);
>> +               }
>> +       } while (addr += PAGE_SIZE, addr != shadow_alloc_end);
>> +
>> +       requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
>> +       kasan_unpoison_shadow(area->addr, requested_size);
>> +       kasan_poison_shadow(area->addr + requested_size,
>> +                           area->size - requested_size,
>> +                           KASAN_VMALLOC_INVALID);
>
>
> Do I read this correctly that if kernel code does vmalloc(64), they
> will have exactly 64 bytes available rather than full page? To make
> sure: vmalloc does not guarantee that the available size is rounded up
> to page size? I suspect we will see a throw out of new bugs related to
> OOBs on vmalloc memory. So I want to make sure that these will be
> indeed bugs that we agree need to be fixed.
> I am sure there will be bugs where the size is controlled by
> user-space, so these are bad bugs under any circumstances. But there
> will also probably be OOBs, where people will try to "prove" that
> that's fine and will work (just based on our previous experiences :)).

So the implementation of vmalloc will always round it up. The
description of the function reads, in part:

 * Allocate enough pages to cover @size from the page level
 * allocator and map them into contiguous kernel virtual space.

So in short it's not quite clear - you could argue that you have a
guarantee that you get full pages, but you could also argue that you've
specifically asked for @size bytes and @size bytes only.

So far it seems that users are well behaved in terms of using the amount
of memory they ask for, but you'll get a better idea than me very
quickly as I only tested with trinity. :)

I also handle vmap - for vmap there's no way to specify sub-page
allocations so you get as many pages as you ask for.

> On impl side: kasan_unpoison_shadow seems to be capable of handling
> non-KASAN_SHADOW_SCALE_SIZE-aligned sizes exactly in the way we want.
> So I think it's better to do:
>
>        kasan_unpoison_shadow(area->addr, requested_size);
>        requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
>        kasan_poison_shadow(area->addr + requested_size,
>                            area->size - requested_size,
>                            KASAN_VMALLOC_INVALID);

Will do for v2.

Regards,
Daniel

