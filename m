Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B25FC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 15:39:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB63522ADA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 15:39:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="XJhOr3aG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB63522ADA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52AF18E0002; Thu, 25 Jul 2019 11:39:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DD036B026B; Thu, 25 Jul 2019 11:39:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F1DE8E0002; Thu, 25 Jul 2019 11:39:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07EF46B026A
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:39:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q10so7745830pgi.9
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 08:39:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:in-reply-to
         :references:date:message-id:mime-version:content-transfer-encoding;
        bh=C1z55Z2C5T/VVbilD04bgcsRmc4fMIXBlsOukeF2YXM=;
        b=hAcplYYH4DAAyLyu4vf/S89rMXHtY4krGO2qVzLDPvUhD1bqzIQJNQfYrP3rljgkQk
         N5t2indTbpNnYqCFTGKMMV/DcTEpbIfiesplHcgiysWeVcSZ1z1/zPF30rB8sXwc2uAk
         WUJuWrKIMCDjn0RxA4JIzAsxXDPcslr92TyVcA7HW/LQG3ujarGInWm2Bg9zUFX9SpT7
         IB8kf8T06MCIGXpZ/eOZJPnwbjZWLHCX3pIm86HtZXrNR6IO2lI7bKB4WbPtro1kD2Qz
         va9grMGoj6/6Ub2UfMqtDuim4lredDg180ZlPNEUx9aMyyprimLj1pgTHapchzlFLFv0
         BGRg==
X-Gm-Message-State: APjAAAVd/BuVJU2dQAqz9XL7R0vwo+8EK3oMkNPArQ0E5f61Adlc2i6C
	wnfmUjAky6nwXXGDc8dVCE98l2sJqsdHaYLq+cwF8DMpWQ/wOQF6ep6O1VJcr/kS2c8dW561nv0
	nsUtkm/r6BvWPxuURa7Q0ea+mtKs+QDOrrJpzJe/qRa+No4VT4GSFTxmKZkOZ5w0ecg==
X-Received: by 2002:a63:4823:: with SMTP id v35mr59538765pga.138.1564069184534;
        Thu, 25 Jul 2019 08:39:44 -0700 (PDT)
X-Received: by 2002:a63:4823:: with SMTP id v35mr59538711pga.138.1564069183696;
        Thu, 25 Jul 2019 08:39:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564069183; cv=none;
        d=google.com; s=arc-20160816;
        b=T3RwCI0+S5gEDw1FApwaElamv36soxXXMcYxebBN9zcdVijmSQ5y+ZUDY4tr0fOTnw
         SMVOaJYPjHJAAgAdpGELjCRLTkRh3Mp3tGPfwHwn7bBNKyWjMjI3Q2gpdY6oDZS1gVvp
         slImDtJ53k0X8k5inVCfKPQlOT9MfcHmBe8RCFO5Yw6Q12l2b23zCot8Kg9v1/b40VU4
         fYj6jY29Q8FYj0fXyaPr3LOJWaSNMLghZoDvyHgjquC1DFVdZQvbeRsb4qIGvTeS56Ec
         TmL1KssGyTl+w7HIg4czk0YD8Qy8BfuZxoF9x0VwC+M64RClmakLByVAXjUAF8zhICUl
         242Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:references
         :in-reply-to:subject:cc:to:from:dkim-signature;
        bh=C1z55Z2C5T/VVbilD04bgcsRmc4fMIXBlsOukeF2YXM=;
        b=Fhs6VQGw2yet8tJhJ0RxHd7QFezAnboRiZuSye4PAEHtkvhKY5GJUXex6H/hamJHnY
         tyha4MSpZ8UjbqT+FnYlfmA/WJIGOZ6geHqlRSgiFTJSeyEpnjyNpttTxcpPktb/QZva
         HbWFDlrlXKBDgsKm650Hx/Tvt6su1IRzmUitm/RF8JeOI1jijlOrI1ryjpiQdPHoKoD5
         GuEvZEZ8YI8fm1SzwGVw699Fjw02CCYh21QKgb3CX8jBgzF1MPgcnxsFWZNzOhBEt1+c
         eVvORtX6R5QHvfZwLJXJEQrUGPGC1AjArPPH+tpeWgJE16bkZyMqYG2BbT4E5WJN8NsC
         bjKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=XJhOr3aG;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor31583416pfh.9.2019.07.25.08.39.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 08:39:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=XJhOr3aG;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version:content-transfer-encoding;
        bh=C1z55Z2C5T/VVbilD04bgcsRmc4fMIXBlsOukeF2YXM=;
        b=XJhOr3aGuuNIkP4kpA8HS8s/JgR+WMYZ1J3mEgq1CWo/6k4RML521jqXRluf4Z5aaz
         hx3+QfqAIm0RXxLfFp01lVlonlb+LJ809JG3M9Kdd68Kk7mroC4fRWjp/iRJARzGYBmm
         H0vLlYPS0WuxmSlQ75KCDqnXj4wYSA5QBypjM=
X-Google-Smtp-Source: APXvYqxHjoKma+4pyqHZg/jbZwwKKEWuHlQBC9TWnoz5k0p4isbrULwmvHBr96fhLd19SMyOOy6Uow==
X-Received: by 2002:aa7:93bb:: with SMTP id x27mr17847025pff.10.1564069182790;
        Thu, 25 Jul 2019 08:39:42 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id o11sm83158287pfh.114.2019.07.25.08.39.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 08:39:42 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: Andy Lutomirski <luto@amacapital.net>, Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH 3/3] x86/kasan: support KASAN_VMALLOC
