Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 28EAE6B0038
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 04:13:16 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so48824342pdj.3
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 01:13:15 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id fk4si41056412pab.16.2015.07.27.01.13.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 01:13:15 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NS5009SI05YU040@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jul 2015 09:13:10 +0100 (BST)
Message-id: <55B5E814.2020507@samsung.com>
Date: Mon, 27 Jul 2015 11:13:08 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v4 0/7] KASAN for arm64
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
Content-type: text/plain; charset=windows-1251
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>

On 07/24/2015 07:41 PM, Andrey Ryabinin wrote:
>  - fix memleak in kasan_populate_zero_shadow:
>        Following code could leak memory when pgd_populate() is nop:
> 		void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
> 		pgd_populate(&init_mm, pgd, p);

It's not a leak actually, because this code is under if (pgd_none(*pgd)).
But gcc complains warns about unused variable p, so this has to be changed anyways.

> 	This was replaced by:
> 	     	 pgd_populate(&init_mm, pgd, early_alloc(PAGE_SIZE, NUMA_NO_NODE));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
