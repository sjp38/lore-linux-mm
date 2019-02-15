Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 827ABC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 10:10:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E84C021A80
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 10:10:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="dsVPGzXf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E84C021A80
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 755FA8E0002; Fri, 15 Feb 2019 05:10:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 705408E0001; Fri, 15 Feb 2019 05:10:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F4D08E0002; Fri, 15 Feb 2019 05:10:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0924A8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 05:10:42 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id h79so3115231wme.3
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 02:10:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=fGrTf9HHpW6M3RhNKUCDoLysugJ3V4FOz2cylNekxBo=;
        b=caELvwxpvPctdm2JimedXGovjWM2JWOXUWIE0LbkMbPEloLuQsU1k8gs+geIpxPqWW
         rsFjFkgQBCrBTIje6ZjiJSWW+a71ShQMaJlyAFJKOp2PH+L5QuxaFQqqG+/aWEfabrk+
         GLgiJQEwznzSK8Slv35LQ/I6NtGx9mQdrq6BYQdlEJMHY/gEf0bNB+yntz7CVhR7K4t9
         AcYyXM8XfsHkqqy1CsiLAEVCt/lPIhcUN7R9O8NrUa1iUUAxc0Ga6GYvlwqOiiCuzeIo
         ADztW956tGh8rWM8trE/zONSsDZbD3SonfwgGlk9D0PF9PDMgTgeB4De7ZUYrYJxOmCY
         htyg==
X-Gm-Message-State: AHQUAuaAgT5o+RBdQr+r8nW2B05qBKi80bzjXe3/x0gLJtVtNXm4oix3
	TAYX0FhneaI+pVtRX6ZuQ3lfNMt/pf5TSyYPBxGXc4FJDA2feKfyGN0V5/RJQnAljSuh13gN5r3
	vmUiS80nlL+Fv0QTxtRFglfpU+h1OH1rENZImNR4f63XsakFGmD1G4c6PAW5U1Cbo8Q==
X-Received: by 2002:a1c:1c4:: with SMTP id 187mr6287274wmb.6.1550225441526;
        Fri, 15 Feb 2019 02:10:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZte4ktAjO959JmHZpYeWCAqu+Pev4TXmNnjFDSzCgAVlF4O6ddyf9bKKKSij3TRzW3WO8e
X-Received: by 2002:a1c:1c4:: with SMTP id 187mr6287195wmb.6.1550225440460;
        Fri, 15 Feb 2019 02:10:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550225440; cv=none;
        d=google.com; s=arc-20160816;
        b=vObzxnQBCr3nyUEZe2bFdq8ga1dG+E04ua1mcZmTdDV0jz6fMLMExbbOi7F5CCOBgk
         02pMDXhq/9Z228o5diE8ND0omqx6d0gKIXuiVhraPCiYQeG+VL6tGHzEydKTQAKVqsrp
         NOazn1zr3UwKJGnuRUM5ZSagviVAAnpQ3qscGujp6FAV1db38ci9zglXR+BlYzhi7vzI
         eUgrDpRqv/FZ4i+FERw+9nxzG68mwngk9ob67CMYNMbQ6YLHIJTTpDUr1S7fnB97BefT
         qGEIAFiXwvCHZZYzG1wcrLHdF3X4saalxyXPnh/ccgjGuN55hps14NnPG/VUpkX9jWz8
         wGJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=fGrTf9HHpW6M3RhNKUCDoLysugJ3V4FOz2cylNekxBo=;
        b=NQlKlkkj0oKXjR20aqjUYdisJv0JoEIh+IDP5yr2X3tRXYlRKXBQA6Wsy30B4PXEoF
         aOEdvrXOj8aFNngFefsl4OKXPwEgo2jFTma+vo48/8eO4hIgtnv613AWGXwtwUUuafAu
         GBNOIoANmQwqT5UDtQPHKRQS+JhlaFldZkDPpYHiFFEX2SLUm072GJEqdth5d8oUAahg
         EaVwK+BbWDj8D/1up+rQ4bDh+yIJpzClQ6njHjQrsKsNM8SIE0DFgiIQUlOOZweCWscu
         n4/AX2fJEwewF2N/A01qUIZtj17QbVRIBWrM9buswXm1QSbRFIlRODojO6W/F1DMskkw
         h/RQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=dsVPGzXf;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id x15si3191558wmh.191.2019.02.15.02.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 02:10:40 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=dsVPGzXf;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4418Cf5XlBz9vKJC;
	Fri, 15 Feb 2019 11:10:38 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=dsVPGzXf; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id kY2u5JCdnJat; Fri, 15 Feb 2019 11:10:38 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4418Cf4QVrz9vKJB;
	Fri, 15 Feb 2019 11:10:38 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1550225438; bh=fGrTf9HHpW6M3RhNKUCDoLysugJ3V4FOz2cylNekxBo=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=dsVPGzXf9jTylpe4jcZ42VTr8CyUFG1L0HNnZ+W9GYdkRO9/4qND3a1ysrc0Ax81h
	 6V9aLnS8grv5bdjtZ5GXir9xL/DUYNnOQOOppPkGgtKGt943zlEsSDAKzHWThrzpL2
	 suwZ4SQlA+a9sM5G4TUbb1ydvkZLudL+eVg6KBdg=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 9A4B88B8C6;
	Fri, 15 Feb 2019 11:10:39 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id cC4JOO6DXi5B; Fri, 15 Feb 2019 11:10:39 +0100 (CET)
