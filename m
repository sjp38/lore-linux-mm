Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 254716B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 10:23:37 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id u56so2858445wes.18
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 07:23:36 -0700 (PDT)
Received: from mail-we0-x22e.google.com (mail-we0-x22e.google.com [2a00:1450:400c:c03::22e])
        by mx.google.com with ESMTPS id gm9si9320088wib.8.2014.09.14.07.23.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Sep 2014 07:23:35 -0700 (PDT)
Received: by mail-we0-f174.google.com with SMTP id t60so2877983wes.33
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 07:23:35 -0700 (PDT)
Message-ID: <5415A4DF.90706@redhat.com>
Date: Sun, 14 Sep 2014 16:23:27 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: export symbol dependencies of is_zero_pfn()
References: <1410553043-575-1-git-send-email-ard.biesheuvel@linaro.org>	<20140912141429.17d570d1a7e1cb99ec73f0f7@linux-foundation.org> <CAKv+Gu8=9tVmKtp5s_SyXF7mGjZ7r9x4iBYnyYfNpBogA9ShVg@mail.gmail.com>
In-Reply-To: <CAKv+Gu8=9tVmKtp5s_SyXF7mGjZ7r9x4iBYnyYfNpBogA9ShVg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kvm@vger.kernel.org, Christoffer Dall <christoffer.dall@linaro.org>, linux-mm@kvack.org, linux-s390@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, ralf@linux-mips.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

Il 12/09/2014 23:19, Ard Biesheuvel ha scritto:
> On 12 September 2014 23:14, Andrew Morton <akpm@linux-foundation.org> wrote:
>> On Fri, 12 Sep 2014 22:17:23 +0200 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>>
>>> In order to make the static inline function is_zero_pfn() callable by
>>> modules, export its symbol dependencies 'zero_pfn' and (for s390 and
>>> mips) 'zero_page_mask'.
>>
>> So hexagon and score get the export if/when needed.
>>
> 
> Exactly.
> 
>>> We need this for KVM, as CONFIG_KVM is a tristate for all supported
>>> architectures except ARM and arm64, and testing a pfn whether it refers
>>> to the zero page is required to correctly distinguish the zero page
>>> from other special RAM ranges that may also have the PG_reserved bit
>>> set, but need to be treated as MMIO memory.
>>>
>>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>>> ---
>>>  arch/mips/mm/init.c | 1 +
>>>  arch/s390/mm/init.c | 1 +
>>>  mm/memory.c         | 2 ++
>>
>> Looks OK to me.  Please include the patch in whichever tree is is that
>> needs it, and merge it up via that tree.
>>
> 
> Thanks.
> 
> @Paolo: could you please take this (with Andrew's ack), and put it
> before the patch you took earlier today?

Yes, will do.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
