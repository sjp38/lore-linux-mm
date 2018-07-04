Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA64B6B0283
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 11:22:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f16-v6so2210411edq.18
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:22:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q15-v6si4060975edd.134.2018.07.04.08.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 08:21:59 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w64FIhD2006077
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 11:21:57 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0xh0x594-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 11:21:57 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 16:21:55 +0100
Date: Wed, 4 Jul 2018 18:21:49 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
 <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
 <20180704070305.GB4352@rapoport-lnx>
 <20180704075449.GB458@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704075449.GB458@jagdpanzerIV>
Message-Id: <20180704152148.GK4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jul 04, 2018 at 04:54:49PM +0900, Sergey Senozhatsky wrote:
> On (07/04/18 10:03), Mike Rapoport wrote:
> >  arch/alpha/kernel/pci_iommu.c             | 20 ++++++++++----------
> >  arch/arm/mm/alignment.c                   |  2 +-
> >  arch/arm/nwfpe/fpmodule.c                 |  2 +-
> >  arch/microblaze/mm/pgtable.c              |  2 +-
> >  arch/sparc/kernel/ds.c                    |  2 +-
> >  arch/um/kernel/sysrq.c                    |  2 +-
> >  arch/x86/include/asm/trace/exceptions.h   |  2 +-
> >  arch/x86/kernel/irq_64.c                  |  2 +-
> >  arch/x86/mm/extable.c                     |  4 ++--
> >  arch/x86/xen/multicalls.c                 |  2 +-
> 
> Isn't it "funny" that parisc, ia64, powerpc don't use pf/pF in arch code,
> but x86, arm, etc. do use pf/pF in arch code?
> 
> Surely, I do understand why we have pf/pF in mm, drivers and all over the
> place. But still, I'm surprised.

That's because somebody (including you) did the conversion ;-)
 
> 	-ss
> 

-- 
Sincerely yours,
Mike.
