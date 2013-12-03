Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id AA1A26B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 16:18:25 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id m15so14145320wgh.25
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 13:18:24 -0800 (PST)
Received: from smtp1.it.da.ut.ee (mailhost6-1.ut.ee. [2001:bb8:2002:500::46])
        by mx.google.com with ESMTP id bb9si31640600wjb.139.2013.12.03.13.18.24
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 13:18:24 -0800 (PST)
Date: Tue, 3 Dec 2013 23:18:23 +0200 (EET)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: Slab BUG with DEBUG_* options
In-Reply-To: <00000142ba22e43b-99d8d7cb-9ecd-4f18-9609-8805270843d4-000000@email.amazonses.com>
Message-ID: <alpine.SOC.1.00.1312032314040.25191@math.ut.ee>
References: <alpine.SOC.1.00.1311300125490.6363@math.ut.ee> <alpine.DEB.2.02.1312030930450.4115@gentwo.org> <00000142ba22e43b-99d8d7cb-9ecd-4f18-9609-8805270843d4-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

> I have another patch here (that I cannot test since I cannot run sparc
> code) that simply changes the determination for switching slab management
> to base the decision not on the final size of the slab (which is always
> large in the debugging cases here) but on the initial object size. For
> small objects < PAGESIZE/8 this should avoid the use of slab management
> even in the debugging case.
> 
> Subject: slab: Do not use slab management for slabs with smaller objects
> 
> Use the object size to make the off slab decision instead of the final
> size of the slab objects (which is large in case of
> CONFIG_PAGEALLOC_DEBUG).

Tested it. seems to hang after switching to another console. Before 
that, slabs are initialized successfully, I verified it with my previous 
debug printk sprinkle patch. Many allocations are still off slab - is 
that OK?

