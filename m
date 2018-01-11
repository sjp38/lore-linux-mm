Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9101B6B026E
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 12:33:08 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id s136so936034oie.0
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 09:33:08 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c5si5276729oif.347.2018.01.11.09.33.07
        for <linux-mm@kvack.org>;
        Thu, 11 Jan 2018 09:33:07 -0800 (PST)
Date: Thu, 11 Jan 2018 17:33:10 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/2] kasan: clean up KASAN_SHADOW_SCALE_SHIFT usage
Message-ID: <20180111173309.GG13216@arm.com>
References: <cover.1515684162.git.andreyknvl@google.com>
 <ff221eca3db7a1f208c30c625b7d209fba33abb9.1515684162.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ff221eca3db7a1f208c30c625b7d209fba33abb9.1515684162.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-kernel@vger.kernel.org, Kostya Serebryany <kcc@google.com>

On Thu, Jan 11, 2018 at 04:29:09PM +0100, Andrey Konovalov wrote:
> Right now the fact that KASAN uses a single shadow byte for 8 bytes of
> memory is scattered all over the code.
> 
> This change defines KASAN_SHADOW_SCALE_SHIFT early in asm include files
> and makes use of this constant where necessary.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/arm64/include/asm/kasan.h  | 3 ++-
>  arch/arm64/include/asm/memory.h | 3 ++-
>  arch/arm64/mm/kasan_init.c      | 3 ++-
>  arch/x86/include/asm/kasan.h    | 8 ++++++--
>  include/linux/kasan.h           | 2 --
>  5 files changed, 12 insertions(+), 7 deletions(-)

For the arm64 parts:

Acked-by: Will Deacon <will.deacon@arm.com>

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