In-Reply-To: <D7AC2D28-596F-4B9E-B4AD-B03D8485E9F1@amacapital.net>
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-4-dja@axtens.net> <CACT4Y+aOvGqJEE5Mzqxusd2+hyX1OUEAFjJTvVED6ujgsASYrQ@mail.gmail.com> <D7AC2D28-596F-4B9E-B4AD-B03D8485E9F1@amacapital.net>
Date: Fri, 26 Jul 2019 01:39:36 +1000
Message-ID: <87lfwmgm2v.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


>> Would it make things simpler if we pre-populate the top level page
>> tables for the whole vmalloc region? That would be
>> (16<<40)/4096/512/512*8 =3D 131072 bytes?
>> The check in vmalloc_fault in not really a big burden, so I am not
>> sure. Just brining as an option.
>
> I prefer pre-populating them. In particular, I have already spent far too=
 much time debugging the awful explosions when the stack doesn=E2=80=99t ha=
ve KASAN backing, and the vmap stack code is very careful to pre-populate t=
he stack pgds =E2=80=94 vmalloc_fault fundamentally can=E2=80=99t recover w=
hen the stack itself isn=E2=80=99t mapped.
>
> So the vmalloc_fault code, if it stays, needs some careful analysis to ma=
ke sure it will actually survive all the various context switch cases.  Or =
you can pre-populate it.
>

No worries - I'll have another crack at prepopulating them for v2.=20

I tried prepopulating them at first, but because I'm really a powerpc
developer rather than an x86 developer (and because I find mm code
confusing at the best of times) I didn't have a lot of luck. I think on
reflection I stuffed up the pgd/p4d stuff and I think I know how to fix
it. So I'll give it another go and ask for help here if I get stuck :)

Regards,
Daniel


>>=20
>> Acked-by: Dmitry Vyukov <dvyukov@google.com>
>>=20
>>> ---
>>> arch/x86/Kconfig            |  1 +
>>> arch/x86/mm/fault.c         | 13 +++++++++++++
>>> arch/x86/mm/kasan_init_64.c | 10 ++++++++++
>>> 3 files changed, 24 insertions(+)
>>>=20
>>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>>> index 222855cc0158..40562cc3771f 100644
>>> --- a/arch/x86/Kconfig
>>> +++ b/arch/x86/Kconfig
>>> @@ -134,6 +134,7 @@ config X86
>>>        select HAVE_ARCH_JUMP_LABEL
>>>        select HAVE_ARCH_JUMP_LABEL_RELATIVE
>>>        select HAVE_ARCH_KASAN                  if X86_64
>>> +       select HAVE_ARCH_KASAN_VMALLOC          if X86_64
>>>        select HAVE_ARCH_KGDB
>>>        select HAVE_ARCH_MMAP_RND_BITS          if MMU
>>>        select HAVE_ARCH_MMAP_RND_COMPAT_BITS   if MMU && COMPAT
>>> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
>>> index 6c46095cd0d9..d722230121c3 100644
>>> --- a/arch/x86/mm/fault.c
>>> +++ b/arch/x86/mm/fault.c
>>> @@ -340,8 +340,21 @@ static noinline int vmalloc_fault(unsigned long ad=
dress)
>>>        pte_t *pte;
>>>=20
>>>        /* Make sure we are in vmalloc area: */
>>> +#ifndef CONFIG_KASAN_VMALLOC
>>>        if (!(address >=3D VMALLOC_START && address < VMALLOC_END))
>>>                return -1;
>>> +#else
>>> +       /*
>>> +        * Some of the shadow mapping for the vmalloc area lives outsid=
e the
>>> +        * pgds populated by kasan init. They are created dynamically a=
nd so
>>> +        * we may need to fault them in.
>>> +        *
>>> +        * You can observe this with test_vmalloc's align_shift_alloc_t=
est
>>> +        */
>>> +       if (!((address >=3D VMALLOC_START && address < VMALLOC_END) ||
>>> +             (address >=3D KASAN_SHADOW_START && address < KASAN_SHADO=
W_END)))
>>> +               return -1;
>>> +#endif
>>>=20
>>>        /*
>>>         * Copy kernel mappings over when needed. This can also
>>> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
>>> index 296da58f3013..e2fe1c1b805c 100644
>>> --- a/arch/x86/mm/kasan_init_64.c
>>> +++ b/arch/x86/mm/kasan_init_64.c
>>> @@ -352,9 +352,19 @@ void __init kasan_init(void)
>>>        shadow_cpu_entry_end =3D (void *)round_up(
>>>                        (unsigned long)shadow_cpu_entry_end, PAGE_SIZE);
>>>=20
>>> +       /*
>>> +        * If we're in full vmalloc mode, don't back vmalloc space with=
 early
>>> +        * shadow pages.
>>> +        */
>>> +#ifdef CONFIG_KASAN_VMALLOC
>>> +       kasan_populate_early_shadow(
>>> +               kasan_mem_to_shadow((void *)VMALLOC_END+1),
>>> +               shadow_cpu_entry_begin);
>>> +#else
>>>        kasan_populate_early_shadow(
>>>                kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
>>>                shadow_cpu_entry_begin);
>>> +#endif
>>>=20
>>>        kasan_populate_shadow((unsigned long)shadow_cpu_entry_begin,
>>>                              (unsigned long)shadow_cpu_entry_end, 0);
>>> --
>>> 2.20.1
>>>=20
>>> --
>>> You received this message because you are subscribed to the Google Grou=
ps "kasan-dev" group.
>>> To unsubscribe from this group and stop receiving emails from it, send =
an email to kasan-dev+unsubscribe@googlegroups.com.
>>> To view this discussion on the web visit https://groups.google.com/d/ms=
gid/kasan-dev/20190725055503.19507-4-dja%40axtens.net.

