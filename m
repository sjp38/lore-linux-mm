Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D30386B0032
	for <linux-mm@kvack.org>; Fri, 29 May 2015 21:18:55 -0400 (EDT)
Received: by wifw1 with SMTP id w1so43034437wif.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 18:18:55 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id op3si6564157wic.73.2015.05.29.18.18.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 18:18:53 -0700 (PDT)
Received: by wizo1 with SMTP id o1so42927784wiz.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 18:18:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1432940350-1802-13-git-send-email-toshi.kani@hp.com>
References: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
	<1432940350-1802-13-git-send-email-toshi.kani@hp.com>
Date: Fri, 29 May 2015 18:18:52 -0700
Message-ID: <CAPcyv4jrZG4YD+kav4SSD1CaXwzJphgJRgwUUeHLSUAcxZqqNg@mail.gmail.com>
Subject: Re: [PATCH v11 12/12] drivers/block/pmem: Map NVDIMM with ioremap_wt()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Juergen Gross <jgross@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Luis Rodriguez <mcgrof@suse.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Christoph Hellwig <hch@lst.de>

On Fri, May 29, 2015 at 3:59 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> From: Toshi Kani <toshi.kani@hp.com>
>
> The pmem driver maps NVDIMM with ioremap_nocache() as we cannot
> write back the contents of the CPU caches in case of a crash.
>
> This patch changes to use ioremap_wt(), which provides uncached
> writes but cached reads, for improving read performance.
>
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>

Acked-by: Dan Williams <dan.j.williams@intel.com>

...with the caveat that I'm going to follow in behind this series with
generic ioremap_cache() enabling and converting pmem to use
persistent_copy() / persistent_sync() when the arch/cpu has persistent
memory synchronization instructions.  After the conversion
ioremap_wt() will still be there for the non-persistent_sync() capable
case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
