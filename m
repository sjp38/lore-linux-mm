Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7200C900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 17:38:34 -0400 (EDT)
Received: by wgv5 with SMTP id 5so19717918wgv.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 14:38:34 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id r1si4120949wic.112.2015.06.03.14.38.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 14:38:33 -0700 (PDT)
Received: by wiga1 with SMTP id a1so28521364wig.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 14:38:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Wed, 3 Jun 2015 14:38:32 -0700
Message-ID: <CAPcyv4g4PzhWR3O=15SVmhSdE8TAbiXzcjS5JvcGzJaKGW=_Xg@mail.gmail.com>
Subject: Re: [PATCH v3 0/6] pmem api, generic ioremap_cache, and memremap
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, mpe@ellerman.id.au, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Christoph Hellwig <hch@lst.de>

On Wed, Jun 3, 2015 at 2:34 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> The pmem api is responsible for shepherding data out to persistent
> media.  The pmem driver uses this api, when available, to assert that
> data is durable by the time bio_endio() is invoked.  When an
> architecture or cpu can not make persistence guarantees the driver warns
> and falls back to "best effort" implementation.
>
> Changes since v2 [1]:

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-May/000987.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
