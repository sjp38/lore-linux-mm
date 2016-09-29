Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5E7A6B0253
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:13:44 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u134so65327223itb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:13:44 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id 10si2047360itm.26.2016.09.29.06.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 06:13:18 -0700 (PDT)
In-Reply-To: <2e840fe0-40cf-abf0-4fe6-a621ce46ae13@gmail.com>
From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: [v3] KVM: PPC: Book3S HV: Migrate pinned pages out of CMA
Message-Id: <3slFPR2kWQz9sC3@ozlabs.org>
Date: Thu, 29 Sep 2016 23:13:15 +1000 (AEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Alexey Kardashevskiy <aik@ozlabs.ru>, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>

On Tue, 2016-06-09 at 06:27:31 UTC, Balbir Singh wrote:
> When PCI Device pass-through is enabled via VFIO, KVM-PPC will
> pin pages using get_user_pages_fast(). One of the downsides of
> the pinning is that the page could be in CMA region. The CMA
> region is used for other allocations like the hash page table.
> Ideally we want the pinned pages to be from non CMA region.
> 
> This patch (currently only for KVM PPC with VFIO) forcefully
> migrates the pages out (huge pages are omitted for the moment).
> There are more efficient ways of doing this, but that might
> be elaborate and might impact a larger audience beyond just
> the kvm ppc implementation.
> 
> The magic is in new_iommu_non_cma_page() which allocates the
> new page from a non CMA region.
> 
> I've tested the patches lightly at my end. The full solution
> requires migration of THP pages in the CMA region. That work
> will be done incrementally on top of this.
> 
> Signed-off-by: Balbir Singh <bsingharora@gmail.com>
> Acked-by: Alexey Kardashevskiy <aik@ozlabs.ru>

Applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/2e5bbb5461f138cac631fe21b4ad95

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
