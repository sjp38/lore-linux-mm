Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 387C76B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 15:05:00 -0400 (EDT)
Received: by yhak3 with SMTP id k3so39624589yha.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:05:00 -0700 (PDT)
Received: from mail-yh0-x231.google.com (mail-yh0-x231.google.com. [2607:f8b0:4002:c01::231])
        by mx.google.com with ESMTPS id 124si1708879ykg.104.2015.06.08.12.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 12:04:59 -0700 (PDT)
Received: by yhpn97 with SMTP id n97so44109129yhp.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:04:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gVuPUFJatsqia3ie-+iHDhEp5DTssDdz7bdWPO0on4Gw@mail.gmail.com>
References: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150603213440.13749.1981.stgit@dwillia2-desk3.amr.corp.intel.com>
	<CAHp75Vc7CJSkFvnyHwONd0w50oxvf+rtb6_a4kqhtxe8dmzDWQ@mail.gmail.com>
	<CAPcyv4gVuPUFJatsqia3ie-+iHDhEp5DTssDdz7bdWPO0on4Gw@mail.gmail.com>
Date: Mon, 8 Jun 2015 22:04:59 +0300
Message-ID: <CAHp75VdW5Pd-h1qvOm+sTT6xoAbYRY9aBR8aTMF7QQ8sT05FZw@mail.gmail.com>
Subject: Re: [PATCH v3 5/6] arch: introduce memremap_cache() and memremap_wt()
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, mpe@ellerman.id.au, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Christoph Hellwig <hch@lst.de>

On Mon, Jun 8, 2015 at 9:25 PM, Dan Williams <dan.j.williams@intel.com> wro=
te:

>>> +       if (region_is_ram(offset, size) !=3D 0) {
>>> +               WARN_ONCE(1, "memremap attempted on ram %pa size: %zd\n=
",
>>
>> %zu
>
> Sure, thanks for taking a look Andy!

One more thing, can we do
WARN_ONCE(region_is_ram(offset, size), =E2=80=A6); ?

--=20
With Best Regards,
Andy Shevchenko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
