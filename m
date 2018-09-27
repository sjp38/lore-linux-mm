Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6BDB8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 20:34:45 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id w132-v6so5791163ita.6
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 17:34:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f65-v6sor276306jai.29.2018.09.26.17.34.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Sep 2018 17:34:44 -0700 (PDT)
MIME-Version: 1.0
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536927045-23536-4-git-send-email-rppt@linux.vnet.ibm.com>
 <CAKgT0UdP=78RsWHMxFu4PD8a3AhA3eNcG68Z_9aGY0vhOKf7xA@mail.gmail.com> <20180926183152.GA4597@rapoport-lnx>
In-Reply-To: <20180926183152.GA4597@rapoport-lnx>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 26 Sep 2018 17:34:32 -0700
Message-ID: <CAKgT0UcC-GTtyPK9ynvj6r3YFqy8kE40iMJxzPowbNoXGf9iWg@mail.gmail.com>
Subject: Re: [PATCH 03/30] mm: remove CONFIG_HAVE_MEMBLOCK
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, chris@zankel.net, David Miller <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, green.hu@gmail.com, Greg KH <gregkh@linuxfoundation.org>, gxt@pku.edu.cn, Ingo Molnar <mingo@redhat.com>, jejb@parisc-linux.org, jonas@southpole.se, Jonathan Corbet <corbet@lwn.net>, lftan@altera.com, msalter@redhat.com, Martin Schwidefsky <schwidefsky@de.ibm.com>, mattst88@gmail.com, mpe@ellerman.id.au, Michal Hocko <mhocko@suse.com>, monstr@monstr.eu, palmer@sifive.com, paul.burton@mips.com, rkuo@codeaurora.org, richard@nod.at, dalias@libc.org, Russell King - ARM Linux <linux@armlinux.org.uk>, fancer.lancer@gmail.com, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, vgupta@synopsys.com, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp

On Wed, Sep 26, 2018 at 11:32 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
>
> On Wed, Sep 26, 2018 at 09:58:41AM -0700, Alexander Duyck wrote:
> > On Fri, Sep 14, 2018 at 5:11 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > >
> > > All architecures use memblock for early memory management. There is no need
> > > for the CONFIG_HAVE_MEMBLOCK configuration option.
> > >
> > > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> >
> > <snip>
> >
> > > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > > index 5169205..4ae91fc 100644
> > > --- a/include/linux/memblock.h
> > > +++ b/include/linux/memblock.h
> > > @@ -2,7 +2,6 @@
> > >  #define _LINUX_MEMBLOCK_H
> > >  #ifdef __KERNEL__
> > >
> > > -#ifdef CONFIG_HAVE_MEMBLOCK
> > >  /*
> > >   * Logical memory blocks.
> > >   *
> > > @@ -460,7 +459,6 @@ static inline phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align)
> > >  {
> > >         return 0;
> > >  }
> > > -#endif /* CONFIG_HAVE_MEMBLOCK */
> > >
> > >  #endif /* __KERNEL__ */
> >
> > There was an #else above this section and I believe it and the code
> > after it needs to be stripped as well.
>
> Right, I've already sent the fix [1] and it's in mmots.
>
> [1] https://lkml.org/lkml/2018/9/19/416
>

Are you sure? The patch you reference appears to be for
drivers/of/fdt.c, and the bit I pointed out here is in
include/linux/memblock.h.

- Alex
