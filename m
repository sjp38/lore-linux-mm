Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 8E5966B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 19:35:46 -0400 (EDT)
Date: Thu, 11 Oct 2012 16:35:41 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v3
Message-ID: <20121011233541.GN2095@tassilo.jf.intel.com>
References: <1349303063-12766-1-git-send-email-andi@firstfloor.org>
 <1349303063-12766-2-git-send-email-andi@firstfloor.org>
 <20121009151907.3f61ebca.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121009151907.3f61ebca.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>

> Alas, include/asm-generic/mman.h doesn't exist now.

git resolved it automagically

> 
> Does this change touch all the hugetlb-capable architectures?

I took a look at this again. So not every hugetlb capable architecture
needs it, only architectures with multiple hugetlb page sizes.

This is only x86, tile, powerpc

I looked at tile and powerpc and they both have configurable
hugetlb page sizes. So it's somewhat awkward to add defines
for them.

One disadvantage of this is also the user programs would need
to know the page sizes that are configured. That is definitely
awkward, but I don't know of any way around that.

Luckily there's a way in /sys to query this.

-Andi

> 
> z:/usr/src/linux-3.6> grep -rl MAP_HUGETLB arch
> arch/alpha/include/asm/mman.h
> arch/xtensa/include/asm/mman.h
> arch/parisc/include/asm/mman.h
> arch/tile/include/asm/mman.h
> arch/sparc/include/asm/mman.h
> arch/powerpc/include/asm/mman.h
> arch/mips/include/asm/mman.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
