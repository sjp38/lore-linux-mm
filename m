Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D18A2C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 21:54:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45A0120663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 21:54:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="XlRyhqkq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45A0120663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB2D08E0003; Wed,  6 Mar 2019 16:54:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C62318E0002; Wed,  6 Mar 2019 16:54:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2A098E0003; Wed,  6 Mar 2019 16:54:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55E908E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 16:54:26 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id y1so7656418wrh.21
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 13:54:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CGxYoqjaGuMadUkLxrfjnlC6FBZGZqJqaeni3+wCIDY=;
        b=Da9gX1yJYtRvcWx0lGwhTC+s9ro3U4amievzjEhgKhXhSghiaPpwE0/7HGsfKor9ZT
         59+4bBofH7qrXmelNVvjlHoH+Trm3dHat3i5eQKwE7TxQLGx5VfLiWsuqzORAvGiWY14
         QrdW0xt32AkyMXztP/RlffMXLARBB4CpHP0sioyLB/09b6MOsuajjTnRZ1F2TDSRBhzN
         6neh4dePoBXlr8CIRD+7RR1QxDh8TodMAY0yRZdj6aRA7WrtesUT0PhWNaLRGWs+h3Wz
         f1sfP9ExJVZbBr1aFl0UzsyP/qChu4h07ucO03b+XZStyCu1gJLp3vXuNQlP/0/ymsu4
         O6CQ==
X-Gm-Message-State: APjAAAWU2WuJfnD+DTVgLMZrfHIAOOM+3u9Hon+5vl88exinXCy6c+H9
	rahuUhGME1XsPHhW1RBscn1NvxuLxsqBRixvZRvs0r11Ewdb32mIHMWCnXUDJkyCNI71KejFvKs
	iqCihQLPq44vbmwSRZHKes3Z5A+djODpo0TuzfNzC92CzwiWvFaf1EGnRAM7JUCLBBA==
X-Received: by 2002:adf:9ecc:: with SMTP id b12mr4542893wrf.83.1551909265644;
        Wed, 06 Mar 2019 13:54:25 -0800 (PST)
X-Google-Smtp-Source: APXvYqxTX8o25rC55iy8C+j03oMTgVZjXuBZip3IN0rPuh9bbBwP3ESqCbGAp5+9DiKUZIieADT+
X-Received: by 2002:adf:9ecc:: with SMTP id b12mr4542854wrf.83.1551909264211;
        Wed, 06 Mar 2019 13:54:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551909264; cv=none;
        d=google.com; s=arc-20160816;
        b=JwUIaSQzT3k3oY40SdFX+1DRlz2d6TB3v+YAu1EhvaTSPHdvqeVjMZuThdNR3ow9RA
         QHCnhoQLjgW5NGn+OO9/fxj9+yuVXu/SVqK9M4aUJEe/XAsOu03cO/tcwg1XP7sHNJDv
         Gh2SKUgIp1JBv793DcMP8EdRE8lJHSr/mLTPEMDlbhFkJ1cTrcl7nXMeEymwxPLyT9vY
         +4fXThmLM+xDl2HfR1jVLsxrlBkSEoOLDbpuI7r7EGLj/0I/DYAQv8FD6kBQ01mKOKIy
         P/3Ak4FItEF9qg1gTKMWUwfaCO6C08QYb/oIiZoVOneyd2/99aBwjcPKJRiQeLbBPq9r
         +DFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=CGxYoqjaGuMadUkLxrfjnlC6FBZGZqJqaeni3+wCIDY=;
        b=i+KYWmGgs768UH3AYnOGYSjNwUZwcfp7Obgklshzm+2XfT/lOb+n1euP6dLivVYSad
         IG8e2wSxl5p8eNShH0pc4MBlmIoef50Q4Vrows6cUAHDcGpEQ4F0oZUOyHCes2a7waXc
         aT9OL+EaV14sR1Q2EYSGv5EmaFqg4FoFOXj1evrpDzl7nAn0l8/FXGQUozx+Oxeq/pIE
         gjG0oh3XQ98KIix4U0yxqAMz40rqsezPMDMyLmooA/LSPXVrWcPnPsg8eC6SSm2v7l34
         mgEV1M/jHQ6pL0SZAoRPBLENYachYJgjsFouUJ9+8buOpawfIe9LNEsAV5QM9o2Qmvyj
         GueQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=XlRyhqkq;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id 93si1954626wrq.442.2019.03.06.13.54.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 13:54:24 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=XlRyhqkq;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44F6wv3g43z9vBwH;
	Wed,  6 Mar 2019 22:54:23 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=XlRyhqkq; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 273gzFdN5yJi; Wed,  6 Mar 2019 22:54:23 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44F6wv2VRgz9vBwC;
	Wed,  6 Mar 2019 22:54:23 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551909263; bh=CGxYoqjaGuMadUkLxrfjnlC6FBZGZqJqaeni3+wCIDY=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=XlRyhqkqavVwbeiS6mwQnLZHW5+JZTRbTno00ZCyDiny3OCr3/228JQ8cvYFfPm/C
	 0Pd5oeXTyMjXXAaeZhXFUPLO/MBwFniFqvcx3x+eFBXmd5WAwAXBTUrYPtVi3u7y2d
	 qrIgWdrlH80VeS1bpb9uwXiGYfqCZfasFx5drbQY=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 856C28B8AB;
	Wed,  6 Mar 2019 22:54:23 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id veWWKZs18AFI; Wed,  6 Mar 2019 22:54:23 +0100 (CET)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 686DC8B883;
	Wed,  6 Mar 2019 22:54:22 +0100 (CET)
