Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 42FA36B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 20:01:09 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id fl12so22169387pdb.6
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 17:01:09 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id g1si3503046pde.233.2015.01.27.17.01.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jan 2015 17:01:08 -0800 (PST)
Message-ID: <1422406862.32234.1.camel@ellerman.id.au>
Subject: Re: [PATCH v3] powerpc/mm: fix undefined reference to
 `.__kernel_map_pages' on FSL PPC64
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 28 Jan 2015 12:01:02 +1100
In-Reply-To: <20150126132222.6477257be204a3332601ef11@freescale.com>
References: <20150120140200.aa7ba0eb28d95e456972e178@freescale.com>
	 <20150120230150.GA14475@cloud>
	 <20150120160738.edfe64806cc8b943beb1dfa0@linux-foundation.org>
	 <CAC5umyieZn7ppXkKb45O=C=BF+iv6R_A1Dwfhro=cBJzFeovrA@mail.gmail.com>
	 <20150122014550.GA21444@js1304-P5Q-DELUXE>
	 <20150122144147.019eedc41f189eac44c3c4cd@freescale.com>
	 <CAC5umyiF52cykH2_5TD0yzXb+842gywpe-+XZHEwmrDe0nYCPw@mail.gmail.com>
	 <20150122212017.4b7032d52a6c75c06d5b4728@freescale.com>
	 <1421987091.24984.13.camel@ellerman.id.au>
	 <20150126132222.6477257be204a3332601ef11@freescale.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kim Phillips <kim.phillips@freescale.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, josh@joshtriplett.org, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@fb.com>, Minchan Kim <minchan@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Scott Wood <scottwood@freescale.com>

On Mon, 2015-01-26 at 13:22 -0600, Kim Phillips wrote:
> arch/powerpc has __kernel_map_pages implementations in mm/pgtable_32.c, and
> mm/hash_utils_64.c, of which the former is built for PPC32, and the latter
> for PPC64 machines with PPC_STD_MMU.  Fix arch/powerpc/Kconfig to not select
> ARCH_SUPPORTS_DEBUG_PAGEALLOC when CONFIG_PPC_STD_MMU_64 isn't defined,
> i.e., for 64-bit book3e builds to use the generic __kernel_map_pages()
> in mm/debug-pagealloc.c.
> 
>   LD      init/built-in.o
> mm/built-in.o: In function `kernel_map_pages':
> include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> Makefile:925: recipe for target 'vmlinux' failed
> make: *** [vmlinux] Error 1
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
> v3:
> - fix wording for hash_utils_64.c implementation pointed out by
> Michael Ellerman
> - changed designation from 'mm:' to 'powerpc/mm:', as I think this
> now belongs in ppc-land
> 
> v2:
> - corrected SUPPORTS_DEBUG_PAGEALLOC selection to enable
> non-STD_MMU_64 builds to use the generic __kernel_map_pages().

I'd be happy to take this through the powerpc tree for 3.20, but for this:

> depends on:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Thu, 22 Jan 2015 10:28:58 +0900
> Subject: [PATCH] mm/debug_pagealloc: fix build failure on ppc and some other archs

I don't have that patch in my tree.

But in what way does this patch depend on that one?

It looks to me like it'd be safe to take this on its own, or am I wrong?

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
