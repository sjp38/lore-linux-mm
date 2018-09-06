Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC67F6B7787
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 03:30:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x24-v6so3334099edm.13
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 00:30:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13-v6si2794985edb.96.2018.09.06.00.30.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 00:30:24 -0700 (PDT)
Date: Thu, 6 Sep 2018 09:30:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 04/29] mm: remove bootmem allocator implementation.
Message-ID: <20180906073023.GO14951@dhcp22.suse.cz>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-5-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536163184-26356-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:19, Mike Rapoport wrote:
> All architectures have been converted to use MEMBLOCK + NO_BOOTMEM. The
> bootmem allocator implementation can be removed.

\o/

Is there any reason to keep

ifdef CONFIG_NO_BOOTMEM
	obj-y		+= nobootmem.o
else
	obj-y		+= bootmem.o
endif

behind?

> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/bootmem.h |  16 -
>  mm/bootmem.c            | 811 ------------------------------------------------
>  2 files changed, 827 deletions(-)
>  delete mode 100644 mm/bootmem.c
-- 
Michal Hocko
SUSE Labs
