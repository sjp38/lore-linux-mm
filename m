Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A60646B0010
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 03:54:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t20-v6so2099907pgu.9
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 00:54:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f8-v6sor755478pgv.422.2018.07.04.00.54.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 00:54:53 -0700 (PDT)
Date: Wed, 4 Jul 2018 16:54:49 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
Message-ID: <20180704075449.GB458@jagdpanzerIV>
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
 <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
 <20180704070305.GB4352@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704070305.GB4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>

On (07/04/18 10:03), Mike Rapoport wrote:
>  arch/alpha/kernel/pci_iommu.c             | 20 ++++++++++----------
>  arch/arm/mm/alignment.c                   |  2 +-
>  arch/arm/nwfpe/fpmodule.c                 |  2 +-
>  arch/microblaze/mm/pgtable.c              |  2 +-
>  arch/sparc/kernel/ds.c                    |  2 +-
>  arch/um/kernel/sysrq.c                    |  2 +-
>  arch/x86/include/asm/trace/exceptions.h   |  2 +-
>  arch/x86/kernel/irq_64.c                  |  2 +-
>  arch/x86/mm/extable.c                     |  4 ++--
>  arch/x86/xen/multicalls.c                 |  2 +-

Isn't it "funny" that parisc, ia64, powerpc don't use pf/pF in arch code,
but x86, arm, etc. do use pf/pF in arch code?

Surely, I do understand why we have pf/pF in mm, drivers and all over the
place. But still, I'm surprised.

	-ss
