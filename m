Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89720C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 13:07:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AA3C20C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 13:07:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cR86z1aw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AA3C20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBB768E0003; Wed, 27 Feb 2019 08:07:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B69D58E0001; Wed, 27 Feb 2019 08:07:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A32BC8E0003; Wed, 27 Feb 2019 08:07:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 752FF8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 08:07:40 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id d7so12793245ios.17
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 05:07:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PA9woRu5kKn7QtKedsBhYpbbgQu1kMY8Ss1/zmi/5II=;
        b=TyW3BckROGohCe4NqBDvzugsHxLEp5+/j4x7hTwDbov7vfyHLknTZfsYg+Ac3P9sQQ
         FbWPceh10ivRPnkY+H1K1PnQeLbCvx4Y8Ayu2/AUc2MItwInGPrI1AHfLhVqg4Q2LUSn
         i8NPAPJFQq8wWTCR1ie9MF1U8NJskMJrLq435r1eoShT72Bulu/8IFLTZiC1u8DP5Cvj
         zWtUtM3tMaWKGO/5cGT4sXqc3C/m+vRxQdNX6DbRuZEBLK4CYrO/gWKa42IGtL2T1byJ
         mpxJm1p7NuOLKLNfLKlHXn5x5wPkqSoRLOtmoFhMr8HSiROQ22Co+0lW8GcYqFvIJIst
         heWw==
X-Gm-Message-State: APjAAAUwncOaXYRifzyTGvOn+CHdkh9VwD5L7v8309luJXcF3IQuaH0B
	EF3WDUdt/Wx1q+jeidAhdsO44VpV+hPCdK4/s+9FviZgyv7f/YfbjjUIyVjHLha186HG1u7wxkA
	2j82bGj3z1ZmCsDcQnpwOKxtCbvJJsLeSgdD2C91rR/nhZ1en0TdNb+o9CZ60+PSxXC6inMBEDY
	mQAZlD15xCwxkM536IBkyHUlpPnWQJrjlJh2O5L9IEysle3ua0OfGAOoL4lhfCG4dmpEEr5HpRS
	0vBSmMjUqI8Rip+y4eZhCSYVcEEeoWv4b9p3h9QtwtsXcvu2GJN/mhuj7/rTi3CA6CyWEudCKnD
	swsEE1KFRJKU/8KDVtXRjtbQgu0TpOz1wolcFAoa6qnm3ont6/0gXehmIKZzupY/W+xzYw0q7zI
	p
X-Received: by 2002:a5d:9b01:: with SMTP id y1mr1783276ion.167.1551272860196;
        Wed, 27 Feb 2019 05:07:40 -0800 (PST)
