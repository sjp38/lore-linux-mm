Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3095B6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:20:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r62so7037006pfj.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:20:30 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id j63si4117331pfc.339.2017.08.10.06.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 Aug 2017 06:20:28 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v7 7/9] mm: Add address parameter to arch_validate_prot()
In-Reply-To: <43c120f0cbbebd1398997b9521013ced664e5053.1502219353.git.khalid.aziz@oracle.com>
References: <cover.1502219353.git.khalid.aziz@oracle.com> <43c120f0cbbebd1398997b9521013ced664e5053.1502219353.git.khalid.aziz@oracle.com>
Date: Thu, 10 Aug 2017 23:20:24 +1000
Message-ID: <87tw1flftz.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, davem@davemloft.net, dave.hansen@linux.intel.com
Cc: bsingharora@gmail.com, dja@axtens.net, tglx@linutronix.de, mgorman@suse.de, aarcange@redhat.com, kirill.shutemov@linux.intel.com, heiko.carstens@de.ibm.com, ak@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

Khalid Aziz <khalid.aziz@oracle.com> writes:

> A protection flag may not be valid across entire address space and
> hence arch_validate_prot() might need the address a protection bit is
> being set on to ensure it is a valid protection flag. For example, sparc
> processors support memory corruption detection (as part of ADI feature)
> flag on memory addresses mapped on to physical RAM but not on PFN mapped
> pages or addresses mapped on to devices. This patch adds address to the
> parameters being passed to arch_validate_prot() so protection bits can
> be validated in the relevant context.
>
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> Cc: Khalid Aziz <khalid@gonehiking.org>
> ---
> v7:
> 	- new patch
>
>  arch/powerpc/include/asm/mman.h | 2 +-
>  arch/powerpc/kernel/syscalls.c  | 2 +-
>  include/linux/mman.h            | 2 +-
>  mm/mprotect.c                   | 2 +-
>  4 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
> index 30922f699341..bc74074304a2 100644
> --- a/arch/powerpc/include/asm/mman.h
> +++ b/arch/powerpc/include/asm/mman.h
> @@ -40,7 +40,7 @@ static inline bool arch_validate_prot(unsigned long prot)
>  		return false;
>  	return true;
>  }
> -#define arch_validate_prot(prot) arch_validate_prot(prot)
> +#define arch_validate_prot(prot, addr) arch_validate_prot(prot)

This can be simpler, as just:

#define arch_validate_prot arch_validate_prot

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
