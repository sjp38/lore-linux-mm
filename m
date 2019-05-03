Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 573C3C43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 07:38:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AC80205F4
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 07:38:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="g6fjTQ0J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AC80205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5E206B0005; Fri,  3 May 2019 03:38:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A356F6B0007; Fri,  3 May 2019 03:38:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9245D6B0008; Fri,  3 May 2019 03:38:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44C8C6B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 03:38:09 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id j126so3714140wma.8
        for <linux-mm@kvack.org>; Fri, 03 May 2019 00:38:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=22Xq3HEvd6Yru88xMDUMXzEqbO1waVFeR8bEmAMWSqI=;
        b=hUNgtgu3Kyeq5HgKV5s6DpsGdvIynhRQa+KxLHDi49er28ibwWBjlZv0XSSMjhLo52
         lnoLs2Hfezm2I6vIua27F/ONTWtXPBdoZ2r3OmZnPE2yLj4N2IR9Pa1cEj+TirXgvxnw
         WxllbHsW2Sp4bY4ELSn/f5785n9ihCvZ7pkf7CkEZ8d45ywJxpM8Aes2Nk96oftXRinD
         O7PZMzhOBXXplMyrCnLuJsO4/PR3tR0+nJ2hPxI/u00KyNlJcpY7S4n4UeiclHZgiw/N
         f9eNAdSd6infrODW7N6nL0IIMR43i9CLnVM2M+iyZNHA1y021GuFAWHf5ZxD2x8TYf6e
         fINA==
X-Gm-Message-State: APjAAAVghXg4ur4dEzKc4uEnQ4dUbBwDR95A1TVRy/tnMY8rH7OW5WbD
	XG74xBymmzv6ezDuMVjrX3AI+jlWeJZoLcJ8MZm6ijT9JwwmV0QtKrvXogvNQ9szs8xHN4pOyRh
	WKvv200XcLsj59dGfEAhe5FLOP4n5jLKbGbw5oM+fm2ZEa8a6nSZZK2lw/uw9cdWlTw==
X-Received: by 2002:adf:f7cd:: with SMTP id a13mr6059757wrq.289.1556869088870;
        Fri, 03 May 2019 00:38:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsVV8wcF9dYvvX5AAY5MBTZZXxdFOn8zlxIF3coDmMGwfNBuhg7oOu6UfBLdren0GzSUDD
