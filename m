Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C08288E00D7
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 11:28:40 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d41so3845766eda.12
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 08:28:40 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y18-v6si58878ejg.267.2019.01.25.08.28.38
        for <linux-mm@kvack.org>;
        Fri, 25 Jan 2019 08:28:39 -0800 (PST)
Date: Fri, 25 Jan 2019 16:28:31 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 7/9] arm64: kdump: No need to mark crashkernel pages
 manually PG_reserved
Message-ID: <20190125162830.GK25901@arrakis.emea.arm.com>
References: <20190114125903.24845-1-david@redhat.com>
 <20190114125903.24845-8-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190114125903.24845-8-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, Will Deacon <will.deacon@arm.com>, James Morse <james.morse@arm.com>, Bhupesh Sharma <bhsharma@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Dave Kleikamp <dave.kleikamp@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Florian Fainelli <f.fainelli@gmail.com>, Stefan Agner <stefan@agner.ch>, Laura Abbott <labbott@redhat.com>, Greg Hackmann <ghackmann@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Kristina Martsenko <kristina.martsenko@arm.com>, CHANDAN VN <chandan.vn@samsung.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Logan Gunthorpe <logang@deltatee.com>

On Mon, Jan 14, 2019 at 01:59:01PM +0100, David Hildenbrand wrote:
> The crashkernel is reserved via memblock_reserve(). memblock_free_all()
> will call free_low_memory_core_early(), which will go over all reserved
> memblocks, marking the pages as PG_reserved.
> 
> So manually marking pages as PG_reserved is not necessary, they are
> already in the desired state (otherwise they would have been handed over
> to the buddy as free pages and bad things would happen).
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: James Morse <james.morse@arm.com>
> Cc: Bhupesh Sharma <bhsharma@redhat.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Dave Kleikamp <dave.kleikamp@oracle.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Stefan Agner <stefan@agner.ch>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Greg Hackmann <ghackmann@android.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Kristina Martsenko <kristina.martsenko@arm.com>
> Cc: CHANDAN VN <chandan.vn@samsung.com>
> Cc: AKASHI Takahiro <takahiro.akashi@linaro.org>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Reviewed-by: Matthias Brugger <mbrugger@suse.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
