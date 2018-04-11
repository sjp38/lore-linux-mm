Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9156B0008
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:34:23 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f9-v6so781346plo.17
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 01:34:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j91-v6si677867pld.14.2018.04.11.01.34.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 01:34:22 -0700 (PDT)
Date: Wed, 11 Apr 2018 10:34:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm: introduce ARCH_HAS_PTE_SPECIAL
Message-ID: <20180411083419.GB23400@dhcp22.suse.cz>
References: <1523433816-14460-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523433816-14460-2-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523433816-14460-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>

On Wed 11-04-18 10:03:35, Laurent Dufour wrote:
> Currently the PTE special supports is turned on in per architecture header
> files. Most of the time, it is defined in arch/*/include/asm/pgtable.h
> depending or not on some other per architecture static definition.
> 
> This patch introduce a new configuration variable to manage this directly
> in the Kconfig files. It would later replace __HAVE_ARCH_PTE_SPECIAL.
> 
> Here notes for some architecture where the definition of
> __HAVE_ARCH_PTE_SPECIAL is not obvious:
> 
> arm
>  __HAVE_ARCH_PTE_SPECIAL which is currently defined in
> arch/arm/include/asm/pgtable-3level.h which is included by
> arch/arm/include/asm/pgtable.h when CONFIG_ARM_LPAE is set.
> So select ARCH_HAS_PTE_SPECIAL if ARM_LPAE.
> 
> powerpc
> __HAVE_ARCH_PTE_SPECIAL is defined in 2 files:
>  - arch/powerpc/include/asm/book3s/64/pgtable.h
>  - arch/powerpc/include/asm/pte-common.h
> The first one is included if (PPC_BOOK3S & PPC64) while the second is
> included in all the other cases.
> So select ARCH_HAS_PTE_SPECIAL all the time.
> 
> sparc:
> __HAVE_ARCH_PTE_SPECIAL is defined if defined(__sparc__) &&
> defined(__arch64__) which are defined through the compiler in
> sparc/Makefile if !SPARC32 which I assume to be if SPARC64.
> So select ARCH_HAS_PTE_SPECIAL if SPARC64
> 
> There is no functional change introduced by this patch.
> 
> Suggested-by: Jerome Glisse <jglisse@redhat>
> Reviewed-by: Jerome Glisse <jglisse@redhat>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Looks good to me. I have checked x86 and the generic code and it looks
good to me. Anyway arch maintainers really have to double check this.
-- 
Michal Hocko
SUSE Labs
