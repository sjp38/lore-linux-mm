Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id B15826B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 03:19:31 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so49227887wid.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 00:19:31 -0700 (PDT)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id k8si2455475wia.75.2015.07.01.00.19.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 00:19:30 -0700 (PDT)
Received: by wgck11 with SMTP id k11so28547577wgc.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 00:19:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150701065948.GA4355@lst.de>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
	<20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
	<20150622161002.GB8240@lst.de>
	<CAPcyv4h5OXyRvZvLGD5ZknO-YUPn675YGv0XdtW1QOO9qmZsug@mail.gmail.com>
	<20150701062352.GA3739@lst.de>
	<CAMuHMdUO4uSWH1Qc0SfDTLuXbiG2N9fq8Tf6j+3RoqVKdPugbA@mail.gmail.com>
	<20150701065948.GA4355@lst.de>
Date: Wed, 1 Jul 2015 09:19:29 +0200
Message-ID: <CAMuHMdXqjmo2T3V=msZySVSu2j4YjyE7FnVXWTjySEyfYLSg1A@mail.gmail.com>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, Linux MM <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jul 1, 2015 at 8:59 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Wed, Jul 01, 2015 at 08:55:57AM +0200, Geert Uytterhoeven wrote:
>> >
>> > I think doing this at runtime might be a better idea.  E.g. a
>> > ioremap_flags with the CACHED argument will return -EOPNOTSUP unless
>> > actually implemented.  On various architectures different CPUs or
>> > boards will have different capabilities in this area.
>>
>> So it would be the responsibility of the caller to fall back from
>> ioremap(..., CACHED) to ioremap(..., UNCACHED)?
>> I.e. all drivers using it should be changed...
>
> All of the zero users we currently have will need to be changed, yes.

Good. Less work to convert all of these ;-)

> Note that I propose to leave ioremap(), aka ioremap_flags(..., 0) as
> a default that always has to work, -EOPNOTSUP is only a valid return
> value for non-default flaga.

OK.

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
