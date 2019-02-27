Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C507C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 08:34:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4082921852
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 08:34:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mo00MrN8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4082921852
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5EF18E0003; Wed, 27 Feb 2019 03:34:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0FF68E0001; Wed, 27 Feb 2019 03:34:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D24FB8E0003; Wed, 27 Feb 2019 03:34:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id ABE6A8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 03:34:45 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id j18so4349894itl.6
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 00:34:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0xHuew9n2ZaXfGGIT1bL+6hd0S3FId/K5bsv3ThAwsM=;
        b=No+GugzrgWC1EXTKIGCJQks9Rxz2/h78lcjBEMGuN6xkMbAr/hqHnVh8DQ9nTbUBoM
         NRXB53y74HewDEaMSeA8dVBTdsDV2HTx2oMcpCbBDNBEORMVmDV8NPg1R7kr4siAgarC
         mwtDAxVLadD8SMsKy3qR4wyRoVkZa90MUOfIKrqviHW+1DGkbISzXu2tmOmidjfaxSOZ
         QeB7jd//fzv8K85YMVJDwqgiXJ46hZjRz+Av2lcor33EpPEvV6WW77PJvqK2NXgP8r47
         Hnli+a5NSNRuanj4yUh7+fwVduxYNPJpiFhjNhethQ8XLo9TeEny2crscPlAFhiqhSiS
         jxyw==
X-Gm-Message-State: APjAAAVjsacvIdp0Jp9fZDTKKJlpEPw3peJdx6GXkkubdvXVJV50q3Li
	67fUelSIe4wNmnmMRiZHr5NAJF284h7nb44ypJ0LQg+X6y5+3Kz/Sz1KB7tEiE6da8fV+2TBsn9
	zWGL7mIyh9TZK+8521g/CVcFsYFqObjhmXxLi9pGYktE6/vhJ5mXuOH6SnWDm73GYjDRuukSXai
	zpZB/mZ3V/kE4YQX3SyUBd+rUVFWiX1oar9HiVRQeeY7LPc/2iq3DITH3GF3Og2nykmulIwkO5q
	f+KYhOrHiFJ5Pmkh+XnFuOYsWIfegERgPmRlmYXRjeBE/hKxEBCkpmVWaOBy6LN+D025/xZ/FTR
	eg1Vt5PoV3ORoQZq6fT2i5Kt6syIVx4GXVIRzAwERRHdLbpMUX4ChYYovw0HtL06sZqbGqEJE1m
	P
X-Received: by 2002:a5d:8982:: with SMTP id m2mr1498055iol.164.1551256485420;
        Wed, 27 Feb 2019 00:34:45 -0800 (PST)
X-Received: by 2002:a5d:8982:: with SMTP id m2mr1498004iol.164.1551256483961;
        Wed, 27 Feb 2019 00:34:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551256483; cv=none;
        d=google.com; s=arc-20160816;
        b=LOw7NL3NcgGH6BzxFcQBQhC6rCVUnpCcsaZhm3vSW07hT1GMtpIzbr3rpcWyXh5ayO
         KJRizTuYRjaq22RFNW10q58ewyuxUY81JrkTMiWzZRIxKFrwAJVuN2pAL1wQfMoDgi5M
         ko+ZbcWt2jZZJ8oR1f2ok8ulhipJDonSIrLFEJW3beGa3Rh5QQQPbHnV1ZRygrxhCBdA
         iJKCB6GBf+y50NITWkZHLvCvQKRlKWsAhVk9cxPwTUuK2TK5Hf7nZOyevQDTtMcfu0H7
         yH8qVdsmbmNn0wNWggL04tgP+l2XE39x5N59vOCMH/LCZdezHbXY+JKBPEiKV3j6GZbk
         KH5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0xHuew9n2ZaXfGGIT1bL+6hd0S3FId/K5bsv3ThAwsM=;
        b=N6B9CVb4QzadY00AG5ZuWX6PvBDzVkMjhthJajHcv8eN0WMFV+HKCIhubiZart/AFo
         nZpxMjAMp8GIfQw2cRevmqJK1b9mQ3ne77Dolcve/Gd/Sva8G/sZQIhSKtcA9lSh3SRE
         /fdro5KkArCohESZXA4SnXMv5+dGU6gtv+wZjRj4NgDL2nUKqKb4n3kZWKD2kV8VlPf/
         uLZ2plNEUdu9LBia+tGMFxUTKyWkQWRO8QeF5qVCgZTLXNn9FvC0q6EJK05Zlj3b9cZJ
         tsrNmvObIHIKWw5rwZ3tzIorSI/cfGJyEaVwqWTe6hrm2YCLiRhhG1KfzxeamBWnzHd3
         Rj5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mo00MrN8;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j12sor6306959ioo.0.2019.02.27.00.34.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 00:34:43 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mo00MrN8;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0xHuew9n2ZaXfGGIT1bL+6hd0S3FId/K5bsv3ThAwsM=;
        b=mo00MrN8/7REJ8h76ktNdA8Uslsjug59G7WpvfLrHnkmKpAZk/UlbXfrVhqFvk2okI
         91dkFw4rZADxMk20Gik8HHgtJlAe76XrdhT6GWznd3FPxf0Gv1Ti0E4qc72QObMuZmLR
         COxbXo0PzLNBj7UvBEQLKumeTawBEIr5Owe7T47opXpME5sCBKMhHWqWevFuYuo8lnR+
         PvNWejRIb6ggcD5O2N4vsobeFT7ZNBVEVoRy5fpT5fMfin+traileTjABSjSmekF0lbk
         KLX9tqoLpxWOqkGjXXZO5VJBA1oTsH/w2bws4mmsR3hOZRwKmZ1v+6DDtfsmIhf2zPPq
         RmZA==
