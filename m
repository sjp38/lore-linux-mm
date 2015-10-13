Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C4CE56B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 04:34:38 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so15061861pab.2
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 01:34:38 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x8si3511818pbt.32.2015.10.13.01.34.37
        for <linux-mm@kvack.org>;
        Tue, 13 Oct 2015 01:34:37 -0700 (PDT)
Date: Tue, 13 Oct 2015 09:34:32 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v7 0/4] KASAN for arm64
Message-ID: <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

On Mon, Oct 12, 2015 at 06:52:56PM +0300, Andrey Ryabinin wrote:
> Andrey Ryabinin (3):
>   arm64: move PGD_SIZE definition to pgalloc.h
>   arm64: add KASAN support
>   Documentation/features/KASAN: arm64 supports KASAN now
> 
> Linus Walleij (1):
>   ARM64: kasan: print memory assignment

Patches queued for 4.4. Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
