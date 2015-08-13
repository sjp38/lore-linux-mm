Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id E37456B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 02:50:46 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so126978106wic.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:50:46 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id fz7si2223454wjc.198.2015.08.12.23.50.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 23:50:45 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so126977311wic.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:50:44 -0700 (PDT)
Date: Thu, 13 Aug 2015 08:50:41 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/2] x86/KASAN updates for 4.3
Message-ID: <20150813065040.GA17983@gmail.com>
References: <1439444244-26057-1-git-send-email-ryabinin.a.a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439444244-26057-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>


* Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:

> These 2 patches taken from v5 'KASAN for arm64' series.
> The only change is updated changelog in second patch.
> 
> I hope this is not too late to queue these for 4.3,
> as this allow us to merge arm64/KASAN patches in v4.4
> through arm64 tree.
> 
> Andrey Ryabinin (2):
>   x86/kasan: define KASAN_SHADOW_OFFSET per architecture
>   x86/kasan, mm: introduce generic kasan_populate_zero_shadow()
> 
>  arch/x86/include/asm/kasan.h |   3 +
>  arch/x86/mm/kasan_init_64.c  | 123 ++--------------------------------
>  include/linux/kasan.h        |  10 ++-
>  mm/kasan/Makefile            |   2 +-
>  mm/kasan/kasan_init.c        | 152 +++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 170 insertions(+), 120 deletions(-)
>  create mode 100644 mm/kasan/kasan_init.c

It's absolutely too late in the -rc cycle for v4.3!

I can create a stable topic tree for it, tip:mm/kasan or so, which arm64 could 
pull and base its own ARM specific work on, if that's OK with everyone.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
