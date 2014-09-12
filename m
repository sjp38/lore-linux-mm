Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2436B003A
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 16:21:56 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id v10so1978275pde.3
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 13:21:56 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ay7si9905914pdb.155.2014.09.12.13.21.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 13:21:55 -0700 (PDT)
Date: Fri, 12 Sep 2014 16:21:38 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Message-ID: <20140912202138.GA24501@laptop.dumpdata.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
 <20140904201123.GA9116@khazad-dum.debian.net>
 <5408C9C4.1010705@zytor.com>
 <20140904231923.GA15320@khazad-dum.debian.net>
 <CALCETrWxKFtM8FhnHQz--uaHYbiqShE1XLJxMCKN7Rs4SO14eQ@mail.gmail.com>
 <20140912192501.GG15656@laptop.dumpdata.com>
 <CALCETrU5r8r-RZ82yXd+Tfrhfz=CfdmCwh4A559kTVcDXFR5jQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrU5r8r-RZ82yXd+Tfrhfz=CfdmCwh4A559kTVcDXFR5jQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>

On Fri, Sep 12, 2014 at 01:03:12PM -0700, Andy Lutomirski wrote:
> On Fri, Sep 12, 2014 at 12:25 PM, Konrad Rzeszutek Wilk
> <konrad.wilk@oracle.com> wrote:
> > On Thu, Sep 04, 2014 at 04:34:43PM -0700, Andy Lutomirski wrote:
> >> At the very least, anyone who plugs an NV-DIMM into a 32-bit machine
> >> is nuts, and not just because I'd be somewhat amazed if it even
> >> physically fits into the slot. :)
> >
> > They do have PCIe to PCI adapters, so you _could_ do it :-)
> >
> 
> My NV-DIMMs are DDR3 RDIMMs, so it would be a very magical adapter indeed.

I misread that as 'NVME', duh!

> 
> --Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