X-Received: by 2002:a5d:9b01:: with SMTP id y1mr1783220ion.167.1551272858896;
        Wed, 27 Feb 2019 05:07:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551272858; cv=none;
        d=google.com; s=arc-20160816;
        b=vpJvJe1mCt6qIkfZfZpGh7tkejwkS0uRXbVcTIbMtcGwCFKNVscWQEYGzYHQ8QLE2j
         IjcNz+++q60OKCfXuUhuLeUjPTAQsV0stZRqIS7ws/pRVb6y9p6PYV1r1KnOdJ24xgYQ
         uThtmiuEg1rIogn++uYaL3NYkW9CBAytBo/oWsD8RgA6sfn+7vHsXYdLYbQMJrqaV2J9
         0ZZI9/cqtfrtT+LU+Ic7IJgnoXuh5QkChRJoAPzA4kWaV6DcuLcGjjp8U9525dzrtiOJ
         PRy/zGN5ZPoDvcKUSutV3yi10XrZZilsfkQR/leY4wD1dDvW/i6IzkboW4JVUGzrMwEP
         /ZDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PA9woRu5kKn7QtKedsBhYpbbgQu1kMY8Ss1/zmi/5II=;
        b=sdfxQhXtJv5khgSmQ8vaH+Oflk1mb6KV/2C5H33TINZ6o5L9yvBCTq5DMUZE+8hD69
         480Z8ebxGffxj30NT6dEP4IbZloH4dnAZglh+lNKwEwRtQW9jOtGLsle1BN+09xR6sZP
         Vj4PTwoh9R1PrvnDge5w+VSEHhW3VtxjvIbuDnuC+lPsT9dyY6JCAm7DJ8hUlnsXF/DF
         +ngLKQBnDkG1cmA6IXP2FEMnMVzroDEnOZ+crdJ6yIjFNUEQAnI2CnaDdMvxEEsn2uGh
         qDJgJtteAS3SLp7qYimgiIuD3vA7QFpL5FvHPkDepv9DAJjIxrkZhJlWZ6H854h54myo
         MgQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cR86z1aw;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10sor7213721iol.85.2019.02.27.05.07.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 05:07:38 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cR86z1aw;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PA9woRu5kKn7QtKedsBhYpbbgQu1kMY8Ss1/zmi/5II=;
        b=cR86z1awTP6Kf3HVNs2tt9u1XcQkxK5Y72NX3ekEfMgdJZ+OG5UZBwKrJKc/x5SRNm
         aw7U9JxWAI+kcrsJj36kBtr56HyTr2V4bRD/he9Jgj0DgrLePYzcbLbPR3PGepZ/LW6o
         Ofj8GBuHULHQYYtsJ39PhTmtE5hQRotw40mk/F/9tnBMC3pjwlXCX8ge8qCdnmUkkiSi
         0xBSfLL0W65HxV8DJ1tZzqAneEcCxh8QWzLo7Ie+59AmOen4fZQPPJT1YML5m0msJPrA
         Pzu4yRl5zz4V09t2fOLdacj1jHxcDmi9fWOrS8CU+LrM62ybOmgYjy29qvTyLyajAN7z
         81Cw==
X-Google-Smtp-Source: APXvYqzMWoXzKSxQgMDIJMVo7CSM/fIqNn/CAsYm4zjwj/MDZusxM+U0Z2JM0KGvE/+3XSWTHr5TMuoe3H8pAUcIebc=
X-Received: by 2002:a5d:84c3:: with SMTP id z3mr1885720ior.11.1551272858164;
 Wed, 27 Feb 2019 05:07:38 -0800 (PST)
MIME-Version: 1.0
References: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr> <CACT4Y+bTBGfsLq+bE9-no8sj8yvrkPN6iaELZMi7DX4Vr59zrA@mail.gmail.com>
 <5c8058fe-ac6a-2b50-3d52-fe89bb48b6f5@c-s.fr>
In-Reply-To: <5c8058fe-ac6a-2b50-3d52-fe89bb48b6f5@c-s.fr>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 27 Feb 2019 14:07:26 +0100
Message-ID: <CACT4Y+YJY-RG_cX5sZ1TieJaV7Vg+xdY7pviUNCoQpUrNXctSA@mail.gmail.com>
Subject: Re: BUG: KASAN: stack-out-of-bounds
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Daniel Axtens <dja@axtens.net>, Linux-MM <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, 
	kasan-dev <kasan-dev@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 1:35 PM Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
>
>
>
> On 02/27/2019 08:34 AM, Dmitry Vyukov wrote:
> > On Wed, Feb 27, 2019 at 9:25 AM Christophe Leroy
> > <christophe.leroy@c-s.fr> wrote:
> >>
> >> With version v8 of the series implementing KASAN on 32 bits powerpc
> >> (https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=94309),
> >> I'm now able to activate KASAN on a mac99 is QEMU.
> >>
> >> Then I get the following reports at startup. Which of the two reports I
> >> get seems to depend on the option used to build the kernel, but for a
> >> given kernel I always get the same report.
> >>
> >> Is that a real bug, in which case how could I spot it ? Or is it
> >> something wrong in my implementation of KASAN ?
> >
> > What is the state of your source tree?
> > Please pass output through some symbolization script, function offsets
> > are not too useful.
> > There was some in scripts/ dir IIRC, but here is another one (though,
> > never tested on powerpc):
> > https://github.com/google/sanitizers/blob/master/address-sanitizer/tools/kasan_symbolize.py
>
> I get the following. It doesn't seem much interesting, does it ?


Yes, it does not seem to work for powerpc32.
Then please pass addresses through addr2line -fi.



