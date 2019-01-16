Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 01EEB8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:39:49 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so2353301edb.1
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 04:39:48 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b3si1379338ede.42.2019.01.16.04.39.47
        for <linux-mm@kvack.org>;
        Wed, 16 Jan 2019 04:39:47 -0800 (PST)
Subject: Re: [PATCH V2] mm: Introduce GFP_PGTABLE
References: <1547619692-7946-1-git-send-email-anshuman.khandual@arm.com>
 <bc49c0d1-b46c-f03a-baf9-445c417fae8f@c-s.fr>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <f71d23c6-57ee-1ceb-39a1-395a2f24a870@arm.com>
Date: Wed, 16 Jan 2019 18:09:34 +0530
MIME-Version: 1.0
In-Reply-To: <bc49c0d1-b46c-f03a-baf9-445c417fae8f@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-riscv@lists.infradead.org
Cc: mark.rutland@arm.com, mhocko@suse.com, peterz@infradead.org, catalin.marinas@arm.com, dave.hansen@linux.intel.com, will.deacon@arm.com, aneesh.kumar@linux.ibm.com, linux@armlinux.org.uk, mingo@redhat.com, rientjes@google.com, palmer@sifive.com, greentime@andestech.com, marc.zyngier@arm.com, rppt@linux.vnet.ibm.com, shakeelb@google.com, kirill@shutemov.name, tglx@linutronix.de, vbabka@suse.cz, ard.biesheuvel@linaro.org, steve.capper@arm.com, christoffer.dall@arm.com, james.morse@arm.com, robin.murphy@arm.com



On 01/16/2019 12:40 PM, Christophe Leroy wrote:
> 
> 
> Le 16/01/2019 à 07:21, Anshuman Khandual a écrit :
>> All architectures have been defining their own PGALLOC_GFP as (GFP_KERNEL |
>> __GFP_ZERO) and using it for allocating page table pages. This causes some
>> code duplication which can be easily avoided. GFP_KERNEL allocated and
>> cleared out pages (__GFP_ZERO) are required for page tables on any given
>> architecture. This creates a new generic GFP flag flag which can be used
>> for any page table page allocation. Does not cause any functional change.
>>
>> GFP_PGTABLE is being added into include/asm-generic/pgtable.h which is the
>> generic page tabe header just to prevent it's potential misuse as a general
>> allocation flag if included in include/linux/gfp.h.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>> Build tested on arm, arm64, powerpc, powerpc64le and x86.
>> Boot tested on arm64 and x86.
>>
>> Changes in V2:
>>
>> - Moved GFP_PGTABLE into include/asm-generic/pgtable.h
>> - On X86 added __GFP_ACCOUNT into GFP_PGTABLE at various places
>> - Replaced possible flags on riscv and nds32 with GFP_PGTABLE
> 
> Could also replace the flags in arch/powerpc/include/asm/nohash/64/pgalloc.h with GFP_PGTABLE in pte_alloc_one_kernel() and pte_alloc_one()

Sure will do.
