Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD826B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:37:41 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id z16-v6so3184568wrs.22
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:37:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s3-v6sor454449wrm.1.2018.07.11.06.37.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 06:37:39 -0700 (PDT)
Date: Wed, 11 Jul 2018 15:37:37 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: Boot failures with "mm/sparse: Remove
 CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER" on powerpc (was Re: mmotm
 2018-07-10-16-50 uploaded)
Message-ID: <20180711133737.GA29573@techadventures.net>
References: <20180710235044.vjlRV%akpm@linux-foundation.org>
 <87lgai9bt5.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lgai9bt5.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, bhe@redhat.com, pasha.tatashin@oracle.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Wed, Jul 11, 2018 at 10:49:58PM +1000, Michael Ellerman wrote:
> akpm@linux-foundation.org writes:
> > The mm-of-the-moment snapshot 2018-07-10-16-50 has been uploaded to
> >
> >    http://www.ozlabs.org/~akpm/mmotm/
> ...
> 
> > * mm-sparse-add-a-static-variable-nr_present_sections.patch
> > * mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
> > * mm-sparsemem-defer-the-ms-section_mem_map-clearing-fix.patch
> > * mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
> > * mm-sparse-optimize-memmap-allocation-during-sparse_init.patch
> > * mm-sparse-optimize-memmap-allocation-during-sparse_init-checkpatch-fixes.patch
> 
> > * mm-sparse-remove-config_sparsemem_alloc_mem_map_together.patch
> 
> This seems to be breaking my powerpc pseries qemu boots.
> 
> The boot log with some extra debug shows eg:
> 
>   $ make pseries_le_defconfig

Could you please share the config?
I was not able to find such config in the kernel tree.
-- 
Oscar Salvador
SUSE L3
