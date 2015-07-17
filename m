Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 42032280319
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 09:13:19 -0400 (EDT)
Received: by pacan13 with SMTP id an13so61151809pac.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 06:13:19 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id xs3si18614351pbb.215.2015.07.17.06.13.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 06:13:18 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NRM00CHIVE1Y080@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 17 Jul 2015 14:13:14 +0100 (BST)
Message-id: <55A8FF63.70505@samsung.com>
Date: Fri, 17 Jul 2015 16:13:07 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <20150708154803.GE6944@e104818-lin.cambridge.arm.com>
 <559FFCA7.4060008@samsung.com>
 <20150714150445.GH13555@e104818-lin.cambridge.arm.com>
 <55A61FF8.9000603@samsung.com>
 <20150715163732.GF20186@e104818-lin.cambridge.arm.com>
 <55A7CE03.301@samsung.com>
 <20150716160313.GC26865@e104818-lin.cambridge.arm.com>
In-reply-to: <20150716160313.GC26865@e104818-lin.cambridge.arm.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Arnd Bergmann <arnd@arndb.de>, David Keitel <dkeitel@codeaurora.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On 07/16/2015 07:03 PM, Catalin Marinas wrote:
> On Thu, Jul 16, 2015 at 06:30:11PM +0300, Andrey Ryabinin wrote:
>>
>> I think this may work, if pud_none(*pud) will be replaced with !pud_val(*pud).
>> We can't use pud_none() because with 2-level page tables it's always false, so
>> we will never go down to pmd level where swapper_pg_dir populated.
> 
> The reason I used "do ... while" vs "while" or "for" is so that it gets
> down to the pmd level. The iteration over pgd is always done in the top
> loop via pgd_addr_end while the loops for missing levels (nopud, nopmd)
> are always a single iteration whether we check for pud_none or not. But
> when the level is present, we avoid looping when !pud_none().
> 

Right, dunno what I was thinking.
It seems to work. Lightly tested with every possible CONFIG_PGTABLE_LEVELS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
