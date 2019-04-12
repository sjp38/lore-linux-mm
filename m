Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED7B9C10F14
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:33:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0954218A3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:33:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="b29dvSdD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0954218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CC926B027A; Fri, 12 Apr 2019 11:33:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47A476B027C; Fri, 12 Apr 2019 11:33:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 344C76B027D; Fri, 12 Apr 2019 11:33:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id C21996B027A
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:33:00 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id p13so1359865lfc.4
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:33:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NXbKfjDtbjJTyw5Ef0Kix1bfyNOyzTYwEKpGgqOg0TQ=;
        b=XIkGh3ifzmpb4oZ+wfWNtyiuWZmevAg/y4wvwo4w8CDlBap8CVCVq0FeE7BF0sIlBd
         RaVcufsZH1FtKuZTwL/SSK9Isch/Nh0YjoFTTDeDlzClP7OjXOcUmpzqiYpXcmDAhCZQ
         EzNWiZP0bzGWvMBgUezcBth4M7FgwhP/wpy/pBhubRHCfQNFJIzrrLSSeO/0oeSHJj8u
         oUg5hA5wEGlp5g7HI9HzwrUmIWb8DQmV06xRrTW9RSNgLU1Ms82ucImSoZNuPUIE0vZP
         G42oI3isuBDiTKBvhyYEUz5bEFocYXROpLfB372Dt2dlEvNcXb+4XtIrJVSYs15geEFH
         mwUg==
X-Gm-Message-State: APjAAAWebG1OuR+h5r9ZdZVR5nZXsfiPxrJG+JVQIMSqT13t2tashNX+
	n7Ra75wfe/vSaHlBP0JbKEdG3YLVkYdZyefuS5dYgVoY9C/I/0qefu4Dv/hIaCtKqRGTygYNEfY
	i8ycnXKijA6PAKR4R/cs3nHe+Hn00poWOvLITFp1tQMH0Mr08v78QUx7nmnpIirZfYQ==
X-Received: by 2002:ac2:4119:: with SMTP id b25mr12970860lfi.72.1555083179678;
        Fri, 12 Apr 2019 08:32:59 -0700 (PDT)
X-Received: by 2002:ac2:4119:: with SMTP id b25mr12970816lfi.72.1555083178779;
        Fri, 12 Apr 2019 08:32:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555083178; cv=none;
        d=google.com; s=arc-20160816;
        b=At2uk1aIFc8jmWKCja7JRdLWHWx7lrHeYN0Q858hB6Z3+V+gH6JGL9G9XY6+uh9nfa
         rTBwZH+PQMsX7Wyh1MUg05srpR8jMYz3pDakGBmRNYLy0zQL1I3yUsb7VR1L1kY6bGAG
         +8iCi8sm0M5ASfSvwoRauoxdIZUEyQrhPA19einCtItDSQ/hC+QHlTac/3/yeijlJ5Vt
         VMTI2KkuiRiXIVFfWXjy1C3A4ljp4tACZo3pAIlnpnygvL/caZ90+fGPuRe6LIMQlO66
         sk59zu7GtU/SkAeFT3YT/0J5fb2D63Cz0NnLO91za5BSKOJKeWPwdiIAOm77dY1mIjUk
         Rl3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NXbKfjDtbjJTyw5Ef0Kix1bfyNOyzTYwEKpGgqOg0TQ=;
        b=Ch/m/i5MtSMFu3m7FYCTtMn3t2q7sTJRA6sutfkH0pGI63sbsU2sVIYZoRG2BgS2gv
         z31Qhe47NGMJN2gJV2HjREDuWueDhWunEQsf4Q4A4OxMYThzA3nKgUVbPlZOBHOPbrEi
         rewxI5j3cKJbKAx6XP9dlmOGaAgTw6xWlTEdJoD+jRanXi0CgiAE2CNUZqrkwG3AviqZ
         JlWMroWvoieGGS4pA+PmqpN9KC13UYocLYBRTF/ga45cRqP9rcI1W/akTcBVbeCG7wF7
         ZDSpaj/QfTUDqaXgrsnnjtbLIDsEyZOyp1Fyw7wFBq7u6gNa2d8j/15NVmkTk0mFBsb6
         2tEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=b29dvSdD;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d17sor1408743lfi.54.2019.04.12.08.32.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 08:32:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=b29dvSdD;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NXbKfjDtbjJTyw5Ef0Kix1bfyNOyzTYwEKpGgqOg0TQ=;
        b=b29dvSdD9cfYHQabi8DqTd65SPCA4obhIln3RU66IajZ136WcOn3NOWVgBFDYVDptF
         Pp2/5FS6XX6lmgEFeW+6w+62lN8PLub/YTGNvXWjkP9nQCUx99g1ArdD+fsyH0+QY+kM
         Dy3/6RufoCQqG8kSbDLFyrVvMcECFbfR4KUgE=
X-Google-Smtp-Source: APXvYqzSUbdGE+/0I3klB6NSTIOF9HYf80hu7I7vgpJh68YUP6Ek+ZuQTeslR40YzcI9SM+/7maTLA==
X-Received: by 2002:ac2:495c:: with SMTP id o28mr31935993lfi.16.1555083176400;
        Fri, 12 Apr 2019 08:32:56 -0700 (PDT)
Received: from mail-lj1-f172.google.com (mail-lj1-f172.google.com. [209.85.208.172])
        by smtp.gmail.com with ESMTPSA id u11sm8367289ljh.80.2019.04.12.08.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 08:32:55 -0700 (PDT)
Received: by mail-lj1-f172.google.com with SMTP id l7so9251975ljg.6
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:32:55 -0700 (PDT)
X-Received: by 2002:a2e:9a91:: with SMTP id p17mr30639609lji.127.1555083174727;
 Fri, 12 Apr 2019 08:32:54 -0700 (PDT)
MIME-Version: 1.0
References: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com> <20190411193906.GA12232@hirez.programming.kicks-ass.net>
 <20190411195424.GL14281@hirez.programming.kicks-ass.net> <20190411211348.GA8451@worktop.programming.kicks-ass.net>
 <20190412105633.GM14281@hirez.programming.kicks-ass.net>
In-Reply-To: <20190412105633.GM14281@hirez.programming.kicks-ass.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 12 Apr 2019 08:32:38 -0700
X-Gmail-Original-Message-ID: <CAHk-=wieBr3G=_ZGoCndi8XnuG1wtkedaGqkWB+=AVq65=_8sQ@mail.gmail.com>
Message-ID: <CAHk-=wieBr3G=_ZGoCndi8XnuG1wtkedaGqkWB+=AVq65=_8sQ@mail.gmail.com>
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"): BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
To: Peter Zijlstra <peterz@infradead.org>
Cc: kernel test robot <lkp@intel.com>, LKP <lkp@01.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, 
	Andy Lutomirski <luto@kernel.org>, Nadav Amit <namit@vmware.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 3:56 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -728,7 +728,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>  {
>         int cpu;
>
> -       struct flush_tlb_info info __aligned(SMP_CACHE_BYTES) = {
> +       struct flush_tlb_info info = {
>                 .mm = mm,
>                 .stride_shift = stride_shift,
>                 .freed_tables = freed_tables,
>

Ack.

We should never have stack alignment bigger than 16 bytes.  And
preferably not even that. Trying to align stack at a cacheline
boundary is wrong - if you *really* need things to be that aligned, do
something else (regular kmalloc, percpu temp area, static allocation -
whatever).

           Linus

