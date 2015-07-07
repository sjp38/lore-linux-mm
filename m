Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE5C6B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 00:14:54 -0400 (EDT)
Received: by oiyy130 with SMTP id y130so133083502oiy.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 21:14:53 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id y66si15271221oig.105.2015.07.06.21.14.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 21:14:53 -0700 (PDT)
Received: by oiab3 with SMTP id b3so14785113oia.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 21:14:53 -0700 (PDT)
MIME-Version: 1.0
From: Sumit Gupta <sumit.g.007@gmail.com>
Date: Tue, 7 Jul 2015 09:44:13 +0530
Message-ID: <CANDtUrdRXh9MUJTzWuUu=ZpGk+zbh0Mp06N58-+kefWKVOeo8g@mail.gmail.com>
Subject: MM: Query about different memory types(mem_types)__mmu.c
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi All,

I have been exploring ARM reference manual about ARM weak memory model
and mmu page table setting from some time.
I think i understand different memory types, mmu settings for
page/section, TEX, AP, B, C, S bits well.
My target is to to dig further and fully understand setting of all
parameters for different memory types in ARM
[File mmu.c: "static struct mem_type mem_types"].

But i am not able to find any good source to refer for fully
understanding all below parameters.
Could you please help me to understand mappings for below mem types.
If you can point me to some references which can help me understand
more.

Thank you in advance for your help.


        [MT_DEVICE] = {           /* Strongly ordered / ARMv6 shared device */
                .prot_pte       = PROT_PTE_DEVICE | L_PTE_MT_DEV_SHARED |
                                  L_PTE_SHARED,
                .prot_pte_s2    = s2_policy(PROT_PTE_S2_DEVICE) |
                                  s2_policy(L_PTE_S2_MT_DEV_SHARED) |
                                  L_PTE_SHARED,
                .prot_l1        = PMD_TYPE_TABLE,
                .prot_sect      = PROT_SECT_DEVICE | PMD_SECT_S,
                .domain         = DOMAIN_IO,
        },
............
       [MT_MEMORY_RW] = {
                .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                             L_PTE_XN,
                .prot_l1   = PMD_TYPE_TABLE,
                .prot_sect = PMD_TYPE_SECT | PMD_SECT_AP_WRITE,
                .domain    = DOMAIN_KERNEL,
        },
............
        [MT_MEMORY_DMA_READY] = {
                .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                                L_PTE_XN,
                .prot_l1   = PMD_TYPE_TABLE,
                .domain    = DOMAIN_KERNEL,
        },

Regards,
Sumit Gupta

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
