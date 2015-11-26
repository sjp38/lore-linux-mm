Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 21E5C6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 10:05:09 -0500 (EST)
Received: by pacej9 with SMTP id ej9so88734575pac.2
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 07:05:08 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w71si831755pfi.241.2015.11.26.07.05.08
        for <linux-mm@kvack.org>;
        Thu, 26 Nov 2015 07:05:08 -0800 (PST)
Date: Thu, 26 Nov 2015 15:05:01 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v7 0/4] KASAN for arm64
Message-ID: <20151126150501.GJ3109@e104818-lin.cambridge.arm.com>
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
 <5649BAFD.6030005@arm.com>
 <5649F783.40109@gmail.com>
 <564B40A7.1000206@arm.com>
 <564B4BFC.1020905@virtuozzo.com>
 <20151126121007.GC32343@leverpostej>
 <5656F991.8090108@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5656F991.8090108@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linus Walleij <linus.walleij@linaro.org>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Alexey Klimov <klimov.linux@gmail.com>, David Keitel <dkeitel@codeaurora.org>, Dmitry Vyukov <dvyukov@google.com>

On Thu, Nov 26, 2015 at 03:22:41PM +0300, Andrey Ryabinin wrote:
> On 11/26/2015 03:10 PM, Mark Rutland wrote:
> > Can you pick up Andrey's patch below for v4.4, until we have a better
> > solution?
> 
> FYI, better solution is almost ready, I'm going to send it today.
> However, I don't know for sure whether it works or not :)

I merged the Kconfig fix for 4.4, it's not a significant loss since I
don't expect anyone to jump onto the 16K page configuration. We'll take
the proper fix for 4.5.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
