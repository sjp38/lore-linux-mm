Received: by wx-out-0506.google.com with SMTP id h31so94074wxd
        for <linux-mm@kvack.org>; Thu, 04 Oct 2007 00:10:11 -0700 (PDT)
Message-ID: <84144f020710040010r4804c69x746bf78db17e9fa1@mail.gmail.com>
Date: Thu, 4 Oct 2007 10:10:10 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [Bug] 2.6.23-rc9 - kernel BUG at mm/slab.c:592!
In-Reply-To: <47048DD8.2090405@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <47048DD8.2090405@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, samba-technical@lists.samba.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Kamalesh,

On 10/4/07, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> Kernel bug hit, while running fsstress over the CIFS mounted partition on
> the ppc64 machine
>
> cpu 0x0: Vector: 700 (Program Check) at [c000000106ec75f0]
>
>     pc: c0000000000d69cc: .kmem_cache_free+0xac/0x154
>
>     lr: c0000000000b05f0: .mempool_free_slab+0x1c/0x30
>
>     sp: c000000106ec7870
>
>    msr: 8000000000029032
>
>   current = 0xc000000007cf64c0
>
>   paca    = 0xc0000000007ecf00
>
>     pid   = 8210, comm = fsstress
>
> kernel BUG at mm/slab.c:592!

Looks like someone passed a non-slab pointer to
mempool_free()/kmem_cache_free() so it's likely that the problem is in
cifs, not mm.

                                             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
