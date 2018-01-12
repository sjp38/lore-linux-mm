Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A84E56B0261
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 11:49:59 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id i66so747865oih.5
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 08:49:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b47sor8500092oth.255.2018.01.12.08.49.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jan 2018 08:49:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <c8f1d954-64fe-1e9c-d8ba-94e880de2501@virtuozzo.com>
References: <cover.1515684162.git.andreyknvl@google.com> <ff221eca3db7a1f208c30c625b7d209fba33abb9.1515684162.git.andreyknvl@google.com>
 <c8f1d954-64fe-1e9c-d8ba-94e880de2501@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 12 Jan 2018 17:49:57 +0100
Message-ID: <CAAeHK+y=1YedHu=+1pjau=2cYh822vGuNLK_6Q4gYh9eGZBeMg@mail.gmail.com>
Subject: Re: [PATCH 2/2] kasan: clean up KASAN_SHADOW_SCALE_SHIFT usage
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Kostya Serebryany <kcc@google.com>

On Thu, Jan 11, 2018 at 10:59 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 01/11/2018 06:29 PM, Andrey Konovalov wrote:
>
>> diff --git a/arch/arm64/include/asm/kasan.h b/arch/arm64/include/asm/kasan.h
>> index e266f80e45b7..811643fe7640 100644
>> --- a/arch/arm64/include/asm/kasan.h
>> +++ b/arch/arm64/include/asm/kasan.h
>> @@ -27,7 +27,8 @@
>>   * should satisfy the following equation:
>>   *      KASAN_SHADOW_OFFSET = KASAN_SHADOW_END - (1ULL << 61)
>
> Care to update comments as well?

Sure, done in v2.

>
>>   */
>> -#define KASAN_SHADOW_OFFSET     (KASAN_SHADOW_END - (1ULL << (64 - 3)))
>> +#define KASAN_SHADOW_OFFSET     (KASAN_SHADOW_END - (1ULL << \
>> +                                     (64 - KASAN_SHADOW_SCALE_SHIFT)))
>>
>>  void kasan_init(void);
>>  void kasan_copy_shadow(pgd_t *pgdir);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
