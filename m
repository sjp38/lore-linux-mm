Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 214ADC32756
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:09:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C503A2173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:09:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="dbDwiA4A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C503A2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 536DF6B0007; Thu,  8 Aug 2019 19:09:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F0456B0008; Thu,  8 Aug 2019 19:09:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D61E6B000A; Thu,  8 Aug 2019 19:09:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 064BF6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:09:08 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id k9so56332399pls.13
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:09:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=PshILyRjCCo0C5QCJz7frN2AnaNP8oJw8QYaH2iANig=;
        b=HO2880JA0kwnAJ4pBEp5pVzNStvGCMgnUgVmwiptl8CEqK+ZICrShQIXGlOzSduDb4
         vYcUNdNuiQBB/8D2i0ZwZ8CzP9x7fJ2Q8XJJH44B+aNpuq+MKh1C47MHKRs67m2BNxJS
         yl4JN5VbgB2TfiGRRpnaMLjhn8x6f9QIgKDQTW8qoJ9X/LXZBIWN7IUMgJzmbZ4Z74Vd
         c/GFVBWUOgF2TSh02OGxDag7a2m3VX8zew/7yD/YD++gUtZu5IkXSUAxB6XqiaWELBzy
         wtfqeEziUJ2+WGWGn8uNkVOcTgZTaoaiA5jIS8SZx1f/A9p4y8BeTDUciWeLZSsNXeMH
         eyqA==
X-Gm-Message-State: APjAAAXLf9Xw/2LhP1BYOJIsXZ8i+31m1JoFGz+p7i7+qRNanOJeomWF
	Kc8hd6lkhbPTK8vC0HlUSCWuwBnt0xIfwwyZEJ/bzfIC2Xwo5xgsfuGKqZ+5JMI2mQ16Yt5Cx1P
	qrXooFbW+JmDUs8BULy9nCXHYYz/GiBcqxBi95xqTq+gEr766jCm/8WY+3JDUwign0w==
X-Received: by 2002:a17:902:24b:: with SMTP id 69mr15413860plc.250.1565305747658;
        Thu, 08 Aug 2019 16:09:07 -0700 (PDT)
X-Received: by 2002:a17:902:24b:: with SMTP id 69mr15413816plc.250.1565305746894;
        Thu, 08 Aug 2019 16:09:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565305746; cv=none;
        d=google.com; s=arc-20160816;
        b=M15MlT08LpwOxiucVqZuVIuew+FDF9Y2y4jSgOE0yEAlFlqNttey1tKpkqWPPAFavk
         rCtPxZZ1DOjAxQaKV9EA8keUnZ7ws+vVC8EBOZT3LpVJJaLD0lsBD3VifylpEdriaplS
         NgKguzCJJvkhEvOWCasz6RUPL5pPuNKcYpdGCTw0g1bgJBOK6cEE1BKPi1V9zOsUSc8o
         YFp5Fmei2brOHZdT/Ddu3ZVD/vbjn7Id28VAQdUrUxDDlkVB8Jt/S7aL4T4HBQfVdVVq
         ZNei6oalDwUu8XbTLFQ27d0gvNvaQ7U+OyZ4dbgiabFgGNf70tnV+X5hLzAostx7Evg9
         T7gQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=PshILyRjCCo0C5QCJz7frN2AnaNP8oJw8QYaH2iANig=;
        b=xrq+AU1rVXQkAk9V6iZZky+Ksa15EQrh7DmulJEwnDbJbmr4gpZNYsJXEatidL/F57
         8N29PGldT1mr8bURCUwh6iPwRETyfwN7+2cla6vkqSPECXGWV/DFHFH4u5k0kiB2AHf2
         vN4Wyiaet5XS/dcQkZisi8kaBk7xm+67E1mED4VAV+ZCjEIzQfKscOvUnEfyU7UjufcV
         3luS3NcY2KvoHuD6863iT2fD2OMnMeGAq2nBHVkSjLz5GY5/NvzuohaQdm9Hmgpu+Wws
         XwD6N9A0jmWaGLDH7XZyEIsVmlGdp7Knb9Ndi6Png8/DjVabzYWP8yJr3rhXJFLumt+/
         kRZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=dbDwiA4A;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 101sor113683862plf.70.2019.08.08.16.09.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 16:09:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=dbDwiA4A;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=PshILyRjCCo0C5QCJz7frN2AnaNP8oJw8QYaH2iANig=;
        b=dbDwiA4Adn6NNb5EvA73thvbmUP2keuqre4+n/NxwEHqhexDztnDaNh7AsRSTZZe49
         hYpD3IzLcNsObNJn7jV0JwQOyof3bHoudWE9xbxMphJZ3xC6+cAju3iiWanCTUgT+RRy
         5BTDqjSStXzv50strdYe4GteQ70uxl48L/KiQ=
X-Google-Smtp-Source: APXvYqwRMwQCoIwwE1SVnXBBenp7lYzRwUiHs8nPiovNgZn+1R84ViErtlLi11BYuAEM5u5dpbcusw==
X-Received: by 2002:a17:902:d70a:: with SMTP id w10mr15179356ply.251.1565305746634;
        Thu, 08 Aug 2019 16:09:06 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id o130sm157376311pfg.171.2019.08.08.16.09.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Aug 2019 16:09:05 -0700 (PDT)
Date: Thu, 8 Aug 2019 16:09:04 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Will Deacon <will@kernel.org>,
	Will Deacon <will.deacon@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	dri-devel@lists.freedesktop.org, Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
Message-ID: <201908081608.A4F6711@keescook>
References: <cover.1563904656.git.andreyknvl@google.com>
 <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
 <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
 <CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
 <20190724142059.GC21234@fuggles.cambridge.arm.com>
 <20190806171335.4dzjex5asoertaob@willie-the-truck>
 <CAAeHK+zF01mxU+PkEYLkoVu-ZZM6jNfL_OwMJKRwLr-sdU4Myg@mail.gmail.com>
 <201908081410.C16D2BD@keescook>
 <20190808153300.09d3eb80772515f0ea062833@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808153300.09d3eb80772515f0ea062833@linux-foundation.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 03:33:00PM -0700, Andrew Morton wrote:
> On Thu, 8 Aug 2019 14:12:19 -0700 Kees Cook <keescook@chromium.org> wrote:
> 
> > > The ones that are left are the mm ones: 4, 5, 6, 7 and 8.
> > > 
> > > Andrew, could you take a look and give your Acked-by or pick them up directly?
> > 
> > Given the subsystem Acks, it seems like 3-10 and 12 could all just go
> > via Andrew? I hope he agrees. :)
> 
> I'll grab everything that has not yet appeared in linux-next.  If more
> of these patches appear in linux-next I'll drop those as well.
> 
> The review discussion against " [PATCH v19 02/15] arm64: Introduce
> prctl() options to control the tagged user addresses ABI" has petered
> out inconclusively.  prctl() vs arch_prctl().

I've always disliked arch_prctl() existing at all. Given that tagging is
likely to be a multi-architectural feature, it seems like the controls
should live in prctl() to me.

-- 
Kees Cook

