Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED736B025F
	for <linux-mm@kvack.org>; Sat,  2 Sep 2017 09:28:38 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k126so5292624qkb.3
        for <linux-mm@kvack.org>; Sat, 02 Sep 2017 06:28:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 1si2486798qta.99.2017.09.02.06.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Sep 2017 06:28:36 -0700 (PDT)
Date: Sat, 2 Sep 2017 15:28:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/13] mmu_notifier kill invalidate_page callback v2
Message-ID: <20170902132831.GA26026@redhat.com>
References: <20170831211738.17922-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170831211738.17922-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Dan Williams <dan.j.williams@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Jack Steiner <steiner@sgi.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, linuxppc-dev@lists.ozlabs.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, kvm@vger.kernel.org

On Thu, Aug 31, 2017 at 05:17:25PM -0400, Jerome Glisse wrote:
> Jerome Glisse (13):
>   dax: update to new mmu_notifier semantic
>   mm/rmap: update to new mmu_notifier semantic
>   powerpc/powernv: update to new mmu_notifier semantic
>   drm/amdgpu: update to new mmu_notifier semantic
>   IB/umem: update to new mmu_notifier semantic
>   IB/hfi1: update to new mmu_notifier semantic
>   iommu/amd: update to new mmu_notifier semantic
>   iommu/intel: update to new mmu_notifier semantic
>   misc/mic/scif: update to new mmu_notifier semantic
>   sgi-gru: update to new mmu_notifier semantic
>   xen/gntdev: update to new mmu_notifier semantic
>   KVM: update to new mmu_notifier semantic
>   mm/mmu_notifier: kill invalidate_page

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
