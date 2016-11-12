Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A1A5E28028E
	for <linux-mm@kvack.org>; Sat, 12 Nov 2016 14:29:43 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id w63so53503125oiw.4
        for <linux-mm@kvack.org>; Sat, 12 Nov 2016 11:29:43 -0800 (PST)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id f10si2676645otd.327.2016.11.12.11.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Nov 2016 11:29:42 -0800 (PST)
Received: by mail-oi0-x244.google.com with SMTP id x4so1881804oix.0
        for <linux-mm@kvack.org>; Sat, 12 Nov 2016 11:29:42 -0800 (PST)
Subject: Re: [PATCH RFC] mm: Add debug_virt_to_phys()
References: <20161112004449.30566-1-f.fainelli@gmail.com>
 <20161112054318.GB24127@arm.com>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <abb97b87-db44-e25a-608e-161b57a0439b@gmail.com>
Date: Sat, 12 Nov 2016 11:29:38 -0800
MIME-Version: 1.0
In-Reply-To: <20161112054318.GB24127@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Nicolas Pitre <nicolas.pitre@linaro.org>, Chris Brandt <chris.brandt@renesas.com>, Pratyush Anand <panand@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>, Neeraj Upadhyay <neeraju@codeaurora.org>, Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jerome Marchand <jmarchan@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:GENERIC INCLUDE/ASM HEADER FILES" <linux-arch@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Le 11/11/2016 A  21:43, Will Deacon a A(C)crit :
> On Fri, Nov 11, 2016 at 04:44:43PM -0800, Florian Fainelli wrote:
>> When CONFIG_DEBUG_VM is turned on, virt_to_phys() maps to
>> debug_virt_to_phys() which helps catch vmalloc space addresses being
>> passed. This is helpful in debugging bogus drivers that just assume
>> linear mappings all over the place.
>>
>> For ARM, ARM64, Unicore32 and Microblaze, the architectures define
>> __virt_to_phys() as being the functional implementation of the address
>> translation, so we special case the debug stub to call into
>> __virt_to_phys directly.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  arch/arm/include/asm/memory.h      |  4 ++++
>>  arch/arm64/include/asm/memory.h    |  4 ++++
>>  include/asm-generic/memory_model.h |  4 ++++
>>  mm/debug.c                         | 15 +++++++++++++++
>>  4 files changed, 27 insertions(+)
> 
> What's the interaction between this and the DEBUG_VIRTUAL patches from Laura?
> 
> http://lkml.kernel.org/r/20161102210054.16621-7-labbott@redhat.com
> 
> They seem to be tackling the exact same problem afaict.

Indeed thanks for pointing that out, I guess I could piggy back on this
patchset and try to cover ARM.

Thanks!
-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
