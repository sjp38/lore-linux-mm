Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 568939003C7
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 12:57:56 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so85531620igb.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 09:57:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id hd4si16389445icb.7.2015.07.27.09.57.55
        for <linux-mm@kvack.org>;
        Mon, 27 Jul 2015 09:57:55 -0700 (PDT)
Date: Mon, 27 Jul 2015 17:57:50 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v4 7/7] x86/kasan: switch to generic
 kasan_populate_zero_shadow()
Message-ID: <20150727165749.GD350@e104818-lin.cambridge.arm.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
 <1437756119-12817-8-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437756119-12817-8-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Fri, Jul 24, 2015 at 07:41:59PM +0300, Andrey Ryabinin wrote:
> Now when we have generic kasan_populate_zero_shadow() we could
> use it for x86.
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

In the interest of facilitating the upstreaming of these patches (when
ready ;), can you merge this patch with 2/7? The second patch is already
touching x86, so just call it something like "x86/kasan: Generalise
kasan shadow mapping initialisation".

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
