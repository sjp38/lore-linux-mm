Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AEDDC10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:15:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B79CA214DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:15:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B79CA214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 514B06B0005; Thu, 18 Apr 2019 02:15:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C21E6B0006; Thu, 18 Apr 2019 02:15:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38B656B0007; Thu, 18 Apr 2019 02:15:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1B9B6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:15:04 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id o16so1133680wrp.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 23:15:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=AMn+kcUfJh7LaZ1vzHC5xYrlRZ7RiJslkBC//gBom+A=;
        b=BLJGXI6eAgemjMBFcIzJ+cc2fcaIzbtGj5ysC03cwW1ck1O/BYqOdzKqjgGPaJ1wSZ
         nqXk+P1IdDUby8zxqWjC8MxPUxIWLIelLKOLKF8rLCmea4wNmCPxa0jdhJBItGIMBl8/
         0SHy6ZJNBTrhjvfa/LwEzF/mIqABehuDr9HuPGtzrwBSkMy6Kdz1cCjdjd3gsG4rlLpW
         8rCCKFaD2SyUukxLqzssJ9DxZZnX2FSXFP+97ph4elVXOLPvQJnJVafbqp1EjMfVwOfl
         eAsFPbrDZ9KwPCvnAH2kd1/zDLbyiOGRrJHzuSSYaxCDjmRRdmHu2jglWGcZqW9WGOi0
         cmtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVTrsOndDNOCNZ0HfCfxpQZljCkY3QFkg+5xqLwjA5fOGrmN6Vn
	LMMLqf5gyOUjZPYWkUGhu0YuFC0VGjK3C2vXQWNswjSTuuVjQs/u4uH+8i2EAPWwH8EMdnsmRGk
	lSCHKqkoWeJ1nxg6bFw00AXIuPJvGfAdbW92LUqLMoQdBeoHXLvlIFNuIs0E+CMa9lQ==
X-Received: by 2002:a1c:a742:: with SMTP id q63mr1496518wme.133.1555568104410;
        Wed, 17 Apr 2019 23:15:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYrp6/fwwHbfDq1IoNsda3kiy3lniAXL/CSwE+fNfIfX4rXFL7y9kRF45dD/xuuJ5Z2iHM
X-Received: by 2002:a1c:a742:: with SMTP id q63mr1496466wme.133.1555568103490;
        Wed, 17 Apr 2019 23:15:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555568103; cv=none;
        d=google.com; s=arc-20160816;
        b=RO3eEBeaTjGbQoMHhafBqnJSxSxEEPVfHustb1lHPdpTuHWruF/a8EmKXZb+AkMmj6
         oWu395MPz301O9d6FyMaS0oDreHBasjyTZ59+JLXtWVLlzaYAf4FLwMUHDHIYbBkMA6B
         4MkDmxqrHCrp2o1zC5QUZdsw9CVBhjfc57Rq+I1qz6eTOsSJEiVM+4EDeEIwGtsTm0WL
         4EfrGZQ8K6rebnduNSIn01SCxSCJeHqf8kmDS/Xj0OyDQwdsF2IH/j0RqN9lYjqld9wB
         gMHq9w37qUswx5I4EavLx/1hIwMKWcHvKLtCuLuxHeU+AwowKI6raZJzunaotT46ToZT
         7Xgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=AMn+kcUfJh7LaZ1vzHC5xYrlRZ7RiJslkBC//gBom+A=;
        b=YHhw6UX+fTIai/eFlIfr5I1JXSlCn8hP4rU3l8QSpFQkb5JTZQgL18kQZepzHpshFO
         IDhAEV2woh0DSIenxwWBUentOR+R8kG8EF6t3UD9PyZ0vkkAWLeEzdLSpOI+Ryn9YgPG
         7bPG2c1yb/1qPqJLdpkKZYpuM5nYOdCtX24Qwu9FtP9cS7Sehv7YnLHgzeKQDhkrY/Y2
         LnBv3RBi5mAxEpSzE2erwcrI+cWAv3zuvnM/ceCnWbIaYg+SPaH4IM2JxwYgqnWKNKCj
         l5ITNm5uY6Qw3Ok5jjKE6jI5o8aF/JzE5osibtQZHHnNIX77qK50VApXr1FYngFI5uG6
         gFWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x127si885143wmf.42.2019.04.17.23.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 17 Apr 2019 23:15:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH0Jt-0006T4-RM; Thu, 18 Apr 2019 08:14:50 +0200
