Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id D1DFA6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:08:00 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so5060609wgb.2
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 03:08:00 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j4si24998449wix.18.2015.06.23.03.07.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jun 2015 03:07:59 -0700 (PDT)
Date: Tue, 23 Jun 2015 12:07:57 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
Message-ID: <20150623100757.GA24894@lst.de>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com> <20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com> <20150622161002.GB8240@lst.de> <CAPcyv4gSMixA6KNpqXR8pkEpff=Z-N+LbQmuxpiVLs4yMfqZSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gSMixA6KNpqXR8pkEpff=Z-N+LbQmuxpiVLs4yMfqZSg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, mpe@ellerman.id.au, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>

On Mon, Jun 22, 2015 at 10:12:40AM -0700, Dan Williams wrote:
> Is that an acked-by for this cycle with a request to go deeper for 4.3?

I wouldn't really expect something this wide reaching to be picked up
for this cycle, but if you manage to get it in:

Acked-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
