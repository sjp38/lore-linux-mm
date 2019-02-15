Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD4F3C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 10:01:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E0D721924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 10:01:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E0D721924
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEB608E0002; Fri, 15 Feb 2019 05:01:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D769C8E0001; Fri, 15 Feb 2019 05:01:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65C38E0002; Fri, 15 Feb 2019 05:01:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58BAC8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 05:01:34 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id s64-v6so2393837lje.19
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 02:01:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ch7EoHne4Vn78A7u+E0nGHclRQLHFZUXvP490sZagxI=;
        b=Zg3l05vZVfuAw/5E3TWLB12cGFqTSePL0xP3LJcT2xRtMZrpmOWpmC1HQFr0gj47Cp
         H1cv8Kokp88eeFDfuvXTjdvWNVM4IsuKJ/EPoQBIbqKzYrLgzLElBaQmBil0Oe9unJNc
         13DOsei+90KYuZtiWAQ4o65R59DaWHq4J8c7+rkVvkvBj3gLGWv/grJfsXfijAINXUBQ
         3f4dyMLLTUvBfMMyKOhvVfAH7NyQIBUqA5s6UcT2VO7wVVuPwzjgLeUh1cJWFarpreBa
         j/n8oKSlYe3ERlk3oSA1KPgVlDHZpechEa3wHQITLAIPMHcnd3L3jpdPsW5RVTInC6l7
         Rfgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuYHqeNc4UZi5OrSWAG9qYh4RcDNXqzGFxSj27A0FPcTmdC1a5ZV
	9pDRsAoK4SbCy+NQFOAJWW08SOXmjZT0qDCbQ01F65mAduJ7/UIjagUgPm41gjmT60JnK8KPgXy
	BW1EEB7/b3JlLdmDMV9pYRCS6BLihnnaQWOpacSVK8+W5Lt4c0WYMEBowjthR3kXBsw==
X-Received: by 2002:a2e:2202:: with SMTP id i2mr189144lji.170.1550224893581;
        Fri, 15 Feb 2019 02:01:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib7kWf+FtfcEBDNM2K7iHDTCWYpxmrG5XBtyZDmBmSx6xtui4nms7tGxzslU7t4yvFMlS59
X-Received: by 2002:a2e:2202:: with SMTP id i2mr189082lji.170.1550224892482;
        Fri, 15 Feb 2019 02:01:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550224892; cv=none;
        d=google.com; s=arc-20160816;
        b=a3RyjMkVNcMohU5xfJ6WA/v/hhBw2A7Xv8z38IVmul2aoJqNjv1A2X1+FJDG0NJyvK
         TxKy1o3GbuukSc02Arx9No0TsbG5+Lj/pRz+6KrwMOsEuocfO6nPsJeX9ZreTBWubZe+
         ldR0XUkQO18nLw+pGGgf3CC46F0Vzam6weGNkN9B1BrQR8ALBhVbuZgtVALVefDULwFS
         7zzTQdyJN6kFyvUsfmIdl2A+7AJDObG+VbjCGkqDpHVXXq4gIo2DP/nl6fOapdFIohIZ
         b74VgBFDw/Ig9wv5w1Eys2XZqy0d9xfAdqzeo0I2E9qkIu+ZkDdmO8KxR8+LrOEUvow9
         DLsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ch7EoHne4Vn78A7u+E0nGHclRQLHFZUXvP490sZagxI=;
        b=B+hC+sA2JiY2W1zgxZt6JN0NqEEs2PmbMvD3O12pTiSCrhBUrYOUlQ4DFRxkQl8NNC
         vvYE/BPvrqGune0IDKLnoLOE1+iIBqKh6Hnf//rFcBIe/bGU5eoRxSqKL/5snbf1cJQ2
         ZhkYYYnUwZUwSpQrKsPQBJuSkUMCx6Kd0dAcsR6P1RgRSDVs4sHT27Pkd//x1LcXwm4f
         9IDEgrKlJ2eqtJOKZnI3K84+xrz5k0sij1/mUPqQoLzZIvtcqLQRr5fl8+rvOc0AIWVy
         LYVgb00NfxySar7CZyjmJzvEI0GDZNzOJlXLiBIn3myR2adWh2g4Zq7be1KPaOM6qsu7
         c6XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id h101-v6si5339804ljh.148.2019.02.15.02.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 02:01:32 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1guaJA-0003fU-Ra; Fri, 15 Feb 2019 13:01:24 +0300
Subject: Re: [PATCH v5 3/3] powerpc/32: Add KASAN support
To: Christophe Leroy <christophe.leroy@c-s.fr>, Daniel Axtens
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
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <e43e21c2-f42c-bab3-c112-2a557f3de5b1@virtuozzo.com>
Date: Fri, 15 Feb 2019 13:01:46 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <b5db7714-51e3-785c-34ca-6c358661c9e8@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/15/19 11:41 AM, Christophe Leroy wrote:
> 
> 
> Le 14/02/2019 à 23:04, Daniel Axtens a écrit :
>> Hi Christophe,
>>
>>> --- a/arch/powerpc/include/asm/string.h
>>> +++ b/arch/powerpc/include/asm/string.h
>>> @@ -27,6 +27,20 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
>>>   extern void * memchr(const void *,int,__kernel_size_t);
>>>   extern void * memcpy_flushcache(void *,const void *,__kernel_size_t);
>>>   +void *__memset(void *s, int c, __kernel_size_t count);
>>> +void *__memcpy(void *to, const void *from, __kernel_size_t n);
>>> +void *__memmove(void *to, const void *from, __kernel_size_t n);
>>> +
>>> +#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
>>> +/*
>>> + * For files that are not instrumented (e.g. mm/slub.c) we
>>> + * should use not instrumented version of mem* functions.
>>> + */
>>> +#define memcpy(dst, src, len) __memcpy(dst, src, len)
>>> +#define memmove(dst, src, len) __memmove(dst, src, len)
>>> +#define memset(s, c, n) __memset(s, c, n)
>>> +#endif
>>> +
>>
>> I'm finding that I miss tests like 'kasan test: kasan_memcmp
>> out-of-bounds in memcmp' because the uninstrumented asm version is used
>> instead of an instrumented C version. I ended up guarding the relevant
>> __HAVE_ARCH_x symbols behind a #ifndef CONFIG_KASAN and only exporting
>> the arch versions if we're not compiled with KASAN.
>>
>> I find I need to guard and unexport strncpy, strncmp, memchr and
>> memcmp. Do you need to do this on 32bit as well, or are those tests
>> passing anyway for some reason?
> 
> Indeed, I didn't try the KASAN test module recently, because my configs don't have CONFIG_MODULE by default.
> 
> Trying to test it now, I am discovering that module loading oopses with latest version of my series, I need to figure out exactly why. Here below the oops by modprobing test_module (the one supposed to just say hello to the world).
> 
> What we see is an access to the RO kasan zero area.
> 
> The shadow mem is 0xf7c00000..0xffc00000
> Linear kernel memory is shadowed by 0xf7c00000-0xf8bfffff
> 0xf8c00000-0xffc00000 is shadowed read only by the kasan zero page.
> 
> Why is kasan trying to access that ? Isn't kasan supposed to not check stuff in vmalloc area ?

It tries to poison global variables in modules. If module is in vmalloc, than it will try to poison vmalloc.
Given that the vmalloc area is not so big on 32bits, the easiest solution is to cover all vmalloc with RW shadow.



