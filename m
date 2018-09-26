Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 268FA8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 12:58:54 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id w132-v6so3990570ita.6
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 09:58:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i15-v6sor3765292iti.76.2018.09.26.09.58.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Sep 2018 09:58:53 -0700 (PDT)
MIME-Version: 1.0
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com> <1536927045-23536-4-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536927045-23536-4-git-send-email-rppt@linux.vnet.ibm.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 26 Sep 2018 09:58:41 -0700
Message-ID: <CAKgT0UdP=78RsWHMxFu4PD8a3AhA3eNcG68Z_9aGY0vhOKf7xA@mail.gmail.com>
Subject: Re: [PATCH 03/30] mm: remove CONFIG_HAVE_MEMBLOCK
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, chris@zankel.net, David Miller <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, green.hu@gmail.com, Greg KH <gregkh@linuxfoundation.org>, gxt@pku.edu.cn, Ingo Molnar <mingo@redhat.com>, jejb@parisc-linux.org, jonas@southpole.se, Jonathan Corbet <corbet@lwn.net>, lftan@altera.com, msalter@redhat.com, Martin Schwidefsky <schwidefsky@de.ibm.com>, mattst88@gmail.com, mpe@ellerman.id.au, Michal Hocko <mhocko@suse.com>, monstr@monstr.eu, palmer@sifive.com, paul.burton@mips.com, rkuo@codeaurora.org, richard@nod.at, dalias@libc.org, Russell King - ARM Linux <linux@armlinux.org.uk>, fancer.lancer@gmail.com, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, vgupta@synopsys.com, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp

On Fri, Sep 14, 2018 at 5:11 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
>
> All architecures use memblock for early memory management. There is no need
> for the CONFIG_HAVE_MEMBLOCK configuration option.
>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

<snip>

> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 5169205..4ae91fc 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -2,7 +2,6 @@
>  #define _LINUX_MEMBLOCK_H
>  #ifdef __KERNEL__
>
> -#ifdef CONFIG_HAVE_MEMBLOCK
>  /*
>   * Logical memory blocks.
>   *
> @@ -460,7 +459,6 @@ static inline phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align)
>  {
>         return 0;
>  }
> -#endif /* CONFIG_HAVE_MEMBLOCK */
>
>  #endif /* __KERNEL__ */

There was an #else above this section and I believe it and the code
after it needs to be stripped as well.
