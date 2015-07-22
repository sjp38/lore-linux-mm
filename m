Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id F22C66B0256
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:21:51 -0400 (EDT)
Received: by qkdl129 with SMTP id l129so154045552qkd.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:21:51 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 40si1832957qkp.22.2015.07.22.07.21.50
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 07:21:51 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:21:45 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3 2/5] arm64: introduce VA_START macro - the first
 kernel virtual address.
Message-ID: <20150722142145.GB16627@e104818-lin.cambridge.arm.com>
References: <1437561037-31995-1-git-send-email-a.ryabinin@samsung.com>
 <1437561037-31995-3-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437561037-31995-3-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jul 22, 2015 at 01:30:34PM +0300, Andrey Ryabinin wrote:
> In order to not use lengthy (UL(0xffffffffffffffff) << VA_BITS) everywhere,
> replace it with VA_START.
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
