Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00BE28E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 11:51:13 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id v7so1962044wme.9
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 08:51:12 -0800 (PST)
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id g7si7846111wme.195.2018.12.21.08.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 08:51:11 -0800 (PST)
Message-ID: <1545411069.25523.33.camel@bitdefender.com>
Subject: Re: [RFC PATCH v5 00/20] VM introspection
From: Mihai =?UTF-8?Q?Don=C8=9Bu?= <mdontu@bitdefender.com>
Date: Fri, 21 Dec 2018 18:51:09 +0200
In-Reply-To: <20181221153917.GA8195@char.us.oracle.com>
References: <20181220182850.4579-1-alazar@bitdefender.com>
	 <20181221153917.GA8195@char.us.oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Adalbert =?UTF-8?Q?Laz=C4=83r?= <alazar@bitdefender.com>, linux-mm@kvack.org
Cc: kvm@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Tamas K Lengyel <tamas@tklengyel.com>, Mathieu Tarral <mathieu.tarral@protonmail.com>

CC += Tamas, Mathieu

On Fri, 2018-12-21 at 10:39 -0500, Konrad Rzeszutek Wilk wrote:
> On Thu, Dec 20, 2018 at 08:28:30PM +0200, Adalbert Lazăr wrote:
> > This patch series proposes a VM introspection subsystem for KVM (KVMi).
> > 
> > The previous RFC can be read here: https://marc.info/?l=kvm&m=151362403331566
> > 
> > This iteration brings, mostly:
> >   - an improved remote mapping (moved to the mm/ tree)
> >   - single-step support for #PF events and as an workaround to unimplemented
> >     instructions from the x86 emulator that may need to be handled on EPT
> >     violations VMEXITS
> >   - a new ioctl to allow the introspection tool to remove its hooks from
> >     guest before it is suspended or live migrated
> 
> .. No mention of the libvmi tool - are you going to provide the functionality
> in there as well to use these new ioctls? Would it make sense to CC the libvmi
> community as well to get their input?

There is work underway to rewrite the KVM driver of LibVMI:

https://github.com/KVM-VMI/libvmi (kvmi branch)

and now that v5 has been published, another round of updates is being
prepared. There is also a dedicated kernel repository:

https://github.com/KVM-VMI/kvm (kvmi branch)

as well as a qemu one:

https://github.com/KVM-VMI/qemu (kvmi branch)

PR-s updating them are being prepared too.

> >   - more bugfixes and a lot of stability
> > 
> > Still not implemented yet (even if some are documented) are virtualized
> > exceptions, EPT views and SPP (Sub Page Protection).
> > 
> > We're still looking forward to add kvm unit tests for this VM
> > introspection system now that we've integrated it in our products and
> > in our internal tests framework.
> 
> ..snip..> 
> 
> >  mm/Kconfig                               |    9 +
> >  mm/Makefile                              |    1 +
> >  mm/gup.c                                 |    1 +
> >  mm/huge_memory.c                         |    1 +
> >  mm/internal.h                            |    5 -
> >  mm/mempolicy.c                           |    1 +
> >  mm/mmap.c                                |    1 +
> >  mm/mmu_notifier.c                        |    1 +
> >  mm/pgtable-generic.c                     |    1 +
> >  mm/remote_mapping.c                      | 1438 ++++++++++++++
> >  mm/rmap.c                                |   39 +-
> >  mm/swapfile.c                            |    1 +
> 
> Please make sure to CC linux-mm@kvack.org when posting this.
> 
> In the meantime for folks on linux-mm, pls see https://www.spinics.net/lists/kvm/msg179441.html

-- 
Mihai Donțu