X-Google-Smtp-Source: APXvYqzoFpWZLN/LYuyTaNPIHi42vvzMbUJ8NtJN84VsWy2k2bBcGxk+Kb7P1M5/Tgl1vV3odNLM3A0ZWOAjoviPg2I=
X-Received: by 2002:a5d:84c3:: with SMTP id z3mr1340885ior.11.1551256483219;
 Wed, 27 Feb 2019 00:34:43 -0800 (PST)
MIME-Version: 1.0
References: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr>
In-Reply-To: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 27 Feb 2019 09:34:32 +0100
Message-ID: <CACT4Y+bTBGfsLq+bE9-no8sj8yvrkPN6iaELZMi7DX4Vr59zrA@mail.gmail.com>
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

On Wed, Feb 27, 2019 at 9:25 AM Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
>
> With version v8 of the series implementing KASAN on 32 bits powerpc
> (https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=94309),
> I'm now able to activate KASAN on a mac99 is QEMU.
>
> Then I get the following reports at startup. Which of the two reports I
> get seems to depend on the option used to build the kernel, but for a
> given kernel I always get the same report.
>
> Is that a real bug, in which case how could I spot it ? Or is it
> something wrong in my implementation of KASAN ?

What is the state of your source tree?
Please pass output through some symbolization script, function offsets
are not too useful.
There was some in scripts/ dir IIRC, but here is another one (though,
never tested on powerpc):
https://github.com/google/sanitizers/blob/master/address-sanitizer/tools/kasan_symbolize.py



