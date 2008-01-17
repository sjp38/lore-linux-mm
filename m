Received: by rv-out-0910.google.com with SMTP id l15so449686rvb.26
        for <linux-mm@kvack.org>; Thu, 17 Jan 2008 04:14:11 -0800 (PST)
Message-ID: <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com>
Date: Thu, 17 Jan 2008 14:14:11 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <20080115150949.GA14089@aepfle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080115150949.GA14089@aepfle.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olaf Hering <olaf@aepfle.de>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, clameter@sgi.com, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Olaf,

[Adding Christoph as cc.]

On Jan 15, 2008 5:09 PM, Olaf Hering <olaf@aepfle.de> wrote:
> Current linus tree crashes in kmem_cache_init, as shown below. The
> system is a 8cpu 2.2GHz POWER5 system, model 9117-570, with 4GB ram.
> Firmware is 240_332, 2.6.23 boots ok with the same config.
>
> There is a series of mm related patches in 2.6.24-rc1:
> commit 04231b3002ac53f8a64a7bd142fde3fa4b6808c6 seems to break it,

So that's the "Memoryless nodes: Slab support" patch that I think
cause a similar oops while ago.

> Unable to handle kernel paging request for data at address 0x00000040
> Faulting instruction address: 0xc000000000437470
> cpu 0x0: Vector: 300 (Data Access) at [c00000000075b830]
>     pc: c000000000437470: ._spin_lock+0x20/0x88
>     lr: c0000000000f78a8: .cache_grow+0x7c/0x338
>     sp: c00000000075bab0
>    msr: 8000000000009032
>    dar: 40
>  dsisr: 40000000
>   current = 0xc000000000665a50
>   paca    = 0xc000000000666380
>     pid   = 0, comm = swapper
> enter ? for help
> [c00000000075bb30] c0000000000f78a8 .cache_grow+0x7c/0x338
> [c00000000075bbf0] c0000000000f7d04 .fallback_alloc+0x1a0/0x1f4
> [c00000000075bca0] c0000000000f8544 .kmem_cache_alloc+0xec/0x150
> [c00000000075bd40] c0000000000fb1c0 .kmem_cache_create+0x208/0x478
> [c00000000075be20] c0000000005e670c .kmem_cache_init+0x218/0x4f4
> [c00000000075bee0] c0000000005bf8ec .start_kernel+0x2f8/0x3fc
> [c00000000075bf90] c000000000008590 .start_here_common+0x60/0xd0

Looks similar to the one discussed on linux-mm ("[BUG] at
mm/slab.c:3320" thread). Christoph?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
