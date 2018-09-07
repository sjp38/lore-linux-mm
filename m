Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D33E6B7F2F
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 12:10:11 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s205-v6so9786277wmf.7
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 09:10:11 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0135.outbound.protection.outlook.com. [104.47.2.135])
        by mx.google.com with ESMTPS id b6-v6si8003801wrr.379.2018.09.07.09.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Sep 2018 09:10:09 -0700 (PDT)
Subject: Re: [PATCH v6 00/18] khwasan: kernel hardware assisted address
 sanitizer
References: <cover.1535462971.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <8fb4852e-a88e-2d3b-88ba-4b73ac2c890d@virtuozzo.com>
Date: Fri, 7 Sep 2018 19:10:20 +0300
MIME-Version: 1.0
In-Reply-To: <cover.1535462971.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>



On 08/29/2018 02:35 PM, Andrey Konovalov wrote:

> Andrey Konovalov (18):
>   khwasan, mm: change kasan hooks signatures
>   khwasan: move common kasan and khwasan code to common.c
>   khwasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_HW
>   khwasan, arm64: adjust shadow size for CONFIG_KASAN_HW
>   khwasan: initialize shadow to 0xff
>   khwasan, arm64: untag virt address in __kimg_to_phys and
>     _virt_addr_is_linear
>   khwasan: add tag related helper functions
>   khwasan: preassign tags to objects with ctors or SLAB_TYPESAFE_BY_RCU
>   khwasan, arm64: fix up fault handling logic
>   khwasan, arm64: enable top byte ignore for the kernel
>   khwasan, mm: perform untagged pointers comparison in krealloc
>   khwasan: split out kasan_report.c from report.c
>   khwasan: add bug reporting routines
>   khwasan: add hooks implementation
>   khwasan, arm64: add brk handler for inline instrumentation
>   khwasan, mm, arm64: tag non slab memory allocated via pagealloc
>   khwasan: update kasan documentation
>   kasan: add SPDX-License-Identifier mark to source files
> 

Aside from nit in 16/18 patch looks fine for me.

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
