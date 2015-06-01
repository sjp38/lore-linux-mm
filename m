Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id AED776B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 04:58:27 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so31787105wib.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 01:58:27 -0700 (PDT)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com. [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id gk19si23617662wjc.187.2015.06.01.01.58.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 01:58:26 -0700 (PDT)
Received: by wgez8 with SMTP id z8so108171217wge.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 01:58:25 -0700 (PDT)
Date: Mon, 1 Jun 2015 10:58:21 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v10 12/12] drivers/block/pmem: Map NVDIMM with
 ioremap_wt()
Message-ID: <20150601085821.GA15014@gmail.com>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
 <1432739944-22633-13-git-send-email-toshi.kani@hp.com>
 <20150529091129.GC31435@pd.tnic>
 <CAPcyv4jHbrUP7bDpw2Cja5x0eMQZBLmmzFXbotQWSEkAiL1s7Q@mail.gmail.com>
 <1432911782.23540.55.camel@misato.fc.hp.com>
 <CAPcyv4g+zYFkEYpa0HCh0Q+2C3wWNr6v3ZU143h52OKf=U=Qvw@mail.gmail.com>
 <CALCETrXXfujebOemesBtgKCkmRTOQFGjdcxjFDF+_P_tv+C0bw@mail.gmail.com>
 <94D0CD8314A33A4D9D801C0FE68B40295A92F392@G9W0745.americas.hpqcorp.net>
 <CALCETrXhNsk9yX=gerxqHCR6+CLdCGrjt9pDk98yeF0L7yyPvg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXhNsk9yX=gerxqHCR6+CLdCGrjt9pDk98yeF0L7yyPvg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Elliott, Robert (Server Storage)" <Elliott@hp.com>, Dan Williams <dan.j.williams@intel.com>, "Kani, Toshimitsu" <toshi.kani@hp.com>, Borislav Petkov <bp@alien8.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Luis Rodriguez <mcgrof@suse.com>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@linux.intel.com>


* Andy Lutomirski <luto@amacapital.net> wrote:

> You answered the wrong question. :) I understand the point of the non-temporal 
> stores -- I don't understand the point of using non-temporal stores to *WB 
> memory*.  I think we should be okay with having the kernel mapping use WT 
> instead.

WB memory is write-through, but they are still fully cached for reads.

So non-temporal instructions influence how the CPU will allocate (or not allocate) 
WT cache lines.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
