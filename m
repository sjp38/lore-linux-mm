Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC9D8E0001
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 08:58:19 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id k18-v6so6216371otl.16
        for <linux-mm@kvack.org>; Sat, 15 Sep 2018 05:58:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t187-v6si4588630oie.215.2018.09.15.05.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Sep 2018 05:58:17 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8FCrdkE144923
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 08:58:16 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgwd3g8s5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 08:58:16 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 15 Sep 2018 13:58:14 +0100
Date: Sat, 15 Sep 2018 15:58:07 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mips: switch to NO_BOOTMEM
References: <1536571398-29194-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180914195300.7wnmsph2qhpixm7s@pburton-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180914195300.7wnmsph2qhpixm7s@pburton-laptop>
Message-Id: <20180915125806.GH15191@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Burton <paul.burton@mips.com>
Cc: Serge Semin <fancer.lancer@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 14, 2018 at 12:53:00PM -0700, Paul Burton wrote:
> Hi Mike,
> 
> On Mon, Sep 10, 2018 at 12:23:18PM +0300, Mike Rapoport wrote:
> > MIPS already has memblock support and all the memory is already registered
> > with it.
> > 
> > This patch replaces bootmem memory reservations with memblock ones and
> > removes the bootmem initialization.
> > 
> > Since memblock allocates memory in top-down mode, we ensure that memblock
> > limit is max_low_pfn to prevent allocations from the high memory.
> > 
> > To have the exceptions base in the lower 512M of the physical memory, its
> > allocation in arch/mips/kernel/traps.c::traps_init() is using bottom-up
> > mode.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> > v2:
> > * set memblock limit to max_low_pfn to avoid allocation attempts from high
> > memory
> > * use boottom-up mode for allocation of the exceptions base
> > 
> > Build tested with *_defconfig.
> > Boot tested with qemu-system-mips64el for 32r6el, 64r6el and fuloong2e
> > defconfigs.
> > Boot tested with qemu-system-mipsel for malta defconfig.
> > 
> >  arch/mips/Kconfig                      |  1 +
> >  arch/mips/kernel/setup.c               | 99 ++++++++--------------------------
> >  arch/mips/kernel/traps.c               |  3 ++
> >  arch/mips/loongson64/loongson-3/numa.c | 34 ++++++------
> >  arch/mips/sgi-ip27/ip27-memory.c       | 11 ++--
> >  5 files changed, 46 insertions(+), 102 deletions(-)
> 
> Thanks - applied to mips-next for 4.20.
> 
> Apologies for the delay, my son decided to be born a few weeks early &
> scupper my plans :)

Congratulations! :)
 
> Paul
> 

-- 
Sincerely yours,
Mike.