X-Received: by 2002:adf:f7cd:: with SMTP id a13mr6059703wrq.289.1556869088107;
        Fri, 03 May 2019 00:38:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556869088; cv=none;
        d=google.com; s=arc-20160816;
        b=XIn2EKCXy8zSmAhn8MuKAIiiuWRSh42jYjvFwW0W/v89Rt53uZojEEg10+aB+Buiz2
         napPDxLCuEJPmiT/FNYYEOXo7DMbgHj1H/e9ikJpAClTVzPZcrm3ozi6qyNZryZrdhd9
         98UzwivbXhAtK66jKm3PqdqTbryFWrVVD+ZsDxorN3+Fs/zuQNq5xzqRyzgeLsm83/WA
         CuxQsmnj7O4LU2FOZJ3jH5vKKbPM0dltQu7Jc/8KnQY36R42TdO3LVz0Tjc/wp+4BsZ0
         wbPnJKTkF+9lRN9X39KLo8FsqW9/xW752AXnlQX60mX3oo85jusTd/VaJ1vVgJ2f1c0o
         UsmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=22Xq3HEvd6Yru88xMDUMXzEqbO1waVFeR8bEmAMWSqI=;
        b=zFnuzmzy2lnMwchvM5QuZ9aX7aGcp5uBMdEigLN3jkI+xS/qIq2gU271dpEuIqF90w
         QvSfDoXUDmh1BUdYZrh4npCsE7VTammtvAyrO3y2YW55cT2eF0SGivChGZSLYo41wplx
         vtJ+OQwYI09HpTh9k3Qbab8dW39vjHia7DyfNyMK0A3WK/mPgw93cTwBblCaby9oKPOI
         CVOhbTLL7DzKpnZOtRVmjDKj1gzqGU1QvnwPQkvMOwS/9huJ9HxEi7Vl9FVgus571U7t
         Hqva1VR5OhkbSOupW9S/ab1xmdwEJqQ3fX6VvIB/rAd9xUIcyITprI3KlymC1KnI/axb
         2fHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=g6fjTQ0J;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id a12si1176434wrf.357.2019.05.03.00.38.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 00:38:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=g6fjTQ0J;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44wPB63Wcfz9vFVp;
	Fri,  3 May 2019 09:38:06 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=g6fjTQ0J; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id Q6TCMmlYgt_T; Fri,  3 May 2019 09:38:06 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44wPB62PVJz9vFVk;
	Fri,  3 May 2019 09:38:06 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556869086; bh=22Xq3HEvd6Yru88xMDUMXzEqbO1waVFeR8bEmAMWSqI=;
	h=Subject:From:To:Cc:References:Date:In-Reply-To:From;
	b=g6fjTQ0JL6fwAUUHq8KpW3v/DHKD9rNsQD9jXKP6PVsqfF71wJQKid60dMBEjOjo/
	 CoL7j3j9LGBMaJdHGjv1jKHgt9s8cdw2G2D4RCHc+zjKGifCuOHw1si6VIDL07vOJg
	 jd6jSKg4onNj6/g1KOMELNwy1JLElux28bsad5iw=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 556958B888;
	Fri,  3 May 2019 09:38:07 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id ppmZKOEr5jsr; Fri,  3 May 2019 09:38:07 +0200 (CEST)
Received: from PO15451 (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0CA268B853;
	Fri,  3 May 2019 09:38:07 +0200 (CEST)
Subject: Re: [PATCH v11 09/13] powerpc: disable KASAN instrumentation on
 early/critical files.
From: Christophe Leroy <christophe.leroy@c-s.fr>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Daniel Axtens <dja@axtens.net>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
 <867c149e77f80e855a9310a490fb15ca03ffd63d.1556295461.git.christophe.leroy@c-s.fr>
Message-ID: <5cff9551-e0ce-a2a4-989c-6b55825fa171@c-s.fr>
Date: Fri, 3 May 2019 09:38:06 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <867c149e77f80e855a9310a490fb15ca03ffd63d.1556295461.git.christophe.leroy@c-s.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 26/04/2019 à 18:23, Christophe Leroy a écrit :
> All files containing functions run before kasan_early_init() is called
> must have KASAN instrumentation disabled.
> 
> For those file, branch profiling also have to be disabled otherwise
> each if () generates a call to ftrace_likely_update().
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>   arch/powerpc/kernel/Makefile             | 12 ++++++++++++
>   arch/powerpc/lib/Makefile                |  8 ++++++++
>   arch/powerpc/mm/Makefile                 |  6 ++++++
>   arch/powerpc/platforms/powermac/Makefile |  6 ++++++
>   arch/powerpc/purgatory/Makefile          |  3 +++
>   arch/powerpc/xmon/Makefile               |  1 +
>   6 files changed, 36 insertions(+)
> 

[...]

> diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
> index 3c1bd9fa23cd..dd945ca869b2 100644
> --- a/arch/powerpc/mm/Makefile
> +++ b/arch/powerpc/mm/Makefile
> @@ -7,6 +7,12 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
>   
>   CFLAGS_REMOVE_slb.o = $(CC_FLAGS_FTRACE)
>   
> +KASAN_SANITIZE_ppc_mmu_32.o := n
> +
> +ifdef CONFIG_KASAN
> +CFLAGS_ppc_mmu_32.o  		+= -DDISABLE_BRANCH_PROFILING
> +endif
> +

The above is missing in powerpc/next (should now be in 
arch/powerpc/mm/book3s32/Makefile )

Christophe

