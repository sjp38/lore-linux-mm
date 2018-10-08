Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 393AF6B000A
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 16:08:44 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id c16-v6so11837859wrr.8
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 13:08:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o7-v6sor6152126wmo.11.2018.10.08.13.08.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 13:08:42 -0700 (PDT)
MIME-Version: 1.0
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
 <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de>
 <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de> <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de> <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
 <20181003212255.GB28361@zn.tnic> <20181004080321.GA3630@8bytes.org>
 <alpine.DEB.2.21.1810051124320.3960@nanos.tec.linutronix.de>
 <74dededa-3754-058b-2291-a349b9f3673e@molgen.mpg.de> <alpine.DEB.2.21.1810082108570.2455@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1810082108570.2455@nanos.tec.linutronix.de>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 8 Oct 2018 15:08:30 -0500
Message-ID: <CAErSpo5dSd7=BZFoROowLACmkKHHD0gbbRQWN3VCga3M3GepgQ@mail.gmail.com>
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: pmenzel@molgen.mpg.de, Joerg Roedel <joro@8bytes.org>, Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org, x86@kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Oct 8, 2018 at 2:37 PM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> Paul,
>
> On Fri, 5 Oct 2018, Paul Menzel wrote:
> > On 10/05/18 11:27, Thomas Gleixner wrote:
> > > If pcibios is enabled and used, need to look at the gory details of that
> > > first, then the W+X check has to exclude that region. We can't do much
> > > about that.
> >
> > That would also explain, why it only happens with the SeaBIOS payload,
> > which sets up legacy BIOS calls. Using GRUB directly as payload, no BIOS
> > calls are set up.
> >
> > Reading the Kconfig description of the PCI access mode, the BIOS should
> > only be used last.
>
> Correct. And looking at the dmesg you provided it is initialized:
>
> [    0.441062] PCI: PCI BIOS area is rw and x. Use pci=nobios if you want it NX.
> [    0.441062] PCI: PCI BIOS revision 2.10 entry at 0xffa40, last bus=3
>
> Though I assume it's not really required, but this PCI BIOS thing is not
> really well documented and there are some obsure usage sites involved.
>
> Bjorn, do you have any insight or did you flush those memories long ago?

No, I don't.  I was never really involved with PCIBIOS.
