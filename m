Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id F1616900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 19:58:26 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so4300977wiw.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 16:58:26 -0700 (PDT)
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id rw6si4020427wjb.95.2015.06.03.16.58.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 16:58:25 -0700 (PDT)
Received: by wgme6 with SMTP id e6so21328249wgm.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 16:58:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150603213423.13749.55822.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150603213423.13749.55822.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Wed, 3 Jun 2015 16:58:24 -0700
Message-ID: <CAPcyv4jpP28UfNDsVa9pV0FuygpirHHWE2AiVgN0eok0+n+Q_g@mail.gmail.com>
Subject: Re: [PATCH v3 2/6] cleanup IORESOURCE_CACHEABLE vs ioremap()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, mpe@ellerman.id.au, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Christoph Hellwig <hch@lst.de>

On Wed, Jun 3, 2015 at 2:34 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> Quoting Arnd:
>     I was thinking the opposite approach and basically removing all uses
>     of IORESOURCE_CACHEABLE from the kernel. There are only a handful of
>     them.and we can probably replace them all with hardcoded
>     ioremap_cached() calls in the cases they are actually useful.
>
> All existing usages of IORESOURCE_CACHEABLE call ioremap() instead of
> ioremap_nocache() if the resource is cacheable, however ioremap() is
> uncached by default.  Clearly none of the existing usages care about the
> cacheability, so let's clean that up before introducing generic
> ioremap_cache() support across architectures.
>
> Suggested-by: Arnd Bergmann <arnd@arndb.de>

Signed-off-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
