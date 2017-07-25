Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2FB6B02C3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:29:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t187so111184956pfb.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:29:04 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0096.outbound.protection.outlook.com. [104.47.0.96])
        by mx.google.com with ESMTPS id f7si1018436pgr.285.2017.07.25.08.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 08:29:03 -0700 (PDT)
Subject: Re: [PATCH] [v3] kasan: avoid -Wmaybe-uninitialized warning
References: <20170725152739.4176967-1-arnd@arndb.de>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <467b0241-da9a-6e91-d7be-b72618a24306@virtuozzo.com>
Date: Tue, 25 Jul 2017 18:31:23 +0300
MIME-Version: 1.0
In-Reply-To: <20170725152739.4176967-1-arnd@arndb.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/25/2017 06:27 PM, Arnd Bergmann wrote:
> gcc-7 produces this warning:
> 
> mm/kasan/report.c: In function 'kasan_report':
> mm/kasan/report.c:351:3: error: 'info.first_bad_addr' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>    print_shadow_for_address(info->first_bad_addr);
>    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> mm/kasan/report.c:360:27: note: 'info.first_bad_addr' was declared here
> 
> The code seems fine as we only print info.first_bad_addr when there is a shadow,
> and we always initialize it in that case, but this is relatively hard
> for gcc to figure out after the latest rework. Adding an intialization
> to the most likely value together with the other struct members
> shuts up that warning.
> 
> Fixes: b235b9808664 ("kasan: unify report headers")
> Link: https://patchwork.kernel.org/patch/9641417/
> Suggested-by: Alexander Potapenko <glider@google.com>
> Suggested-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
