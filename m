Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1EAF6B02FD
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 14:10:32 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 6so12951346oik.11
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 11:10:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c63si743489oih.390.2017.06.22.11.10.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 11:10:32 -0700 (PDT)
Received: from mail-ua0-f178.google.com (mail-ua0-f178.google.com [209.85.217.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 79E9F22B6C
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:10:31 +0000 (UTC)
Received: by mail-ua0-f178.google.com with SMTP id g40so23432334uaa.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 11:10:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <E43BCF62-8688-4238-80F6-FE6F0040FD25@gmail.com>
References: <cover.1498022414.git.luto@kernel.org> <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
 <E43BCF62-8688-4238-80F6-FE6F0040FD25@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 22 Jun 2017 11:10:10 -0700
Message-ID: <CALCETrXcTG2JBnX7kwP2iM=dngk1NRf-3deSgU3BDA5rz1GuSQ@mail.gmail.com>
Subject: Re: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, Jun 22, 2017 at 9:09 AM, Nadav Amit <nadav.amit@gmail.com> wrote:
> Andy Lutomirski <luto@kernel.org> wrote:
>
>>
>> --- a/arch/x86/mm/init.c
>> +++ b/arch/x86/mm/init.c
>> @@ -812,6 +812,7 @@ void __init zone_sizes_init(void)
>>
>> DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
>>       .loaded_mm = &init_mm,
>> +     .next_asid = 1,
>
> I think this is a remainder from previous version of the patches, no? It
> does not seem necessary and may be confusing (ctx_id 0 is reserved, but not
> asid 0).

Hmm.  It's no longer needed for correctness, but init_mm still lands
in slot 0, and it seems friendly to avoid immediately stomping it.
Admittedly, this won't make any practical difference since it'll only
happen once per cpu.

>
> Other than that, if you want, you can put for the entire series:
>
> Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