Memory: 493968K/523456K available (3521K kernel code, 343K rwdata, 1176K rodata, 264K init, 9803K bss, 29488K reserved)
__kmem_cache_create: starting, size=248, flags=8192
__kmem_cache_create: now flags=76800
__kmem_cache_create: aligned size to 248 because of redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: starting, size=96, flags=8192
__kmem_cache_create: now flags=76800
__kmem_cache_create: aligned size to 96 because of redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: starting, size=192, flags=8192
__kmem_cache_create: now flags=76800
__kmem_cache_create: aligned size to 192 because of redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: starting, size=32, flags=8192
__kmem_cache_create: now flags=76800
__kmem_cache_create: aligned size to 32 because of redzoning
__kmem_cache_create: aligned size to 32
__kmem_cache_create: num=226, slab_size=960
__kmem_cache_create: starting, size=64, flags=8192
__kmem_cache_create: now flags=76800
__kmem_cache_create: aligned size to 64 because of redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: starting, size=128, flags=8192
__kmem_cache_create: now flags=76800
__kmem_cache_create: aligned size to 128 because of redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: starting, size=256, flags=8192
__kmem_cache_create: now flags=76800
__kmem_cache_create: aligned size to 256 because of redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: starting, size=512, flags=8192
__kmem_cache_create: now flags=76800
__kmem_cache_create: aligned size to 512 because of redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: starting, size=1024, flags=8192
__kmem_cache_create: now flags=76800
__kmem_cache_create: aligned size to 1024 because of redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=8192, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=2048, flags=8192
__kmem_cache_create: now flags=76800
__kmem_cache_create: aligned size to 2048 because of redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=8192, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=4096, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=8192, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=8192, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=8192, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=16384, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=16384
__kmem_cache_create: aligned size to 16384
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=16384, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=32768, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=32768
__kmem_cache_create: aligned size to 32768
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=32768, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=65536, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=65536
__kmem_cache_create: aligned size to 65536
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=65536, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=131072, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=131072
__kmem_cache_create: aligned size to 131072
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=131072, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=262144, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=262144
__kmem_cache_create: aligned size to 262144
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=262144, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=524288, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=524288
__kmem_cache_create: aligned size to 524288
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=524288, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=1048576, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=1048576
__kmem_cache_create: aligned size to 1048576
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=1048576, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=2097152, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=2097152
__kmem_cache_create: aligned size to 2097152
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=2097152, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=4194304, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=4194304
__kmem_cache_create: aligned size to 4194304
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=4194304, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=8388608, flags=8192
__kmem_cache_create: now flags=10240
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=8388608
__kmem_cache_create: aligned size to 8388608
__kmem_cache_create: num=1, slab_size=64
__kmem_cache_create: CFLGS_OFF_SLAB, size=8388608, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=8192, flags=0
__kmem_cache_create: now flags=2048
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=8192
__kmem_cache_create: CFLGS_OFF_SLAB, size=8192, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=8192, flags=0
__kmem_cache_create: now flags=2048
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=8192
__kmem_cache_create: CFLGS_OFF_SLAB, size=8192, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=16384, flags=0
__kmem_cache_create: now flags=2048
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=16384
__kmem_cache_create: aligned size to 16384
__kmem_cache_create: num=1, slab_size=16384
__kmem_cache_create: CFLGS_OFF_SLAB, size=16384, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=32768, flags=0
__kmem_cache_create: now flags=2048
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=32768
__kmem_cache_create: aligned size to 32768
__kmem_cache_create: num=1, slab_size=32768
__kmem_cache_create: CFLGS_OFF_SLAB, size=32768, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=65536, flags=0
__kmem_cache_create: now flags=2048
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=65536
__kmem_cache_create: aligned size to 65536
__kmem_cache_create: num=1, slab_size=65536
__kmem_cache_create: CFLGS_OFF_SLAB, size=65536, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=131072, flags=0
__kmem_cache_create: now flags=2048
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=131072
__kmem_cache_create: aligned size to 131072
__kmem_cache_create: num=1, slab_size=131072
__kmem_cache_create: CFLGS_OFF_SLAB, size=131072, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=262144, flags=0
__kmem_cache_create: now flags=2048
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=262144
__kmem_cache_create: aligned size to 262144
__kmem_cache_create: num=1, slab_size=262144
__kmem_cache_create: CFLGS_OFF_SLAB, size=262144, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=524288, flags=0
__kmem_cache_create: now flags=2048
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=524288
__kmem_cache_create: aligned size to 524288
__kmem_cache_create: num=1, slab_size=524288
__kmem_cache_create: CFLGS_OFF_SLAB, size=524288, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=1048576, flags=0
__kmem_cache_create: now flags=2048
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=1048576
__kmem_cache_create: aligned size to 1048576
__kmem_cache_create: num=1, slab_size=1048576
__kmem_cache_create: CFLGS_OFF_SLAB, size=1048576, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=2112, flags=262144
__kmem_cache_create: now flags=330752
__kmem_cache_create: aligned size to 2112 because of redzoning
__kmem_cache_create: aligned size to 2128 because of redzoning, take 2
__kmem_cache_create: increased size to 2136 because user store and redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: turning on CFLGS_OFF_SLAB, size=8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=56
__kmem_cache_create: CFLGS_OFF_SLAB, size=8192, slab_size=52
__kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
__kmem_cache_create: starting, size=560, flags=393216
__kmem_cache_create: now flags=461824
__kmem_cache_create: aligned size to 560 because of redzoning
__kmem_cache_create: aligned size to 576 because of redzoning, take 2
__kmem_cache_create: increased size to 584 because user store and redzoning
__kmem_cache_create: pagealloc debug, setting size to 8192
__kmem_cache_create: aligned size to 8192
__kmem_cache_create: num=1, slab_size=56
NR_IRQS:255
kmemleak: Kernel memory leak detector disabled
clocksource: mult[2c71c72] shift[24]
clockevent: mult[5c28f5c3] shift[32]
Console: colour dummy device 80x25
console [tty0] enabled, bootconsole disabled

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