> ==================================================================
> BUG: KASAN: stack-out-of-bounds in[<        none        >]
> memchr+0x24/0x74 lib/string.c:958
> Read of size 1 at addr c0ecdd40 by task swapper/0
>
> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1142
> Call Trace:
> [c0e9dca0] [c01c42c0] print_address_description+0x64/0x2bc (unreliable)
> [c0e9dcd0] [c01c46a4] kasan_report+0xfc/0x180
> [c0e9dd10] [c0895150] memchr+0x24/0x74
> [c0e9dd30] [c00a9e58] msg_print_text+0x124/0x574
> [c0e9dde0] [c00ab730] console_unlock+0x114/0x4f8
> [c0e9de40] [c00adc80] vprintk_emit+0x188/0x1c4
> [c0e9de80] [c00ae3e4] printk+0xa8/0xcc
> [c0e9df20] [c0c27e44] early_irq_init+0x38/0x108
> [c0e9df50] [c0c15434] start_kernel+0x310/0x488
> [c0e9dff0] [00003484] 0x3484
>
> The buggy address belongs to the variable:
> [<        none        >] __log_buf+0xec0/0x4020
> arch/powerpc/kernel/head_32.S:?
> The buggy address belongs to the page:
> page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
> flags: 0x1000(reserved)
> raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff 00000001
> page dumped because: kasan: bad access detected
>
> Memory state around the buggy address:
>   c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>   c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  >c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
>                                     ^
>   c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
>   c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ==================================================================
>
>
> Christophe
>
> >
> >
> >
> >> I checked that after kasan_init(), the entire shadow memory is full of 0
> >> only.
> >>
> >> I also made a try with the strong STACK_PROTECTOR compiled in, but no
> >> difference and nothing detected by the stack protector.
> >>
> >> ==================================================================
> >> BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
> >> Read of size 1 at addr c0ecdd40 by task swapper/0
> >>
> >> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1133
> >> Call Trace:
> >> [c0e9dca0] [c01c42a0] print_address_description+0x64/0x2bc (unreliable)
> >> [c0e9dcd0] [c01c4684] kasan_report+0xfc/0x180
> >> [c0e9dd10] [c089579c] memchr+0x24/0x74
> >> [c0e9dd30] [c00a9e38] msg_print_text+0x124/0x574
> >> [c0e9dde0] [c00ab710] console_unlock+0x114/0x4f8
> >> [c0e9de40] [c00adc60] vprintk_emit+0x188/0x1c4
> >> --- interrupt: c0e9df00 at 0x400f330
> >>       LR = init_stack+0x1f00/0x2000
> >> [c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
> >> [c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
> >> [c0e9df50] [c0c16434] start_kernel+0x310/0x488
> >> [c0e9dff0] [00003484] 0x3484
> >>
> >> The buggy address belongs to the variable:
> >>    __log_buf+0xec0/0x4020
> >> The buggy address belongs to the page:
> >> page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
> >> flags: 0x1000(reserved)
> >> raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff 00000001
> >> page dumped because: kasan: bad access detected
> >>
> >> Memory state around the buggy address:
> >>    c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>    c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>   >c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
> >>                                      ^
> >>    c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
> >>    c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >> ==================================================================
> >>
> >> ==================================================================
> >> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1ec/0x600
> >> Read of size 1 at addr f6f37de0 by task swapper/0
> >>
> >> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1134
> >> Call Trace:
> >> [c0ff7d60] [c01fe808] print_address_description+0x6c/0x2b0 (unreliable)
> >> [c0ff7d90] [c01fe4fc] kasan_report+0x13c/0x1ac
> >> [c0ff7dd0] [c0d34324] pmac_nvram_init+0x1ec/0x600
> >> [c0ff7ef0] [c0d31148] pmac_setup_arch+0x280/0x308
> >> [c0ff7f20] [c0d2c30c] setup_arch+0x250/0x280
> >> [c0ff7f50] [c0d26354] start_kernel+0xb8/0x4d8
> >> [c0ff7ff0] [00003484] 0x3484
> >>
> >>
> >> Memory state around the buggy address:
> >>    f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>    f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>   >f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
> >>                                                  ^
> >>    f6f37e00: 00 00 00 00 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
> >>    f6f37e80: 00 00 01 f2 00 00 00 00 00 00 00 00 00 00 00 00
> >> ==================================================================
> >>
> >> ==================================================================
> >> BUG: KASAN: stack-out-of-bounds in memchr+0xa0/0xac
> >> Read of size 1 at addr c17cdd30 by task swapper/0
> >>
> >> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1135
> >> Call Trace:
> >> [c179dc90] [c032fe28] print_address_description+0x64/0x2bc (unreliable)
> >> [c179dcc0] [c033020c] kasan_report+0xfc/0x180
> >> [c179dd00] [c115ef50] memchr+0xa0/0xac
> >> [c179dd20] [c01297f8] msg_print_text+0xc8/0x67c
> >> [c179ddd0] [c012bc8c] console_unlock+0x17c/0x818
> >> [c179de40] [c012f420] vprintk_emit+0x188/0x1c4
> >> --- interrupt: c179df30 at 0x400def0
> >>       LR = init_stack+0x1ef0/0x2000
> >> [c179de80] [c012fff0] printk+0xa8/0xcc (unreliable)
> >> [c179df20] [c150b4b8] early_irq_init+0x38/0x108
> >> [c179df50] [c14ef7f8] start_kernel+0x30c/0x530
> >> [c179dff0] [00003484] 0x3484
> >>
> >> The buggy address belongs to the variable:
> >>    __log_buf+0xeb0/0x4020
> >> The buggy address belongs to the page:
> >> page:c6ebe9a0 count:1 mapcount:0 mapping:00000000 index:0x0
> >> flags: 0x1000(reserved)
> >> raw: 00001000 c6ebe9a4 c6ebe9a4 00000000 00000000 00000000 ffffffff 00000001
> >> page dumped because: kasan: bad access detected
> >>
> >> Memory state around the buggy address:
> >>    c17cdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>    c17cdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>   >c17cdd00: 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00 f3 f3
> >>                                ^
> >>    c17cdd80: f3 f3 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>    c17cde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >> ==================================================================
> >>
> >> ==================================================================
> >> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x228/0xae0
> >> Read of size 1 at addr f6f37dd0 by task swapper/0
> >>
> >> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1136
> >> Call Trace:
> >> [c1c37d50] [c03f7e88] print_address_description+0x6c/0x2b0 (unreliable)
> >> [c1c37d80] [c03f7bd4] kasan_report+0x10c/0x16c
> >> [c1c37dc0] [c19879b4] pmac_nvram_init+0x228/0xae0
> >> [c1c37ef0] [c19826bc] pmac_setup_arch+0x578/0x6a8
> >> [c1c37f20] [c19792bc] setup_arch+0x5f4/0x620
> >> [c1c37f50] [c196f898] start_kernel+0xb8/0x588
> >> [c1c37ff0] [00003484] 0x3484
> >>
> >>
> >> Memory state around the buggy address:
> >>    f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>    f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>   >f6f37d80: 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00
> >>                                            ^
> >>    f6f37e00: 01 f2 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2 00 00
> >>    f6f37e80: 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00
> >> ==================================================================
> >>
> >> ==================================================================
> >> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1ec/0x5ec
> >> Read of size 1 at addr f6f37de0 by task swapper/0
> >>
> >> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1137
> >> Call Trace:
> >> [c0fb7d60] [c01f8184] print_address_description+0x6c/0x2b0 (unreliable)
> >> [c0fb7d90] [c01f7ed0] kasan_report+0x10c/0x16c
> >> [c0fb7dd0] [c0d1dfe8] pmac_nvram_init+0x1ec/0x5ec
> >> [c0fb7ef0] [c0d1ae90] pmac_setup_arch+0x280/0x308
> >> [c0fb7f20] [c0d16138] setup_arch+0x250/0x280
> >> [c0fb7f50] [c0d1032c] start_kernel+0xb8/0x4a4
> >> [c0fb7ff0] [00003484] 0x3484
> >>
> >>
> >> Memory state around the buggy address:
> >>    f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>    f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>   >f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
> >>                                                  ^
> >>    f6f37e00: 00 00 01 f2 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
> >>    f6f37e80: 00 00 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00
> >> ==================================================================
> >>
> >> Thanks
> >> Christophe

