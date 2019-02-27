Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 026CBC00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 09:26:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D6DD2084D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 09:26:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Vh46G7QO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D6DD2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11ABA8E0003; Wed, 27 Feb 2019 04:26:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CB298E0001; Wed, 27 Feb 2019 04:26:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFA408E0003; Wed, 27 Feb 2019 04:26:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8D258E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 04:26:07 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id r136so4689670ith.3
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 01:26:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vstIwG6RGSnFTCdlWq8XlRTKnk2DsAOEgppdnknGPvs=;
        b=IDkR9CclPSVEWdZW33hNCtuS17SSak7bYkTOgpQ+s1BDNZQdOss4FlzTTKDaBx6+fW
         ycQvPNz8Up87k9PyJj6U2Jp22F65sp+NnLLU4RKXgd6sCbqV7MK/YYEP7Z5cjZiYgK1U
         hc6oXvSjt9tFMIqpPu2Po9FySb35/kX6OP5fRwlpXp4HoxBRq/008JRm6FKlODt0hN92
         5hEgdZ7+4BPa71BJ9rA1qpLqJFZuEVwT0rcdn+kEtBSRvgvbKMufWpJMW/NH+NRUCU5w
         /FM2mFSBhTed+bieVUFf518ckzIXdflcee/ZPbNO9Jtv8kN6+3rKDiUDZ96IIBxP/0fH
         Nk9w==
X-Gm-Message-State: AHQUAuYtWSFaKdorJ3wX4LeNAKLfcD5I+OXE5Qh95lh/T194kfKodlL8
	3DJPYiAngKRHaYGVab6G960XpHbTSLn1XdtKlTmi4w9iFs5PFhWmc9lWAgixCkLmasOQaIuUeEy
	O0jl6osTTOBCSKxRiC1kfzyiHEcLVtIuKNm3fXb++3zwidRp1s5V4Jz9efuw7PR0i9qX3UiMK/8
	ofozrGkSYAjzLL3+SHrENFaz6qT/J0KXJtBKO3VKg8H3EAq24jIruzi5WkpvdguUU1zsGW039hU
	OKjlnHnHufNGCI+pAW3SCm81FPj+pqja0dK4WcTsg+OeTHf5raq6usDD3n2L0grWLzD7XjZ10ul
	rIxYDKcApPadvZcT52wc/GvJyqswUcbvEazkhfRxYVY6pNg/YhxB3RdlgSBbl5fw0AqmngGzy1R
	W
X-Received: by 2002:a02:3c07:: with SMTP id m7mr778788jaa.26.1551259567564;
        Wed, 27 Feb 2019 01:26:07 -0800 (PST)
X-Received: by 2002:a02:3c07:: with SMTP id m7mr778760jaa.26.1551259566714;
        Wed, 27 Feb 2019 01:26:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551259566; cv=none;
        d=google.com; s=arc-20160816;
        b=BcQ1M1ErUeu39v3ePWJcpXIxpnRF6eQVflPbYXfKP4mMndBNyEW24jrC0Rr+HriKvd
         tSvOzNHS5xYZzUdVeTk6NaIVmqmC58EcoB8ITw4GBSQF+ncl9R1URahOPYr7QBSFC4cq
         vNjVlNH7Y0HfIU7UGTVwAQwqkso8iwa5u8aWzm2qXhZIfM1OPIf1ph8RLcJYJjkDAC1s
         xfIfS2nI5fU4VmdggKs7wg2pMPTSvOtGWCyiYwsH7DmGhvQJHffctLV0Pem05geh3lye
         oWuaEevsbL2PUstmhPKSMFfuDBjXNKyStACtdn1yAEzHx/msxlhCb/ga6N+nxxt6+7a1
         JABg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vstIwG6RGSnFTCdlWq8XlRTKnk2DsAOEgppdnknGPvs=;
        b=x6/D7PRRtJDdNfuYDKMcynnEk4kknVk9lUjT4Ts/WCxJxGXQhoYO2Qxg05nA901Ko+
         IDc5ciPbMaFGee/kbW527I+ndSv4jC4pTsA8NNlPdx4qTz7xtJgynHQtX99FFcdpmaZj
         mrR0hxVrp7R3u2dj7uxSuIPIQyc1Bwv9n7qSFxLt6pw6trIM1tSkLdRQVJjAst+LOif9
         FSrlxt5l1jSbFLexwqVVcxPs/Zwe2IS9lNc9puVvtwUs0PNW4PBlY9VhzuNNRJPF77gU
         +q02STIjdArliY22jg3dYgAWDorLHY2I0W7xsYsJgrsqCiisws00sv20wkjwSLsBFfNZ
         bOGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Vh46G7QO;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9sor6059224iod.121.2019.02.27.01.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 01:26:06 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Vh46G7QO;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vstIwG6RGSnFTCdlWq8XlRTKnk2DsAOEgppdnknGPvs=;
        b=Vh46G7QO6H7EXlWkJhKTMtownvl9a1V7KKNdJDBgDZk02XlTWlJxxhVKDg0z5uxRiP
         N1wFOppgtnTZXbAR/2oTV3N2cwau/gmV/+qylFxNig36ygJ3F3gY323BltjgIi1xksmN
         ygxHb9r7RciVIJedUy60aQSoiStCpa5YhPGSJIdlIAi1TQkzrxKbbdnVpKO5kMT9wBuH
         DmqdbW1unCNNT5NoGrvqFR2U+bLh0KoXfzJfqxKfeGRqQ/Hcx/x8fvmpFA/Conh+qQo0
         +IOwOAFkmMp1SO9lDj6cnUHBTV/l/tUEUk3yx8SFflwQ6qZCM1RVVr5IctsKZJuTg8/A
         iBvg==
