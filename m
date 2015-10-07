Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8416B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 06:04:18 -0400 (EDT)
Received: by qgt47 with SMTP id 47so10722456qgt.2
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 03:04:17 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f137si33447043qhc.122.2015.10.07.03.04.17
        for <linux-mm@kvack.org>;
        Wed, 07 Oct 2015 03:04:17 -0700 (PDT)
Date: Wed, 7 Oct 2015 11:04:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v6 0/6] KASAN for arm64
Message-ID: <20151007100411.GG3069@e104818-lin.cambridge.arm.com>
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

On Thu, Sep 17, 2015 at 12:38:06PM +0300, Andrey Ryabinin wrote:
> As usual patches available in git
> 	git://github.com/aryabinin/linux.git kasan/arm64v6
> 
> Changes since v5:
>  - Rebase on top of 4.3-rc1
>  - Fixed EFI boot.
>  - Updated Doc/features/KASAN.

I tried to merge these patches (apart from the x86 one which is already
merged) but it still doesn't boot on Juno as an EFI application.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
