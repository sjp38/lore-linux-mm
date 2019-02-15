Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1E65C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 10:38:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 798B921924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 10:38:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 798B921924
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6C6A8E0002; Fri, 15 Feb 2019 05:38:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1C908E0001; Fri, 15 Feb 2019 05:38:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0BB48E0002; Fri, 15 Feb 2019 05:38:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6772C8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 05:38:40 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id v8so2421292ljh.20
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 02:38:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=V8W6lFhD94x7i+uX0K7RSwudYx4hWDMfrTrzwycJ5mg=;
        b=BPTxqB5F9eZaBZzAdr2bEv67D9oBrGff/ki0DzOvQBQ3fnfUd2Tw9yn+gZUDPK9VW/
         wYbqvmIwH88Z/G6/Pv0WIkWV5pxZ3Bwy2FE1qR298wt5y/+0zfjZWFJGC+a4AjGw45XW
         MLDZ6nJVK2c5Yo0w4NdL5Tr0QXkZvDLDM2ncEq4ZQAm0LWeihiv7aSuoclMhM9eLrCbl
         mcBbJ5QqBoww/9heoYAq4iPpjcyiy6jtcFgnGdiw0lR8fmA4xvem953Fjd9CMZLAeNx7
         PYu9HIIsmth0keNZlP7KstnZ+op6RQjdnZBQ14N9cLsGk5CnNPu2BB9l+u4jY7Z0MNak
         W5sg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuaYkTwyxrhtMaW988n10SN+WoUONqDatdlPk8VPJ6GN5jXD3kzo
	RkFPbMGxKflLmwK/2kWeb2pWCVJxnDwSi0vnybnfFgNavb1hpYPL3Y5Z7TUuULf5y+d9y9tBfJl
	mV1be1MHHRVTA7WDx6sp7sUTRaorb1//lkLscxM8FlLi7INZF8O2HRZjHIJz/Ly/McQ==
X-Received: by 2002:a2e:7615:: with SMTP id r21-v6mr5218005ljc.131.1550227119762;
        Fri, 15 Feb 2019 02:38:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZL5U8dAr2QOTNHa+FqhseBk2v4FXmQwE3QfjnjgegtOC86EvPsGncHKkzPLNPZ5Ll4lRqM
X-Received: by 2002:a2e:7615:: with SMTP id r21-v6mr5217965ljc.131.1550227118622;
        Fri, 15 Feb 2019 02:38:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550227118; cv=none;
        d=google.com; s=arc-20160816;
        b=FLfdJjLC6ksr5sNJuIf9b5Y4A4pgI2c9O+Ez8M9wQYJCVlGji2ZZ4RoW5NGH1ssqDf
         eQRwd4Z+eBPI71CNt5VvZqZ2g0wklNPE9oD0QkAQ6r5ntZkndUp3oDqwtxSINwYD6s/I
         WaapQhyQ3ZrhYQo2PJXWGeIbjA7euutqC7KhY1xG0NPQnfCgzKLBGcoMfMlT6E9qATmO
         fhu5Iqv/Lgj3k4HJ9Df2d2PIpL/t6MVO6u/Rcng7opbfi+9mb6LnYSWivfAu20WKMN+d
         QOkmHW0eLKL8z/mariw1n0NkdhpkOXgBzrgTTMODdbiwxh609DxIVxB5NI9bNnmq7cu7
         o2Ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=V8W6lFhD94x7i+uX0K7RSwudYx4hWDMfrTrzwycJ5mg=;
        b=FBmCiGx9NhAd6Otai5hXtS9U64iBYaHOrAhDoQswcZheioeWanUNUHeVSQZevldwmJ
         I6DXCEKouGjO4NORMvLBfdjmTh64Pcsy/7oaC+8EawdTF4azETANwhiRwzAjjFa2hFD/
         k9t7rTeWzLlALefMQlzN3bFVjcJPyOzAzZvJ9qs1pz1mGR1nlJIhNSrEwp8wiX6U33jg
         ycyG5uZbRyFAW+nWez53NP9qxcZzk7ZjbLkeqW/yzw+DsuUVba3Cboo584F9sawt/ZWA
         3yrDyWgdGQW494fKML8hvffZi8abfiohTsl3369q2AdXH5+s8uh9rSd0f5yElAg7Qpur
         etSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id f19-v6si4272878ljg.114.2019.02.15.02.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 02:38:38 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1guat9-0003sq-Lj; Fri, 15 Feb 2019 13:38:35 +0300
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
 <e43e21c2-f42c-bab3-c112-2a557f3de5b1@virtuozzo.com>
 <cd942662-2e93-ca93-915f-c9f346317535@c-s.fr>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <0c8f357d-a0b9-2dcd-63cc-44edec153b6c@virtuozzo.com>