Date: Thu, 18 Apr 2019 08:14:48 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Nadav Amit <nadav.amit@gmail.com>, Ingo Molnar <mingo@kernel.org>, 
    Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com, 
    Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, 
    Kees Cook <keescook@google.com>, 
    Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, 
    Juerg Haefliger <juerg.haefliger@canonical.com>, 
    deepa.srinivasan@oracle.com, chris.hyser@oracle.com, 
    Tyler Hicks <tyhicks@canonical.com>, David Woodhouse <dwmw@amazon.co.uk>, 
    Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, 
    Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
    iommu <iommu@lists.linux-foundation.org>, X86 ML <x86@kernel.org>, 
    "linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>, 
    "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
    Linux-MM <linux-mm@kvack.org>, 
    LSM List <linux-security-module@vger.kernel.org>, 
    Khalid Aziz <khalid@gonehiking.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, 
    Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>, 
    "H. Peter Anvin" <hpa@zytor.com>, Arjan van de Ven <arjan@infradead.org>, 
    Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
In-Reply-To: <CAHk-=whUwOjFW6RjHVM8kNOv1QVLJuHj2Dda0=mpLPdJ1UyatQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1904180811570.3174@nanos.tec.linutronix.de>
References: <cover.1554248001.git.khalid.aziz@oracle.com> <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com> <20190417161042.GA43453@gmail.com> <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com> <20190417170918.GA68678@gmail.com>
 <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com> <20190417172632.GA95485@gmail.com> <063753CC-5D83-4789-B594-019048DE22D9@gmail.com> <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de> <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com>
 <alpine.DEB.2.21.1904180129000.3174@nanos.tec.linutronix.de> <CAHk-=whUwOjFW6RjHVM8kNOv1QVLJuHj2Dda0=mpLPdJ1UyatQ@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Apr 2019, Linus Torvalds wrote:
> On Wed, Apr 17, 2019 at 4:42 PM Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Wed, 17 Apr 2019, Linus Torvalds wrote:
> > > With SMEP, user space pages are always NX.
> >
> > We talk past each other. The user space page in the ring3 valid virtual
> > address space (non negative) is of course protected by SMEP.
> >
> > The attack utilizes the kernel linear mapping of the physical
> > memory. I.e. user space address 0x43210 has a kernel equivalent at
> > 0xfxxxxxxxxxx. So if the attack manages to trick the kernel to that valid
> > kernel address and that is mapped X --> game over. SMEP does not help
> > there.
> 
> Oh, agreed.
> 
> But that would simply be a kernel bug. We should only map kernel pages
> executable when we have kernel code in them, and we should certainly
> not allow those pages to be mapped writably in user space.
> 
> That kind of "executable in kernel, writable in user" would be a
> horrendous and major bug.
> 
> So i think it's a non-issue.

Pretty much.

> > From the top of my head I'd say this is a non issue as those kernel address
> > space mappings _should_ be NX, but we got bitten by _should_ in the past:)
> 
> I do agree that bugs can happen, obviously, and we might have missed something.
>
> But in the context of XPFO, I would argue (*very* strongly) that the
> likelihood of the above kind of bug is absolutely *miniscule* compared
> to the likelihood that we'd have something wrong in the software
> implementation of XPFO.
> 
> So if the argument is "we might have bugs in software", then I think
> that's an argument _against_ XPFO rather than for it.

No argument from my side. We better spend time to make sure that a bogus
kernel side X mapping is caught, like we catch other things.

Thanks,

	tglx

