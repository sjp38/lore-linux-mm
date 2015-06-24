Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5050A6B0032
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 08:24:13 -0400 (EDT)
Received: by wguu7 with SMTP id u7so34777895wgu.3
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 05:24:12 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r1si2594955wic.9.2015.06.24.05.24.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jun 2015 05:24:11 -0700 (PDT)
Date: Wed, 24 Jun 2015 14:24:10 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
Message-ID: <20150624122410.GA18241@lst.de>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com> <20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com> <20150622161002.GB8240@lst.de> <CAPcyv4gSMixA6KNpqXR8pkEpff=Z-N+LbQmuxpiVLs4yMfqZSg@mail.gmail.com> <20150623100757.GA24894@lst.de> <CAPcyv4hXwdsF0a1=FhK6wn5US9p-T9t7OxwVsiMiCM=M-a7o6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hXwdsF0a1=FhK6wn5US9p-T9t7OxwVsiMiCM=M-a7o6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, mpe@ellerman.id.au, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>

On Tue, Jun 23, 2015 at 08:04:47AM -0700, Dan Williams wrote:
> Thanks, definitely a long shot at this point, but this is what one
> gets for fixing rather than working around broken base infrastructure.
> It would be unfortunate if we went another cycle with pmem having both
> poor performance and broken persistence guarantees.

Maybe we can aim for the minimal fix for 4.2 that just adds meremap
and the accessors for x86 and the do the big scale cleanups for 4.3?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