X-Google-Smtp-Source: APXvYqz8Ud+yQay/ozIws7gBzBnivarDRgoEFhbeiVox0MBaF1zqZZ20aEerwyjMiQn7Y3x15Db/8X4R0sL7i5irt2E=
X-Received: by 2002:a5d:834a:: with SMTP id q10mr1306903ior.271.1551259566125;
 Wed, 27 Feb 2019 01:26:06 -0800 (PST)
MIME-Version: 1.0
References: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr> <5f0203bd-77ea-d94c-11b7-1befba439cd4@virtuozzo.com>
In-Reply-To: <5f0203bd-77ea-d94c-11b7-1befba439cd4@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 27 Feb 2019 10:25:54 +0100
Message-ID: <CACT4Y+Ze0Ezi4uKVZR1nk_EOjNcHd=JLhYq8ahqbfOL_8Jq9iw@mail.gmail.com>
Subject: Re: BUG: KASAN: stack-out-of-bounds
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>, Alexander Potapenko <glider@google.com>, 
	Daniel Axtens <dja@axtens.net>, Linux-MM <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, 
	kasan-dev <kasan-dev@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 10:18 AM Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> On 2/27/19 11:25 AM, Christophe Leroy wrote:
> > With version v8 of the series implementing KASAN on 32 bits powerpc (https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=94309), I'm now able to activate KASAN on a mac99 is QEMU.
> >
> > Then I get the following reports at startup. Which of the two reports I get seems to depend on the option used to build the kernel, but for a given kernel I always get the same report.
> >
> > Is that a real bug, in which case how could I spot it ? Or is it something wrong in my implementation of KASAN ?
> >
> > I checked that after kasan_init(), the entire shadow memory is full of 0 only.
> >
> > I also made a try with the strong STACK_PROTECTOR compiled in, but no difference and nothing detected by the stack protector.
> >
> > ==================================================================
> > BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
> > Read of size 1 at addr c0ecdd40 by task swapper/0
> >
> > CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1133
> > Call Trace:
> > [c0e9dca0] [c01c42a0] print_address_description+0x64/0x2bc (unreliable)
> > [c0e9dcd0] [c01c4684] kasan_report+0xfc/0x180
> > [c0e9dd10] [c089579c] memchr+0x24/0x74
> > [c0e9dd30] [c00a9e38] msg_print_text+0x124/0x574
> > [c0e9dde0] [c00ab710] console_unlock+0x114/0x4f8
> > [c0e9de40] [c00adc60] vprintk_emit+0x188/0x1c4
> > --- interrupt: c0e9df00 at 0x400f330
> >     LR = init_stack+0x1f00/0x2000
> > [c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
> > [c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
> > [c0e9df50] [c0c16434] start_kernel+0x310/0x488
> > [c0e9dff0] [00003484] 0x3484
> >
> > The buggy address belongs to the variable:
> >  __log_buf+0xec0/0x4020
> > The buggy address belongs to the page:
> > page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
> > flags: 0x1000(reserved)
> > raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff 00000001
> > page dumped because: kasan: bad access detected
> >
> > Memory state around the buggy address:
> >  c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >  c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
> >                                    ^
> >  c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
> >  c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> > ==================================================================
> >
>
> This one doesn't look good. Notice that it says stack-out-of-bounds, but at the same time there is
>         "The buggy address belongs to the variable:  __log_buf+0xec0/0x4020"
>  which is printed by following code:
>         if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
>                 pr_err("The buggy address belongs to the variable:\n");
>                 pr_err(" %pS\n", addr);
>         }
>
> So the stack unrelated address got stack-related poisoning. This could be a stack overflow, did you increase THREAD_SHIFT?
> KASAN with stack instrumentation significantly increases stack usage.

A straightforward explanation would be that this happens before real
shadow is mapped and we don't turn off KASAN reports. Should be easy
to check so worth eliminating this possibility before any other
debugging.