> I checked that after kasan_init(), the entire shadow memory is full of 0
> only.
>
> I also made a try with the strong STACK_PROTECTOR compiled in, but no
> difference and nothing detected by the stack protector.
>
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
> Read of size 1 at addr c0ecdd40 by task swapper/0
>
> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1133
> Call Trace:
> [c0e9dca0] [c01c42a0] print_address_description+0x64/0x2bc (unreliable)
> [c0e9dcd0] [c01c4684] kasan_report+0xfc/0x180
> [c0e9dd10] [c089579c] memchr+0x24/0x74
> [c0e9dd30] [c00a9e38] msg_print_text+0x124/0x574
> [c0e9dde0] [c00ab710] console_unlock+0x114/0x4f8
> [c0e9de40] [c00adc60] vprintk_emit+0x188/0x1c4
> --- interrupt: c0e9df00 at 0x400f330
>      LR = init_stack+0x1f00/0x2000
> [c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
> [c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
> [c0e9df50] [c0c16434] start_kernel+0x310/0x488
> [c0e9dff0] [00003484] 0x3484
>
> The buggy address belongs to the variable:
>   __log_buf+0xec0/0x4020
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
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1ec/0x600
> Read of size 1 at addr f6f37de0 by task swapper/0
>
> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1134
> Call Trace:
> [c0ff7d60] [c01fe808] print_address_description+0x6c/0x2b0 (unreliable)
> [c0ff7d90] [c01fe4fc] kasan_report+0x13c/0x1ac
> [c0ff7dd0] [c0d34324] pmac_nvram_init+0x1ec/0x600
> [c0ff7ef0] [c0d31148] pmac_setup_arch+0x280/0x308
> [c0ff7f20] [c0d2c30c] setup_arch+0x250/0x280
> [c0ff7f50] [c0d26354] start_kernel+0xb8/0x4d8
> [c0ff7ff0] [00003484] 0x3484
>
>
> Memory state around the buggy address:
>   f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>   f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  >f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
>                                                 ^
>   f6f37e00: 00 00 00 00 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
>   f6f37e80: 00 00 01 f2 00 00 00 00 00 00 00 00 00 00 00 00
> ==================================================================
>
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in memchr+0xa0/0xac
> Read of size 1 at addr c17cdd30 by task swapper/0
>
> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1135
> Call Trace:
> [c179dc90] [c032fe28] print_address_description+0x64/0x2bc (unreliable)
> [c179dcc0] [c033020c] kasan_report+0xfc/0x180
> [c179dd00] [c115ef50] memchr+0xa0/0xac
> [c179dd20] [c01297f8] msg_print_text+0xc8/0x67c
> [c179ddd0] [c012bc8c] console_unlock+0x17c/0x818
> [c179de40] [c012f420] vprintk_emit+0x188/0x1c4
> --- interrupt: c179df30 at 0x400def0
>      LR = init_stack+0x1ef0/0x2000
> [c179de80] [c012fff0] printk+0xa8/0xcc (unreliable)
> [c179df20] [c150b4b8] early_irq_init+0x38/0x108
> [c179df50] [c14ef7f8] start_kernel+0x30c/0x530
> [c179dff0] [00003484] 0x3484
>
> The buggy address belongs to the variable:
>   __log_buf+0xeb0/0x4020
> The buggy address belongs to the page:
> page:c6ebe9a0 count:1 mapcount:0 mapping:00000000 index:0x0
> flags: 0x1000(reserved)
> raw: 00001000 c6ebe9a4 c6ebe9a4 00000000 00000000 00000000 ffffffff 00000001
> page dumped because: kasan: bad access detected
>
> Memory state around the buggy address:
>   c17cdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>   c17cdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  >c17cdd00: 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00 f3 f3
>                               ^
>   c17cdd80: f3 f3 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>   c17cde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ==================================================================
>
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x228/0xae0
> Read of size 1 at addr f6f37dd0 by task swapper/0
>
> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1136
> Call Trace:
> [c1c37d50] [c03f7e88] print_address_description+0x6c/0x2b0 (unreliable)
> [c1c37d80] [c03f7bd4] kasan_report+0x10c/0x16c
> [c1c37dc0] [c19879b4] pmac_nvram_init+0x228/0xae0
> [c1c37ef0] [c19826bc] pmac_setup_arch+0x578/0x6a8
> [c1c37f20] [c19792bc] setup_arch+0x5f4/0x620
> [c1c37f50] [c196f898] start_kernel+0xb8/0x588
> [c1c37ff0] [00003484] 0x3484
>
>
> Memory state around the buggy address:
>   f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>   f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  >f6f37d80: 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00
>                                           ^
>   f6f37e00: 01 f2 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2 00 00
>   f6f37e80: 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00
> ==================================================================
>
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1ec/0x5ec
> Read of size 1 at addr f6f37de0 by task swapper/0
>
> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1137
> Call Trace:
> [c0fb7d60] [c01f8184] print_address_description+0x6c/0x2b0 (unreliable)
> [c0fb7d90] [c01f7ed0] kasan_report+0x10c/0x16c
> [c0fb7dd0] [c0d1dfe8] pmac_nvram_init+0x1ec/0x5ec
> [c0fb7ef0] [c0d1ae90] pmac_setup_arch+0x280/0x308
> [c0fb7f20] [c0d16138] setup_arch+0x250/0x280
> [c0fb7f50] [c0d1032c] start_kernel+0xb8/0x4a4
> [c0fb7ff0] [00003484] 0x3484
>
>
> Memory state around the buggy address:
>   f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>   f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  >f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
>                                                 ^
>   f6f37e00: 00 00 01 f2 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
>   f6f37e80: 00 00 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00
> ==================================================================
>
> Thanks
> Christophe

