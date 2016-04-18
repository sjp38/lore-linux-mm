Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C50DE6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 12:07:50 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g185so416160634ioa.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 09:07:50 -0700 (PDT)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id vv1si24976306igb.11.2016.04.18.09.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 09:07:48 -0700 (PDT)
Received: by mail-io0-x231.google.com with SMTP id u185so199254898iod.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 09:07:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460995497-24312-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1460995497-24312-1-git-send-email-ard.biesheuvel@linaro.org>
Date: Mon, 18 Apr 2016 18:07:48 +0200
Message-ID: <CAKv+Gu95yDmAYATWRBY27PRHxX9L4YJxgxKf0UCZ-QbkEQfaNQ@mail.gmail.com>
Subject: Re: [PATCH resend 0/3] mm: allow arch to override lowmem_page_address
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, lftan@altera.com, Jonas Bonn <jonas@southpole.se>
Cc: Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On 18 April 2016 at 18:04, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> These patches allow the arch to define the page_to_virt() conversion that
> is used in lowmem_page_address(). This is desirable for arm64, where this
> conversion is trivial when CONFIG_SPARSEMEM_VMEMMAP is enabled, while
> breaking it up into __va(PFN_PHYS(page_to_pfn(page))), as is done currently
> in lowmem_page_address(), will force the use of a virt-to-phys() conversion
> and back again, which always involves a memory access on arm64, since the
> start of physical memory is not a compile time constant.
>
> I have split off these patches from my series 'arm64: optimize virt_to_page
> and page_address' which I sent out 3 weeks ago, and resending them in the
> hope that they can be picked up (with Will's ack on #3) to be merged via
> the mm tree.
>
> I have cc'ed the nios2 and openrisc maintainers on previous versions, and
> cc'ing them again now. I have dropped both of the arch specific mailing
> lists, since one is defunct and the other is subscriber only.
>
> Andrew, is this something you would be pulling to pick up (assuming that you

s/pulling/willing/

> agree with the contents)? Thanks.
>
> Ard Biesheuvel (3):
>   nios2: use correct void* return type for page_to_virt()
>   openrisc: drop wrongly typed definition of page_to_virt()
>   mm: replace open coded page to virt conversion with page_to_virt()
>
>  arch/nios2/include/asm/io.h      | 1 -
>  arch/nios2/include/asm/page.h    | 2 +-
>  arch/nios2/include/asm/pgtable.h | 2 +-
>  arch/openrisc/include/asm/page.h | 2 --
>  include/linux/mm.h               | 6 +++++-
>  5 files changed, 7 insertions(+), 6 deletions(-)
>
> --
> 2.5.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
