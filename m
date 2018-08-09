Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF7896B0269
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 05:02:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z20-v6so1874380edq.10
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 02:02:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5-v6si969794edq.130.2018.08.09.02.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 02:02:09 -0700 (PDT)
Date: Thu, 9 Aug 2018 11:02:08 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH V3 0/4] Fix kvm misconceives NVDIMM pages as reserved mmio
Message-ID: <20180809090208.GD5069@quack2.suse.cz>
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com, linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com

On Thu 09-08-18 18:52:48, Zhang Yi wrote:
> For device specific memory space, when we move these area of pfn to
> memory zone, we will set the page reserved flag at that time, some of
> these reserved for device mmio, and some of these are not, such as
> NVDIMM pmem.
> 
> Now, we map these dev_dax or fs_dax pages to kvm for DIMM/NVDIMM
> backend, since these pages are reserved. the check of
> kvm_is_reserved_pfn() misconceives those pages as MMIO. Therefor, we
> introduce 2 page map types, MEMORY_DEVICE_FS_DAX/MEMORY_DEVICE_DEV_DAX,
> to indentify these pages are from NVDIMM pmem. and let kvm treat these
> as normal pages.
> 
> Without this patch, Many operations will be missed due to this
> mistreatment to pmem pages. For example, a page may not have chance to
> be unpinned for KVM guest(in kvm_release_pfn_clean); not able to be
> marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc.
> 
> V1:
> https://lkml.org/lkml/2018/7/4/91
> 
> V2:
> https://lkml.org/lkml/2018/7/10/135
> 
> V3:
> [PATCH V3 1/4] Needs Comments.
> [PATCH V3 2/4] Update the description of MEMORY_DEVICE_DEV_DAX: Jan
> [PATCH V3 3/4] Acked-by: Jan in V2

Hum, but it is not the the patch...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
