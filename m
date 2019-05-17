Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66D85C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 08:49:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 278E62082E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 08:49:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="L17n4MiM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 278E62082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0E986B0005; Fri, 17 May 2019 04:49:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A99396B0006; Fri, 17 May 2019 04:49:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 938596B0007; Fri, 17 May 2019 04:49:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5386B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 04:49:16 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id q191so2395025vkh.5
        for <linux-mm@kvack.org>; Fri, 17 May 2019 01:49:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=dcKNTtASXX61Q+VQr8INe49VkZfJpp38n/5rM4hpO6M=;
        b=O5Fedq8t5Tr5zp6XHm2oZYHHp3df4Mgs2hto3PbZXmUIj4dElzrfBuseMZ8Z0JwWNY
         RMlAGgEgdGRJLMOwsPFRel2AwPrFF0IvMKvtBqg5UNVxDKICU1LEpDm/EGIOK8qTQzdt
         hC5ndbdWAQVHVg17biiHVi0l1wPXhTqbDoghMOSI5YhJpuz4h/uuZCNToVCZvuD6AcAL
         rVpiB/wwtQaGWY/BKV2jaVkW/U9pn61ifONc1hPlLnSiY/a9ubduK26HUC8iY1nfmGps
         rOB1n//jfFGjkhiXcNJVj6AOpBYo5nAh4JzqjkPRM9920UX9DXzlEvKnRRLXRH5lzRiN
         Q/tg==
X-Gm-Message-State: APjAAAWt0nE/MagXaVt4Ze9xzYp891u+umRtVHEA0DeiXD1Ms6RXfWja
	G4ZjgIlVF/nlxNhBZXqNCiljI6+LEQTg02CWujMm0ZJeKFaHsIvOk+I2mFO5u/+6VZmdCgFQHpK
	HewXqARyp87AxRZMWbacMx8gE3JgIT4/UwjdT0uCkoyWNtpr+aQ8DeI/ym9JEJo84Sw==
X-Received: by 2002:a67:fc4:: with SMTP id 187mr5407565vsp.215.1558082956064;
        Fri, 17 May 2019 01:49:16 -0700 (PDT)
X-Received: by 2002:a67:fc4:: with SMTP id 187mr5407548vsp.215.1558082955268;
        Fri, 17 May 2019 01:49:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558082955; cv=none;
        d=google.com; s=arc-20160816;
        b=Ic6FHdYM1psvGlTmewtfrYMkjmUb1yEXOvL5WmC+/dZ/img4GeIA/PratORjpQCwZ8
         l0ih51r9Xcqxd/lQleKELRsZJ7DyHOdqw35lHvEouzSGofI5L297x2n6TlblPFaUYVJb
         b7Vp9+j75Rk7bufHJtzUPTi5E++Ud0UfdV7wMHalmqZaZCMxE/79PDM7fYc1s9bKUxbb
         MdkmDxNNdvo5CHlbmNu8mn1XGRVu/MnxJWDNmnJQZ8R3A/i2fmk1ToCa+4+UPTW0x9ou
         HlHxR7zfpmONTivDxyw60E0g968kE9WgacNE9okfXOG9AbR/ZiAzGSlzU6d+aaqMDDDX
         qC7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=dcKNTtASXX61Q+VQr8INe49VkZfJpp38n/5rM4hpO6M=;
        b=aaPO9FKqEEXdeLZMk+2BYf0soRtrTrULfI2WbAfFMGD7XBiDAyZTABIEw88pU9Dod8
         mRCmUm+rTxPmz3tbyDgJEEJZN5ywFbYp5UsQRDXTtyrAF/aJo5d/ROUrjsdYjg1Riax9
         gFhvg9GiP8Kr4YChI+eGAeLF25koBsodoMcziMyVB7B9VeLbWbmWuHd55KJ6pfIu5WwH
         K8UgrUDBSebMP4z1bP7YRXLq9t9oDSAJ+e95lz/Gpta8EQzy8amtdTWQfAPeZMrbvGAT
         fSdsN5EzoW3lByo3AHmbCjCY1ojSUQEo/ljB7xArkfuRKw45s0TFJwCXh+i6KcqaWNh9
         /2dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=L17n4MiM;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor3801703vsp.28.2019.05.17.01.49.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 01:49:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=L17n4MiM;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=dcKNTtASXX61Q+VQr8INe49VkZfJpp38n/5rM4hpO6M=;
        b=L17n4MiMW7VFyQE9PCxCtQ37t2a1Wc5Jn9V0cOf+nXVc7WbgrEA+XNwEHw1OgXi3V7
         QR5kHf/KQyqtT9tgUeeWuaf7EW91762vRWCIxrrkLG0EeghJYGV9+A/HrETuO5I2jVuL
         0alBtY+sHd2baPoT3zytaA3Jh8D+kQmT4m7FxWr21/zZoLv6VBFF/ObluRCJrPTYt/fx
         fCmNr/z0F+W7jB2p3hdd2dcW5Db93F9IseCYmKAwmVMmAZ+qe5+a6ITXxZv9i5MOjlYK
         0LC2uyo6WYi/VcMZiWRCrLFeS/41MURPF4f42J7VREGI9brrmoCceTUeyI/xDEmUIZfI
         lyLw==
