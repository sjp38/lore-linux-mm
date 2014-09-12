Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E5B7F6B0038
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 15:25:24 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ey11so1909400pad.20
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 12:25:24 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f8si9746528pdm.106.2014.09.12.12.25.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 12:25:23 -0700 (PDT)
Date: Fri, 12 Sep 2014 15:25:01 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Message-ID: <20140912192501.GG15656@laptop.dumpdata.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
 <20140904201123.GA9116@khazad-dum.debian.net>
 <5408C9C4.1010705@zytor.com>
 <20140904231923.GA15320@khazad-dum.debian.net>
 <CALCETrWxKFtM8FhnHQz--uaHYbiqShE1XLJxMCKN7Rs4SO14eQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWxKFtM8FhnHQz--uaHYbiqShE1XLJxMCKN7Rs4SO14eQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>

On Thu, Sep 04, 2014 at 04:34:43PM -0700, Andy Lutomirski wrote:
> On Thu, Sep 4, 2014 at 4:19 PM, Henrique de Moraes Holschuh
> <hmh@hmh.eng.br> wrote:
> > On Thu, 04 Sep 2014, H. Peter Anvin wrote:
> >> On 09/04/2014 01:11 PM, Henrique de Moraes Holschuh wrote:
> >> > I am worried of uncharted territory, here.  I'd actually advocate for not
> >> > enabling the upper four PAT entries on IA-32 at all, unless Windows 9X / XP
> >> > is using them as well.  Is this a real concern, or am I being overly
> >> > cautious?
> >>
> >> It is extremely unlikely that we'd have PAT issues in 32-bit mode and
> >> not in 64-bit mode on the same CPU.
> >
> > Sure, but is it really a good idea to enable this on the *old* non-64-bit
> > capable processors (note: I don't mean x86-64 processors operating in 32-bit
> > mode) ?
> >
> >> As far as I know, the current blacklist rule is very conservative due to
> >> lack of testing more than anything else.
> >
> > I was told that much in 2009 when I asked why cpuid 0x6d8 was blacklisted
> > from using PAT :-)
> 
> At the very least, anyone who plugs an NV-DIMM into a 32-bit machine
> is nuts, and not just because I'd be somewhat amazed if it even
> physically fits into the slot. :)

They do have PCIe to PCI adapters, so you _could_ do it :-)

> 
> --Andy
> 
> >
> > --
> >   "One disk to rule them all, One disk to find them. One disk to bring
> >   them all and in the darkness grind them. In the Land of Redmond
> >   where the shadows lie." -- The Silicon Valley Tarot
> >   Henrique Holschuh
> 
> 
> 
> -- 
> Andy Lutomirski
> AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