Received: from PO15451 (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 60CE88B8C5;
	Fri, 15 Feb 2019 11:10:39 +0100 (CET)
Subject: Re: [PATCH v5 3/3] powerpc/32: Add KASAN support
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Daniel Axtens
 <dja@axtens.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 kasan-dev@googlegroups.com, linux-mm@kvack.org
References: <cover.1549935247.git.christophe.leroy@c-s.fr>
 <3429fe33b68206ecc2a725a740937bbaef2d1ac8.1549935251.git.christophe.leroy@c-s.fr>
 <8736oq3u2r.fsf@dja-thinkpad.axtens.net>
 <b5db7714-51e3-785c-34ca-6c358661c9e8@c-s.fr>
 <e43e21c2-f42c-bab3-c112-2a557f3de5b1@virtuozzo.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <cd942662-2e93-ca93-915f-c9f346317535@c-s.fr>
Date: Fri, 15 Feb 2019 11:10:39 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <e43e21c2-f42c-bab3-c112-2a557f3de5b1@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 15/02/2019 à 11:01, Andrey Ryabinin a écrit :
> 
> 
> On 2/15/19 11:41 AM, Christophe Leroy wrote:
>>
>>
>> Le 14/02/2019 à 23:04, Daniel Axtens a écrit :
>>> Hi Christophe,
>>>
>>>> --- a/arch/powerpc/include/asm/string.h
>>>> +++ b/arch/powerpc/include/asm/string.h
>>>> @@ -27,6 +27,20 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
>>>>    extern void * memchr(const void *,int,__kernel_size_t);
>>>>    extern void * memcpy_flushcache(void *,const void *,__kernel_size_t);
>>>>    +void *__memset(void *s, int c, __kernel_size_t count);
>>>> +void *__memcpy(void *to, const void *from, __kernel_size_t n);
>>>> +void *__memmove(void *to, const void *from, __kernel_size_t n);
>>>> +
>>>> +#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
>>>> +/*
>>>> + * For files that are not instrumented (e.g. mm/slub.c) we
>>>> + * should use not instrumented version of mem* functions.
>>>> + */
>>>> +#define memcpy(dst, src, len) __memcpy(dst, src, len)
>>>> +#define memmove(dst, src, len) __memmove(dst, src, len)
>>>> +#define memset(s, c, n) __memset(s, c, n)
>>>> +#endif
>>>> +
>>>
>>> I'm finding that I miss tests like 'kasan test: kasan_memcmp
>>> out-of-bounds in memcmp' because the uninstrumented asm version is used
>>> instead of an instrumented C version. I ended up guarding the relevant
>>> __HAVE_ARCH_x symbols behind a #ifndef CONFIG_KASAN and only exporting
>>> the arch versions if we're not compiled with KASAN.
>>>
>>> I find I need to guard and unexport strncpy, strncmp, memchr and
>>> memcmp. Do you need to do this on 32bit as well, or are those tests
>>> passing anyway for some reason?
>>
>> Indeed, I didn't try the KASAN test module recently, because my configs don't have CONFIG_MODULE by default.
>>
>> Trying to test it now, I am discovering that module loading oopses with latest version of my series, I need to figure out exactly why. Here below the oops by modprobing test_module (the one supposed to just say hello to the world).
>>
>> What we see is an access to the RO kasan zero area.
>>
>> The shadow mem is 0xf7c00000..0xffc00000
>> Linear kernel memory is shadowed by 0xf7c00000-0xf8bfffff
>> 0xf8c00000-0xffc00000 is shadowed read only by the kasan zero page.
>>
>> Why is kasan trying to access that ? Isn't kasan supposed to not check stuff in vmalloc area ?
> 
> It tries to poison global variables in modules. If module is in vmalloc, than it will try to poison vmalloc.
> Given that the vmalloc area is not so big on 32bits, the easiest solution is to cover all vmalloc with RW shadow.
> 

Euh ... Not so big ?

Memory: 96448K/131072K available (8016K kernel code, 1680K rwdata
, 2720K rodata, 624K init, 4678K bss, 34624K reserved, 0K cma-reserved)
Kernel virtual memory layout:
   * 0xffefc000..0xffffc000  : fixmap
   * 0xf7c00000..0xffc00000  : kasan shadow mem
   * 0xf7a00000..0xf7c00000  : consistent mem
   * 0xf7a00000..0xf7a00000  : early ioremap
   * 0xc9000000..0xf7a00000  : vmalloc & ioremap

Here, vmalloc area size 0x2ea00000, that is 746Mbytes. Shadow for this 
would be 93Mbytes and we are already using 16Mbytes to shadow the linear 
memory area .... this poor board has 128Mbytes RAM in total.

So another solution is needed.

Christophe

