Date: Wed, 6 Jun 2007 16:50:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
In-Reply-To: <20070606161909.ea6a2556.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706061646230.18160@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
 <20070606100817.7af24b74.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706061053290.11553@schroedinger.engr.sgi.com>
 <20070606131121.a8f7be78.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706061326020.12565@schroedinger.engr.sgi.com>
 <20070606133432.2f3cb26a.akpm@linux-foundation.org> <46671C16.9080409@mbligh.org>
 <Pine.LNX.4.64.0706061349451.12665@schroedinger.engr.sgi.com>
 <20070606161909.ea6a2556.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jun 2007, Andrew Morton wrote:

> Did you try starting from the test.kernel.org config? 
> http://test.kernel.org/abat/93412/build/dotconfig

Ok used that one but same result.

There must be something trivial that I do not do right. The compile does 
not get that this is a 64 bit compile. Maybe I cannot do a 64 bit compile 
on a 32 bit system (this is i386)?

clameter@schroedinger:~/software/slub$ cat /usr/local/bin/make_powerpc
make ARCH=powerpc CROSS_COMPILE=powerpc-linux-gnu- $*

clameter@schroedinger:~/software/slub$ make_powerpc all
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CC      arch/powerpc/kernel/asm-offsets.s
In file included from include/asm/mmu.h:7,
                 from include/asm/lppaca.h:32,
                 from include/asm/paca.h:20,
                 from include/asm/hw_irq.h:17,
                 from include/asm/system.h:9,
                 from include/linux/list.h:9,
                 from include/linux/signal.h:8,
                 from arch/powerpc/kernel/asm-offsets.c:16:
include/asm/mmu-hash64.h: In function `hpte_encode_r':
include/asm/mmu-hash64.h:216: warning: integer constant is too large for 
"unsigned long" type
include/asm/mmu-hash64.h: In function `hpt_hash':
include/asm/mmu-hash64.h:231: warning: integer constant is too large for 
"unsign

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