X-Google-Smtp-Source: APXvYqzjUD0ahzXEakEX3krc2+ox/87AMfIOaCIz/6rEh7xXajD9IsIsVNzi0hRDQJd9iq5DpU4tQU0ApbW3Gj4ZDrA=
X-Received: by 2002:a67:7241:: with SMTP id n62mr3594300vsc.217.1558082954585;
 Fri, 17 May 2019 01:49:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190514143537.10435-1-glider@google.com> <20190514143537.10435-5-glider@google.com>
 <201905160923.BD3E530EFC@keescook> <201905161714.A53D472D9@keescook>
In-Reply-To: <201905161714.A53D472D9@keescook>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 17 May 2019 10:49:03 +0200
Message-ID: <CAG_fn=Vj6Jk_DY_-0+x6EpbsVh+abpEVcjycBhJxeMH3wuy9rw@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] net: apply __GFP_NO_AUTOINIT to AF_UNIX sk_buff allocations
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 2:26 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Thu, May 16, 2019 at 09:53:01AM -0700, Kees Cook wrote:
> > On Tue, May 14, 2019 at 04:35:37PM +0200, Alexander Potapenko wrote:
> > > Add sock_alloc_send_pskb_noinit(), which is similar to
> > > sock_alloc_send_pskb(), but allocates with __GFP_NO_AUTOINIT.
> > > This helps reduce the slowdown on hackbench in the init_on_alloc mode
> > > from 6.84% to 3.45%.
> >
> > Out of curiosity, why the creation of the new function over adding a
> > gfp flag argument to sock_alloc_send_pskb() and updating callers? (Ther=
e
> > are only 6 callers, and this change already updates 2 of those.)
> >
> > > Slowdown for the initialization features compared to init_on_free=3D0=
,
> > > init_on_alloc=3D0:
> > >
> > > hackbench, init_on_free=3D1:  +7.71% sys time (st.err 0.45%)
> > > hackbench, init_on_alloc=3D1: +3.45% sys time (st.err 0.86%)
>
> So I've run some of my own wall-clock timings of kernel builds (which
> should be an pretty big "worst case" situation, and I see much smaller
> performance changes:
How many cores were you using? I suspect the numbers may vary a bit
depending on that.
> everything off
>         Run times: 289.18 288.61 289.66 287.71 287.67
>         Min: 287.67 Max: 289.66 Mean: 288.57 Std Dev: 0.79
>                 baseline
>
> init_on_alloc=3D1
>         Run times: 289.72 286.95 287.87 287.34 287.35
>         Min: 286.95 Max: 289.72 Mean: 287.85 Std Dev: 0.98
>                 0.25% faster (within the std dev noise)
>
> init_on_free=3D1
>         Run times: 303.26 301.44 301.19 301.55 301.39
>         Min: 301.19 Max: 303.26 Mean: 301.77 Std Dev: 0.75
>                 4.57% slower
>
> init_on_free=3D1 with the PAX_MEMORY_SANITIZE slabs excluded:
>         Run times: 299.19 299.85 298.95 298.23 298.64
>         Min: 298.23 Max: 299.85 Mean: 298.97 Std Dev: 0.55
>                 3.60% slower
>
> So the tuning certainly improved things by 1%. My perf numbers don't
> show the 24% hit you were seeing at all, though.
Note that 24% is the _sys_ time slowdown. The wall time slowdown seen
in this case was 8.34%

> > In the commit log it might be worth mentioning that this is only
> > changing the init_on_alloc case (in case it's not already obvious to
> > folks). Perhaps there needs to be a split of __GFP_NO_AUTOINIT into
> > __GFP_NO_AUTO_ALLOC_INIT and __GFP_NO_AUTO_FREE_INIT? Right now
> > __GFP_NO_AUTOINIT is only checked for init_on_alloc:
>
> I was obviously crazy here. :) GFP isn't present for free(), but a SLAB
> flag works (as was done in PAX_MEMORY_SANITIZE). I'll send the patch I
> used for the above timing test.
>
> --
> Kees Cook



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