Subject: Re: [PATCH v9 02/11] powerpc: prepare string/mem functions for KASAN
To: Daniel Axtens <dja@axtens.net>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 kasan-dev@googlegroups.com, linux-mm@kvack.org
References: <cover.1551443452.git.christophe.leroy@c-s.fr>
 <45fb252fc1b27f2804109fa35ba2882ae29e6035.1551443453.git.christophe.leroy@c-s.fr>
 <87sgw31a85.fsf@dja-thinkpad.axtens.net>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <c69636a6-1f43-78e6-ff88-a3e4f3a35132@c-s.fr>
Date: Wed, 6 Mar 2019 22:54:22 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <87sgw31a85.fsf@dja-thinkpad.axtens.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 04/03/2019 à 06:26, Daniel Axtens a écrit :
> Hi Christophe,
>> diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
>> new file mode 100644
>> index 000000000000..c3161b8fc017
>> --- /dev/null
>> +++ b/arch/powerpc/include/asm/kasan.h
>> @@ -0,0 +1,15 @@
>> +/* SPDX-License-Identifier: GPL-2.0 */
>> +#ifndef __ASM_KASAN_H
>> +#define __ASM_KASAN_H
>> +
>> +#ifdef CONFIG_KASAN
>> +#define _GLOBAL_KASAN(fn)	.weak fn ; _GLOBAL(__##fn) ; _GLOBAL(fn)
>> +#define _GLOBAL_TOC_KASAN(fn)	.weak fn ; _GLOBAL_TOC(__##fn) ; _GLOBAL_TOC(fn)
>> +#define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(__##fn) ; EXPORT_SYMBOL(fn)
> 
> I'm having some trouble with this. I get warnings like this:

I don't have such problem, neither with ppc32 nor with ppc64e_defconfig.

What config are you using ?

