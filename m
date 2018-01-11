Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DAFC6B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 17:00:10 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w186so3123067pgb.10
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 14:00:10 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00129.outbound.protection.outlook.com. [40.107.0.129])
        by mx.google.com with ESMTPS id b126si12601338pgc.610.2018.01.11.14.00.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 14:00:09 -0800 (PST)
Subject: Re: [PATCH 2/2] kasan: clean up KASAN_SHADOW_SCALE_SHIFT usage
References: <cover.1515684162.git.andreyknvl@google.com>
 <ff221eca3db7a1f208c30c625b7d209fba33abb9.1515684162.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <c8f1d954-64fe-1e9c-d8ba-94e880de2501@virtuozzo.com>
Date: Fri, 12 Jan 2018 00:59:57 +0300
MIME-Version: 1.0
In-Reply-To: <ff221eca3db7a1f208c30c625b7d209fba33abb9.1515684162.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>



On 01/11/2018 06:29 PM, Andrey Konovalov wrote:

> diff --git a/arch/arm64/include/asm/kasan.h b/arch/arm64/include/asm/kasan.h
> index e266f80e45b7..811643fe7640 100644
> --- a/arch/arm64/include/asm/kasan.h
> +++ b/arch/arm64/include/asm/kasan.h
> @@ -27,7 +27,8 @@
>   * should satisfy the following equation:
>   *      KASAN_SHADOW_OFFSET = KASAN_SHADOW_END - (1ULL << 61)

Care to update comments as well?

>   */
> -#define KASAN_SHADOW_OFFSET     (KASAN_SHADOW_END - (1ULL << (64 - 3)))
> +#define KASAN_SHADOW_OFFSET     (KASAN_SHADOW_END - (1ULL << \
> +					(64 - KASAN_SHADOW_SCALE_SHIFT)))
>  
>  void kasan_init(void);
>  void kasan_copy_shadow(pgd_t *pgdir);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
