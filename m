Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id F32346B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 09:55:04 -0400 (EDT)
Date: Mon, 9 Jul 2012 08:55:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: WARNING: __GFP_FS allocations with IRQs disabled
 (kmemcheck_alloc_shadow)
In-Reply-To: <CAAmzW4OD2_ODyeY7c1VMPajwzovOms5M8Vnw=XP=uGUyPogiJQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207090853450.27519@router.home>
References: <20120708040009.GA8363@localhost> <CAAmzW4OD2_ODyeY7c1VMPajwzovOms5M8Vnw=XP=uGUyPogiJQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Vegard Nossum <vegard.nossum@gmail.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 9 Jul 2012, JoonSoo Kim wrote:

> 2012/7/8 Fengguang Wu <fengguang.wu@intel.com>:
> > Hi Vegard,
> >
> > This warning code is triggered for the attached config:
> >
> > __lockdep_trace_alloc():
> >         /*
> >          * Oi! Can't be having __GFP_FS allocations with IRQs disabled.
> >          */
> >         if (DEBUG_LOCKS_WARN_ON(irqs_disabled_flags(flags)))
> >                 return;
> >
> > Where the irq is possibly disabled at the beginning of __slab_alloc():
> >
> >         local_irq_save(flags);
>
> Currently, in slub code, kmemcheck_alloc_shadow is always invoked with
> irq_disabled.
> I think that something like below is needed.

Or you could move the kmem_check_enabled section to occur before the irq
is disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
