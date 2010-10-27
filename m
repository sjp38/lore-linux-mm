Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9B7D46B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 06:28:05 -0400 (EDT)
Message-Id: <849307$a582r7@azsmga001.ch.intel.com>
Date: Wed, 27 Oct 2010 11:27:57 +0100
Subject: Re: [PATCH 0/5] mm, highmem: kmap_atomic rework -v3
References: <20100918155326.478277313@chello.nl>
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20100918155326.478277313@chello.nl>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 18 Sep 2010 17:53:26 +0200, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> Next version of the kmap_atomic rework using Andrew's fancy CPP trickery to
> avoid having to convert the whole tree at once.
> 
> This is compile tested for i386-allmodconfig, frv, mips-sb1250-swarm,
> powerpc-ppc6xx_defconfig, sparc32_defconfig, arm-omap3 (all with
> HIGHEM=y).

This break on x86, HIGHMEM=n:

arch/x86/mm/iomap_32.c: In function a??kmap_atomic_prot_pfna??:
arch/x86/mm/iomap_32.c:64: error: implicit declaration of function
a??kmap_atomic_idx_pusha??
arch/x86/mm/iomap_32.c: In function a??iounmap_atomica??:
arch/x86/mm/iomap_32.c:101: error: implicit declaration of function
a??kmap_atomic_idx_popa??

The use of the kmap idx there looks a little delicate so I'm not sure how
to fix this.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
