Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7246B025A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 06:27:44 -0400 (EDT)
Received: by obbgp5 with SMTP id gp5so13288921obb.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 03:27:44 -0700 (PDT)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id j6si3423726obu.78.2015.07.07.03.27.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 03:27:43 -0700 (PDT)
Received: by oiaf66 with SMTP id f66so106352533oia.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 03:27:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150707101330.GJ7557@n2100.arm.linux.org.uk>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
	<20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
	<20150622161002.GB8240@lst.de>
	<CAPcyv4h5OXyRvZvLGD5ZknO-YUPn675YGv0XdtW1QOO9qmZsug@mail.gmail.com>
	<20150701062352.GA3739@lst.de>
	<CAMuHMdUO4uSWH1Qc0SfDTLuXbiG2N9fq8Tf6j+3RoqVKdPugbA@mail.gmail.com>
	<20150701065948.GA4355@lst.de>
	<CAMuHMdXqjmo2T3V=msZySVSu2j4YjyE7FnVXWTjySEyfYLSg1A@mail.gmail.com>
	<20150701072828.GA4881@lst.de>
	<20150707095012.GQ7021@wotan.suse.de>
	<20150707101330.GJ7557@n2100.arm.linux.org.uk>
Date: Tue, 7 Jul 2015 12:27:43 +0200
Message-ID: <CAMuHMdX539+TRrZ+NtQNzJecVgT_Mc=CTZggixtcUg_GsFMjoQ@mail.gmail.com>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "Luis R. Rodriguez" <mcgrof@suse.com>, Christoph Hellwig <hch@lst.de>, Andy Lutomirski <luto@amacapital.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Julia Lawall <julia.lawall@lip6.fr>, Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Linux MM <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Jul 7, 2015 at 12:13 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> Another issue is... the use of memcpy()/memset() directly on memory
> returned from ioremap*().  The pmem driver does this.  This fails sparse
> checks.  However, years ago, x86 invented the memcpy_fromio()/memcpy_toio()
> memset_io() functions, which took a __iomem pointer (which /presumably/
> means they're supposed to operate on the memory associated with an
> ioremap'd region.)
>
> Should these functions always be used for mappings via ioremap*(), and
> the standard memcpy()/memset() be avoided?  To me, that sounds like a
> very good thing, because that gives us more control over the
> implementation of the functions used to access ioremap'd regions,
> and the arch can decide to prevent GCC inlining its own memset() or
> memcpy() code if desired.

Yes they should. Not doing that is a typical portability bug (works on x86,
not everywhere).

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
