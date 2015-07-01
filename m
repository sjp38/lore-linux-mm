Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id E19BD6B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 02:55:59 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so35880752wib.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 23:55:59 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id ld9si1701369wjc.86.2015.06.30.23.55.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 23:55:58 -0700 (PDT)
Received: by wicgi11 with SMTP id gi11so35939372wic.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 23:55:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150701062352.GA3739@lst.de>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
	<20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
	<20150622161002.GB8240@lst.de>
	<CAPcyv4h5OXyRvZvLGD5ZknO-YUPn675YGv0XdtW1QOO9qmZsug@mail.gmail.com>
	<20150701062352.GA3739@lst.de>
Date: Wed, 1 Jul 2015 08:55:57 +0200
Message-ID: <CAMuHMdUO4uSWH1Qc0SfDTLuXbiG2N9fq8Tf6j+3RoqVKdPugbA@mail.gmail.com>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, Linux MM <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jul 1, 2015 at 8:23 AM, Christoph Hellwig <hch@lst.de> wrote:
>> One useful feature of the ifdef mess as implemented in the patch is
>> that you could test for whether ioremap_cache() is actually
>> implemented or falls back to default ioremap().  I think for
>> completeness archs should publish an ioremap type capabilities mask
>> for drivers that care... (I can imagine pmem caring), or default to
>> being permissive if something like IOREMAP_STRICT is not set.  There's
>> also the wrinkle of archs that can only support certain types of
>> mappings at a given alignment.
>
> I think doing this at runtime might be a better idea.  E.g. a
> ioremap_flags with the CACHED argument will return -EOPNOTSUP unless
> actually implemented.  On various architectures different CPUs or
> boards will have different capabilities in this area.

So it would be the responsibility of the caller to fall back from
ioremap(..., CACHED) to ioremap(..., UNCACHED)?
I.e. all drivers using it should be changed...

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