Date: Fri, 15 Feb 2019 13:38:56 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <cd942662-2e93-ca93-915f-c9f346317535@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/15/19 1:10 PM, Christophe Leroy wrote:
> 
> 
> Le 15/02/2019 à 11:01, Andrey Ryabinin a écrit :
>>
>>
>> On 2/15/19 11:41 AM, Christophe Leroy wrote:
>>>
>>>
>>> Le 14/02/2019 à 23:04, Daniel Axtens a écrit :
>>>> Hi Christophe,
>>>>
>>>>> --- a/arch/powerpc/include/asm/string.h
>>>>> +++ b/arch/powerpc/include/asm/string.h
>>>>> @@ -27,6 +27,20 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
>>>>>    extern void * memchr(const void *,int,__kernel_size_t);
>>>>>    extern void * memcpy_flushcache(void *,const void *,__kernel_size_t);
>>>>>    +void *__memset(void *s, int c, __kernel_size_t count);
>>>>> +void *__memcpy(void *to, const void *from, __kernel_size_t n);
>>>>> +void *__memmove(void *to, const void *from, __kernel_size_t n);
>>>>> +
>>>>> +#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
>>>>> +/*
>>>>> + * For files that are not instrumented (e.g. mm/slub.c) we
>>>>> + * should use not instrumented version of mem* functions.
>>>>> + */
>>>>> +#define memcpy(dst, src, len) __memcpy(dst, src, len)
>>>>> +#define memmove(dst, src, len) __memmove(dst, src, len)
>>>>> +#define memset(s, c, n) __memset(s, c, n)
>>>>> +#endif
>>>>> +
>>>>
>>>> I'm finding that I miss tests like 'kasan test: kasan_memcmp
>>>> out-of-bounds in memcmp' because the uninstrumented asm version is used
>>>> instead of an instrumented C version. I ended up guarding the relevant
>>>> __HAVE_ARCH_x symbols behind a #ifndef CONFIG_KASAN and only exporting
>>>> the arch versions if we're not compiled with KASAN.
>>>>
>>>> I find I need to guard and unexport strncpy, strncmp, memchr and
>>>> memcmp. Do you need to do this on 32bit as well, or are those tests
>>>> passing anyway for some reason?
>>>
>>> Indeed, I didn't try the KASAN test module recently, because my configs don't have CONFIG_MODULE by default.
>>>
>>> Trying to test it now, I am discovering that module loading oopses with latest version of my series, I need to figure out exactly why. Here below the oops by modprobing test_module (the one supposed to just say hello to the world).
>>>
>>> What we see is an access to the RO kasan zero area.
>>>
>>> The shadow mem is 0xf7c00000..0xffc00000
>>> Linear kernel memory is shadowed by 0xf7c00000-0xf8bfffff
>>> 0xf8c00000-0xffc00000 is shadowed read only by the kasan zero page.
>>>
>>> Why is kasan trying to access that ? Isn't kasan supposed to not check stuff in vmalloc area ?
>>
>> It tries to poison global variables in modules. If module is in vmalloc, than it will try to poison vmalloc.
>> Given that the vmalloc area is not so big on 32bits, the easiest solution is to cover all vmalloc with RW shadow.
>>
> 
> Euh ... Not so big ?
> 
> Memory: 96448K/131072K available (8016K kernel code, 1680K rwdata
> , 2720K rodata, 624K init, 4678K bss, 34624K reserved, 0K cma-reserved)
> Kernel virtual memory layout:
>   * 0xffefc000..0xffffc000  : fixmap
>   * 0xf7c00000..0xffc00000  : kasan shadow mem
>   * 0xf7a00000..0xf7c00000  : consistent mem
>   * 0xf7a00000..0xf7a00000  : early ioremap
>   * 0xc9000000..0xf7a00000  : vmalloc & ioremap
> 
> Here, vmalloc area size 0x2ea00000, that is 746Mbytes. Shadow for this would be 93Mbytes and we are already using 16Mbytes to shadow the linear memory area .... this poor board has 128Mbytes RAM in total.
> 
> So another solution is needed.
> 

Ok.
As a temporary workaround your can make __asan_register_globals() to skip globals in vmalloc(). 
Obviously it means that out-of-bounds accesses to in modules will be missed.

Non temporary solution would making kasan to fully support vmalloc, i.e. remove RO shadow and allocate/free shadow on vmalloc()/vfree().
But this feels like separate task, out of scope of this patch set.

It is also possible to follow some other arches - dedicate separate address range for modules, allocate/free shadow in module_alloc/free.
But it doesn't seem worthy to implement this only for the sake of kasan, since vmalloc support needs to be done anyway.

