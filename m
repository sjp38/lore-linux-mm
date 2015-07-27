Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1526B9003C7
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 13:53:17 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so55638343pdr.2
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 10:53:16 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id kk7si45743673pab.132.2015.07.27.10.53.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 10:53:16 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NS500D9SR0N6K50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jul 2015 18:53:11 +0100 (BST)
Message-id: <55B67005.9030802@samsung.com>
Date: Mon, 27 Jul 2015 20:53:09 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v4 7/7] x86/kasan: switch to generic
 kasan_populate_zero_shadow()
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
 <1437756119-12817-8-git-send-email-a.ryabinin@samsung.com>
 <20150727165749.GD350@e104818-lin.cambridge.arm.com>
In-reply-to: <20150727165749.GD350@e104818-lin.cambridge.arm.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 07/27/2015 07:57 PM, Catalin Marinas wrote:
> On Fri, Jul 24, 2015 at 07:41:59PM +0300, Andrey Ryabinin wrote:
>> Now when we have generic kasan_populate_zero_shadow() we could
>> use it for x86.
>>
>> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> 
> In the interest of facilitating the upstreaming of these patches (when
> ready ;), can you merge this patch with 2/7? The second patch is already
> touching x86, so just call it something like "x86/kasan: Generalise
> kasan shadow mapping initialisation".
> 

Ok

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
