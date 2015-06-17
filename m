Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id E9FE56B0072
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 11:16:36 -0400 (EDT)
Received: by wgv5 with SMTP id 5so39854036wgv.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 08:16:36 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id m6si9677796wif.81.2015.06.17.08.16.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 08:16:35 -0700 (PDT)
Date: Wed, 17 Jun 2015 17:15:57 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 6/6] arch, x86: pmem api for ensuring durability of
 persistent memory updates
In-Reply-To: <CALCETrXXYyjKHi1ajR6aescmjSo5eds=5g_byWpzBRbBNdsgRQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1506171714490.4107@nanos>
References: <20150611211354.10271.57950.stgit@dwillia2-desk3.amr.corp.intel.com> <20150611211947.10271.80768.stgit@dwillia2-desk3.amr.corp.intel.com> <CALCETrXXYyjKHi1ajR6aescmjSo5eds=5g_byWpzBRbBNdsgRQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, Toshi Kani <toshi.kani@hp.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Christoph Hellwig <hch@lst.de>

On Wed, 17 Jun 2015, Andy Lutomirski wrote:
> On Thu, Jun 11, 2015 at 2:19 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> > +static inline void arch_sync_pmem(void)
> > +{
> > +       wmb();
> > +       pcommit_sfence();
> > +}
> 
> This function is non-intuitive to me.  It's really "arch-specific sync
> pmem after one or more copies using arch_memcpy_to_pmem".  If normal
> stores or memcpy to non-WC memory is used instead, then it's
> insufficient if the memory is WB and it's unnecessarily slow if the
> memory is WT or UC (the first sfence isn't needed).
> 
> I would change the name and add documentation.  I'd also add a comment
> about the wmb() being an SFENCE to flush pending non-temporal writes.

Not "I'd also add ...".

Documentation of memory barriers are mandatory.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
