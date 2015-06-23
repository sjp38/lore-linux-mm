Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1FB6B006C
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:09:09 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so61520335wiw.0
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 03:09:08 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id es2si24987531wib.45.2015.06.23.03.09.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jun 2015 03:09:07 -0700 (PDT)
Date: Tue, 23 Jun 2015 12:09:06 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 6/6] arch, x86: pmem api for ensuring durability of
	persistent memory updates
Message-ID: <20150623100906.GD24894@lst.de>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com> <20150622082449.35954.91411.stgit@dwillia2-desk3.jf.intel.com> <20150622161754.GC8240@lst.de> <CAPcyv4hweoNDZy8Q=dYbdGoY6wCNpAUFrsHvf9v1UpBqizhMHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hweoNDZy8Q=dYbdGoY6wCNpAUFrsHvf9v1UpBqizhMHw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, mpe@ellerman.id.au, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Richard Weinberger <richard@nod.at>

Oh, and please move the ioremap selftest to a .c file instead of a
header included by almost every driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
