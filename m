Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC996B0255
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 12:30:46 -0400 (EDT)
Received: by lbbtg9 with SMTP id tg9so9662562lbb.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 09:30:45 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id r8si1728113lbh.6.2015.08.11.09.30.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 09:30:44 -0700 (PDT)
Received: by lbbsx3 with SMTP id sx3so32986430lbb.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 09:30:44 -0700 (PDT)
Subject: Re: [PATCH v5 2/6] x86/kasan, mm: introduce generic
 kasan_populate_zero_shadow()
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
 <1439259499-13913-3-git-send-email-ryabinin.a.a@gmail.com>
 <20150811154117.GH23307@e104818-lin.cambridge.arm.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <55CA2332.7040206@gmail.com>
Date: Tue, 11 Aug 2015 19:30:42 +0300
MIME-Version: 1.0
In-Reply-To: <20150811154117.GH23307@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>



On 08/11/2015 06:41 PM, Catalin Marinas wrote:
> On Tue, Aug 11, 2015 at 05:18:15AM +0300, Andrey Ryabinin wrote:
>> --- /dev/null
>> +++ b/mm/kasan/kasan_init.c
> [...]
>> +#if CONFIG_PGTABLE_LEVELS > 3
>> +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
>> +#endif
>> +#if CONFIG_PGTABLE_LEVELS > 2
>> +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
>> +#endif
>> +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
> 
> Is there any problem if you don't add the #ifs here? Wouldn't the linker
> remove them if they are not used?
> 

AFAIK such optimization is possible if we build with -fdata-sections flag and
use --gc-sections flag in linker, but we don't do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