Another (unrelated) question I have:
On the initial arm64 implementation (39d114ddc682 arm64: add KASAN 
support) they made KASAN implementation depend on SPARSEMEM_VMEMMAP 
(allthough they later removed that dependency with commit e17d8025f07e 
arm64/mm/kasan: don't use vmemmap_populate() to initialize shadow)

So I'm wondering why on your side, KASAN depends on !SPARSEMEM_VMEMMAP

Thanks
Christophe

> 
> WARNING: EXPORT symbol "__memcpy" [vmlinux] version generation failed, symbol will not be versioned.
> 
> It seems to be related to the export line, as if I swap the exports to
> do fn before __##fn I get:
> 
> WARNING: EXPORT symbol "memset" [vmlinux] version generation failed, symbol will not be versioned.
> 
> I have narrowed this down to combining 2 EXPORT_SYMBOL()s on one line.
> This works - no warning:
> 
> EXPORT_SYMBOL(memset)
> EXPORT_SYMBOL(__memset)
> 
> This throws a warning:
> 
> EXPORT_SYMBOL(memset) ; EXPORT_SYMBOL(__memset)
> 
> I notice in looking at the diff of preprocessed source we end up
> invoking an asm macro that doesn't seem to have a full final argument, I
> wonder if that's relevant...
> 
> -___EXPORT_SYMBOL __memset, __memset, ; ___EXPORT_SYMBOL memset, memset,
> +___EXPORT_SYMBOL __memset, __memset,
> +___EXPORT_SYMBOL memset, memset,
> 
> I also notice that nowhere else in the source do people have multiple
> EXPORT_SYMBOLs on the same line, and other arches seem to just
> unconditionally export both symbols on multiple lines.
> 
> I have no idea how this works for you - maybe it's affected by something 32bit.
> 
> How would you feel about this approach instead? I'm not tied to any of
> the names or anything.
> 
> diff --git a/arch/powerpc/include/asm/ppc_asm.h b/arch/powerpc/include/asm/ppc_asm.h
> index e0637730a8e7..7b6a91b448dd 100644
> --- a/arch/powerpc/include/asm/ppc_asm.h
> +++ b/arch/powerpc/include/asm/ppc_asm.h
> @@ -214,6 +214,9 @@ name: \
>   
>   #define DOTSYM(a)      a
>   
> +#define PROVIDE_WEAK_ALIAS(strongname, weakname) \
> +       .weak weakname ; .set weakname, strongname ;
> +
>   #else
>   
>   #define XGLUE(a,b) a##b
> @@ -236,6 +239,10 @@ GLUE(.,name):
>   
>   #define DOTSYM(a)      GLUE(.,a)
>   
> +#define PROVIDE_WEAK_ALIAS(strongname, weakname) \
> +       .weak weakname ; .set weakname, strongname ; \
> +       .weak DOTSYM(weakname) ; .set DOTSYM(weakname), DOTSYM(strongname) ;
> +
>   #endif
>   
>   #else /* 32-bit */
> @@ -251,6 +258,9 @@ GLUE(.,name):
>   
>   #define _GLOBAL_TOC(name) _GLOBAL(name)
>   
> +#define PROVIDE_WEAK_ALIAS(strongname, weakname) \
> +       .weak weakname ; .set weakname, strongname ;
> +
>   #endif
>   
>   /*
> --- a/arch/powerpc/lib/mem_64.S
> +++ b/arch/powerpc/lib/mem_64.S
> @@ -33,7 +33,8 @@ EXPORT_SYMBOL(__memset32)
>   EXPORT_SYMBOL(__memset64)
>   #endif
>   
> -_GLOBAL_KASAN(memset)
> +PROVIDE_WEAK_ALIAS(__memset,memset)
> +_GLOBAL(__memset)
>          neg     r0,r3
>          rlwimi  r4,r4,8,16,23
>          andi.   r0,r0,7                 /* # bytes to be 8-byte aligned */
> @@ -98,9 +99,11 @@ _GLOBAL_KASAN(memset)
>   10:    bflr    31
>          stb     r4,0(r6)
>          blr
> -EXPORT_SYMBOL_KASAN(memset)
> +EXPORT_SYMBOL(memset)
> +EXPORT_SYMBOL(__memset)
>   
> -_GLOBAL_TOC_KASAN(memmove)
> +PROVIDE_WEAK_ALIAS(__memmove,memove)
> +_GLOBAL_TOC(__memmove)
>          cmplw   0,r3,r4
>          bgt     backwards_memcpy
>          b       memcpy
> @@ -141,4 +144,5 @@ _GLOBAL(backwards_memcpy)
>          beq     2b
>          mtctr   r7
>          b       1b
> -EXPORT_SYMBOL_KASAN(memmove)
> +EXPORT_SYMBOL(memmove)
> +EXPORT_SYMBOL(__memmove)
> diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
> index 862b515b8868..7c1b09556cad 100644
> --- a/arch/powerpc/lib/memcpy_64.S
> +++ b/arch/powerpc/lib/memcpy_64.S
> @@ -19,7 +19,8 @@
>   #endif
>   
>          .align  7
> -_GLOBAL_TOC_KASAN(memcpy)
> +PROVIDE_WEAK_ALIAS(__memcpy,memcpy)
> +_GLOBAL_TOC(__memcpy)
>   BEGIN_FTR_SECTION
>   #ifdef __LITTLE_ENDIAN__
>          cmpdi   cr7,r5,0
> @@ -230,4 +231,5 @@ END_FTR_SECTION_IFCLR(CPU_FTR_UNALIGNED_LD_STD)
>   4:     ld      r3,-STACKFRAMESIZE+STK_REG(R31)(r1)     /* return dest pointer */
>          blr
>   #endif
> -EXPORT_SYMBOL_KASAN(memcpy)
> +EXPORT_SYMBOL(__memcpy)
> +EXPORT_SYMBOL(memcpy)
> 
> 
> Regards,
> Daniel
> 
> 
>> +#else
>> +#define _GLOBAL_KASAN(fn)	_GLOBAL(fn)
>> +#define _GLOBAL_TOC_KASAN(fn)	_GLOBAL_TOC(fn)
>> +#define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(fn)
>> +#endif
>> +
>> +#endif
>> diff --git a/arch/powerpc/include/asm/string.h b/arch/powerpc/include/asm/string.h
>> index 1647de15a31e..9bf6dffb4090 100644
>> --- a/arch/powerpc/include/asm/string.h
>> +++ b/arch/powerpc/include/asm/string.h
>> @@ -4,14 +4,17 @@
>>   
>>   #ifdef __KERNEL__
>>   
>> +#ifndef CONFIG_KASAN
>>   #define __HAVE_ARCH_STRNCPY
>>   #define __HAVE_ARCH_STRNCMP
>> +#define __HAVE_ARCH_MEMCHR
>> +#define __HAVE_ARCH_MEMCMP
>> +#define __HAVE_ARCH_MEMSET16
>> +#endif
>> +
>>   #define __HAVE_ARCH_MEMSET
>>   #define __HAVE_ARCH_MEMCPY
>>   #define __HAVE_ARCH_MEMMOVE
>> -#define __HAVE_ARCH_MEMCMP
>> -#define __HAVE_ARCH_MEMCHR
>> -#define __HAVE_ARCH_MEMSET16
>>   #define __HAVE_ARCH_MEMCPY_FLUSHCACHE
>>   
>>   extern char * strcpy(char *,const char *);
>> @@ -27,7 +30,27 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
>>   extern void * memchr(const void *,int,__kernel_size_t);
>>   extern void * memcpy_flushcache(void *,const void *,__kernel_size_t);
>>   
>> +void *__memset(void *s, int c, __kernel_size_t count);
>> +void *__memcpy(void *to, const void *from, __kernel_size_t n);
>> +void *__memmove(void *to, const void *from, __kernel_size_t n);
>> +
>> +#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
>> +/*
>> + * For files that are not instrumented (e.g. mm/slub.c) we
>> + * should use not instrumented version of mem* functions.
>> + */
>> +#define memcpy(dst, src, len) __memcpy(dst, src, len)
>> +#define memmove(dst, src, len) __memmove(dst, src, len)
>> +#define memset(s, c, n) __memset(s, c, n)
>> +
>> +#ifndef __NO_FORTIFY
>> +#define __NO_FORTIFY /* FORTIFY_SOURCE uses __builtin_memcpy, etc. */
>> +#endif
>> +
>> +#endif
>> +
>>   #ifdef CONFIG_PPC64
>> +#ifndef CONFIG_KASAN
>>   #define __HAVE_ARCH_MEMSET32
>>   #define __HAVE_ARCH_MEMSET64
>>   
>> @@ -49,8 +72,11 @@ static inline void *memset64(uint64_t *p, uint64_t v, __kernel_size_t n)
>>   {
>>   	return __memset64(p, v, n * 8);
>>   }
>> +#endif
>>   #else
>> +#ifndef CONFIG_KASAN
>>   #define __HAVE_ARCH_STRLEN
>> +#endif
>>   
>>   extern void *memset16(uint16_t *, uint16_t, __kernel_size_t);
>>   #endif
>> diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
>> index 667df97d2595..181fd10008ef 100644
>> --- a/arch/powerpc/kernel/prom_init_check.sh
>> +++ b/arch/powerpc/kernel/prom_init_check.sh
>> @@ -16,8 +16,16 @@
>>   # If you really need to reference something from prom_init.o add
>>   # it to the list below:
>>   
>> +grep "^CONFIG_KASAN=y$" .config >/dev/null
>> +if [ $? -eq 0 ]
>> +then
>> +	MEM_FUNCS="__memcpy __memset"
>> +else
>> +	MEM_FUNCS="memcpy memset"
>> +fi
>> +
>>   WHITELIST="add_reloc_offset __bss_start __bss_stop copy_and_flush
>> -_end enter_prom memcpy memset reloc_offset __secondary_hold
>> +_end enter_prom $MEM_FUNCS reloc_offset __secondary_hold
>>   __secondary_hold_acknowledge __secondary_hold_spinloop __start
>>   strcmp strcpy strlcpy strlen strncmp strstr kstrtobool logo_linux_clut224
>>   reloc_got2 kernstart_addr memstart_addr linux_banner _stext
>> diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
>> index 79396e184bca..47a4de434c22 100644
>> --- a/arch/powerpc/lib/Makefile
>> +++ b/arch/powerpc/lib/Makefile
>> @@ -8,9 +8,14 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
>>   CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
>>   CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
>>   
>> -obj-y += string.o alloc.o code-patching.o feature-fixups.o
>> +obj-y += alloc.o code-patching.o feature-fixups.o
>>   
>> -obj-$(CONFIG_PPC32)	+= div64.o copy_32.o crtsavres.o strlen_32.o
>> +ifndef CONFIG_KASAN
>> +obj-y	+=	string.o memcmp_$(BITS).o
>> +obj-$(CONFIG_PPC32)	+= strlen_32.o
>> +endif
>> +
>> +obj-$(CONFIG_PPC32)	+= div64.o copy_32.o crtsavres.o
>>   
>>   obj-$(CONFIG_FUNCTION_ERROR_INJECTION)	+= error-inject.o
>>   
>> @@ -34,7 +39,7 @@ obj64-$(CONFIG_KPROBES_SANITY_TEST)	+= test_emulate_step.o \
>>   					   test_emulate_step_exec_instr.o
>>   
>>   obj-y			+= checksum_$(BITS).o checksum_wrappers.o \
>> -			   string_$(BITS).o memcmp_$(BITS).o
>> +			   string_$(BITS).o
>>   
>>   obj-y			+= sstep.o ldstfp.o quad.o
>>   obj64-y			+= quad.o
>> diff --git a/arch/powerpc/lib/copy_32.S b/arch/powerpc/lib/copy_32.S
>> index ba66846fe973..fc4fa7246200 100644
>> --- a/arch/powerpc/lib/copy_32.S
>> +++ b/arch/powerpc/lib/copy_32.S
>> @@ -14,6 +14,7 @@
>>   #include <asm/ppc_asm.h>
>>   #include <asm/export.h>
>>   #include <asm/code-patching-asm.h>
>> +#include <asm/kasan.h>
>>   
>>   #define COPY_16_BYTES		\
>>   	lwz	r7,4(r4);	\
>> @@ -68,6 +69,7 @@ CACHELINE_BYTES = L1_CACHE_BYTES
>>   LG_CACHELINE_BYTES = L1_CACHE_SHIFT
>>   CACHELINE_MASK = (L1_CACHE_BYTES-1)
>>   
>> +#ifndef CONFIG_KASAN
>>   _GLOBAL(memset16)
>>   	rlwinm.	r0 ,r5, 31, 1, 31
>>   	addi	r6, r3, -4
>> @@ -81,6 +83,7 @@ _GLOBAL(memset16)
>>   	sth	r4, 4(r6)
>>   	blr
>>   EXPORT_SYMBOL(memset16)
>> +#endif
>>   
>>   /*
>>    * Use dcbz on the complete cache lines in the destination
>> @@ -91,7 +94,7 @@ EXPORT_SYMBOL(memset16)
>>    * We therefore skip the optimised bloc that uses dcbz. This jump is
>>    * replaced by a nop once cache is active. This is done in machine_init()
>>    */
>> -_GLOBAL(memset)
>> +_GLOBAL_KASAN(memset)
>>   	cmplwi	0,r5,4
>>   	blt	7f
>>   
>> @@ -150,7 +153,7 @@ _GLOBAL(memset)
>>   9:	stbu	r4,1(r6)
>>   	bdnz	9b
>>   	blr
>> -EXPORT_SYMBOL(memset)
>> +EXPORT_SYMBOL_KASAN(memset)
>>   
>>   /*
>>    * This version uses dcbz on the complete cache lines in the
>> @@ -163,12 +166,12 @@ EXPORT_SYMBOL(memset)
>>    * We therefore jump to generic_memcpy which doesn't use dcbz. This jump is
>>    * replaced by a nop once cache is active. This is done in machine_init()
>>    */
>> -_GLOBAL(memmove)
>> +_GLOBAL_KASAN(memmove)
>>   	cmplw	0,r3,r4
>>   	bgt	backwards_memcpy
>>   	/* fall through */
>>   
>> -_GLOBAL(memcpy)
>> +_GLOBAL_KASAN(memcpy)
>>   1:	b	generic_memcpy
>>   	patch_site	1b, patch__memcpy_nocache
>>   
>> @@ -242,8 +245,8 @@ _GLOBAL(memcpy)
>>   	stbu	r0,1(r6)
>>   	bdnz	40b
>>   65:	blr
>> -EXPORT_SYMBOL(memcpy)
>> -EXPORT_SYMBOL(memmove)
>> +EXPORT_SYMBOL_KASAN(memcpy)
>> +EXPORT_SYMBOL_KASAN(memmove)
>>   
>>   generic_memcpy:
>>   	srwi.	r7,r5,3
>> diff --git a/arch/powerpc/lib/mem_64.S b/arch/powerpc/lib/mem_64.S
>> index 3c3be02f33b7..7cd6cf6822a2 100644
>> --- a/arch/powerpc/lib/mem_64.S
>> +++ b/arch/powerpc/lib/mem_64.S
>> @@ -12,7 +12,9 @@
>>   #include <asm/errno.h>
>>   #include <asm/ppc_asm.h>
>>   #include <asm/export.h>
>> +#include <asm/kasan.h>
>>   
>> +#ifndef CONFIG_KASAN
>>   _GLOBAL(__memset16)
>>   	rlwimi	r4,r4,16,0,15
>>   	/* fall through */
>> @@ -29,8 +31,9 @@ _GLOBAL(__memset64)
>>   EXPORT_SYMBOL(__memset16)
>>   EXPORT_SYMBOL(__memset32)
>>   EXPORT_SYMBOL(__memset64)
>> +#endif
>>   
>> -_GLOBAL(memset)
>> +_GLOBAL_KASAN(memset)
>>   	neg	r0,r3
>>   	rlwimi	r4,r4,8,16,23
>>   	andi.	r0,r0,7			/* # bytes to be 8-byte aligned */
>> @@ -95,9 +98,9 @@ _GLOBAL(memset)
>>   10:	bflr	31
>>   	stb	r4,0(r6)
>>   	blr
>> -EXPORT_SYMBOL(memset)
>> +EXPORT_SYMBOL_KASAN(memset)
>>   
>> -_GLOBAL_TOC(memmove)
>> +_GLOBAL_TOC_KASAN(memmove)
>>   	cmplw	0,r3,r4
>>   	bgt	backwards_memcpy
>>   	b	memcpy
>> @@ -138,4 +141,4 @@ _GLOBAL(backwards_memcpy)
>>   	beq	2b
>>   	mtctr	r7
>>   	b	1b
>> -EXPORT_SYMBOL(memmove)
>> +EXPORT_SYMBOL_KASAN(memmove)
>> diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
>> index 273ea67e60a1..862b515b8868 100644
>> --- a/arch/powerpc/lib/memcpy_64.S
>> +++ b/arch/powerpc/lib/memcpy_64.S
>> @@ -11,6 +11,7 @@
>>   #include <asm/export.h>
>>   #include <asm/asm-compat.h>
>>   #include <asm/feature-fixups.h>
>> +#include <asm/kasan.h>
>>   
>>   #ifndef SELFTEST_CASE
>>   /* For big-endian, 0 == most CPUs, 1 == POWER6, 2 == Cell */
>> @@ -18,7 +19,7 @@
>>   #endif
>>   
>>   	.align	7
>> -_GLOBAL_TOC(memcpy)
>> +_GLOBAL_TOC_KASAN(memcpy)
>>   BEGIN_FTR_SECTION
>>   #ifdef __LITTLE_ENDIAN__
>>   	cmpdi	cr7,r5,0
>> @@ -229,4 +230,4 @@ END_FTR_SECTION_IFCLR(CPU_FTR_UNALIGNED_LD_STD)
>>   4:	ld	r3,-STACKFRAMESIZE+STK_REG(R31)(r1)	/* return dest pointer */
>>   	blr
>>   #endif
>> -EXPORT_SYMBOL(memcpy)
>> +EXPORT_SYMBOL_KASAN(memcpy)
>> -- 
>> 2.13.3

