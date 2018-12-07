Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A94BA8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 10:32:56 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id d196so3607235qkb.6
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 07:32:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q128si2315513qka.151.2018.12.07.07.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 07:32:55 -0800 (PST)
Date: Fri, 7 Dec 2018 10:32:49 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v2 1/3] mm/mmu_notifier: use structure for
 invalidate_range_start/end callback
Message-ID: <20181207153249.GA3293@redhat.com>
References: <20181205053628.3210-1-jglisse@redhat.com>
 <20181205053628.3210-2-jglisse@redhat.com>
 <20181207033027.GA20236@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181207033027.GA20236@ziepe.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, Dec 06, 2018 at 08:30:27PM -0700, Jason Gunthorpe wrote:
> On Wed, Dec 05, 2018 at 12:36:26AM -0500, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > To avoid having to change many callback definition everytime we want
> > to add a parameter use a structure to group all parameters for the
> > mmu_notifier invalidate_range_start/end callback. No functional changes
> > with this patch.
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Matthew Wilcox <mawilcox@microsoft.com>
> > Cc: Ross Zwisler <zwisler@kernel.org>
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Paolo Bonzini <pbonzini@redhat.com>
> > Cc: Radim Krčmář <rkrcmar@redhat.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Christian Koenig <christian.koenig@amd.com>
> > Cc: Felix Kuehling <felix.kuehling@amd.com>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: kvm@vger.kernel.org
> > Cc: dri-devel@lists.freedesktop.org
> > Cc: linux-rdma@vger.kernel.org
> > Cc: linux-fsdevel@vger.kernel.org
> > ---
> >  drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  | 43 +++++++++++--------------
> >  drivers/gpu/drm/i915/i915_gem_userptr.c | 14 ++++----
> >  drivers/gpu/drm/radeon/radeon_mn.c      | 16 ++++-----
> >  drivers/infiniband/core/umem_odp.c      | 20 +++++-------
> >  drivers/infiniband/hw/hfi1/mmu_rb.c     | 13 +++-----
> >  drivers/misc/mic/scif/scif_dma.c        | 11 ++-----
> >  drivers/misc/sgi-gru/grutlbpurge.c      | 14 ++++----
> >  drivers/xen/gntdev.c                    | 12 +++----
> >  include/linux/mmu_notifier.h            | 14 +++++---
> >  mm/hmm.c                                | 23 ++++++-------
> >  mm/mmu_notifier.c                       | 21 ++++++++++--
> >  virt/kvm/kvm_main.c                     | 14 +++-----
> >  12 files changed, 102 insertions(+), 113 deletions(-)
> 
> The changes to drivers/infiniband look mechanical and fine to me.
> 
> It even looks like this avoids merge conflicts with the other changes
> to these files :)
> 
> For infiniband:
> 
> Acked-by: Jason Gunthorpe <jgg@mellanox.com>
> 
> I assume this will go through the mm tree?

Yes this is my exceptation as in the ends it touch more mm
stuff than anything else. Andrew already added v1 to its
patchset.

Cheers,
Jérôme
