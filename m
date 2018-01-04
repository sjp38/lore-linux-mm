Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF5D280244
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 11:34:14 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id p4so1243453wrf.4
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 08:34:14 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [146.0.238.70])
        by mx.google.com with ESMTPS id h193si2377089wme.115.2018.01.04.08.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 04 Jan 2018 08:34:13 -0800 (PST)
Date: Thu, 4 Jan 2018 17:34:09 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
In-Reply-To: <CALCETrVg=XQh+9VczkoC-0oLnBHGD=5hswTmyWQUR8_TTpnDsQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1801041733170.1771@nanos>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com> <20180103084600.GA31648@trogon.sfo.coreos.systems> <20180103092016.GA23772@kroah.com> <20180104003303.GA1654@trogon.sfo.coreos.systems> <DE0BC12C-4BA8-46AF-BD90-6904B9F87187@amacapital.net>
 <CAD3Vwcptxyf+QJO7snZs_-MHGV3ARmLeaFVR49jKM=6MAGMk7Q@mail.gmail.com> <CALCETrW8NxLd4v_U_g8JyW5XdVXWhM_MZOUn05J8VTuWOwkj-A@mail.gmail.com> <alpine.DEB.2.20.1801041320360.1771@nanos> <CALCETrVg=XQh+9VczkoC-0oLnBHGD=5hswTmyWQUR8_TTpnDsQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Benjamin Gilbert <benjamin.gilbert@coreos.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable <stable@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Garnier <thgarnie@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>

On Thu, 4 Jan 2018, Andy Lutomirski wrote:
> On Thu, Jan 4, 2018 at 4:28 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > --- a/arch/x86/include/asm/pgtable_64_types.h
> > +++ b/arch/x86/include/asm/pgtable_64_types.h
> > @@ -88,7 +88,7 @@ typedef struct { pteval_t pte; } pte_t;
> >  # define VMALLOC_SIZE_TB       _AC(32, UL)
> >  # define __VMALLOC_BASE                _AC(0xffffc90000000000, UL)
> >  # define __VMEMMAP_BASE                _AC(0xffffea0000000000, UL)
> > -# define LDT_PGD_ENTRY         _AC(-4, UL)
> > +# define LDT_PGD_ENTRY         _AC(-3, UL)
> >  # define LDT_BASE_ADDR         (LDT_PGD_ENTRY << PGDIR_SHIFT)
> >  #endif
> 
> If you actually change the memory map order, you need to change the
> shadow copy in mm/dump_pagetables.c, too.  I have a draft patch to
> just sort the damn list, but that's not ready yet.

Yes, I forgot that in the first attempt. Noticed myself when dumping it,
but that should be irrelevant to figure out whether it fixes the problem at
hand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
