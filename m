Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0126B026E
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:13:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t78-v6so16899782pfa.8
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:13:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v17-v6si22353515pfl.233.2018.07.11.14.13.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 14:13:46 -0700 (PDT)
Date: Wed, 11 Jul 2018 14:13:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Boot failures with
 "mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER" on powerpc (was
 Re: mmotm 2018-07-10-16-50 uploaded)
Message-Id: <20180711141344.10eb6d22b0ee1423cc94faf8@linux-foundation.org>
In-Reply-To: <CAGM2reYsSi5kDGtnTQASnp1v49T8Y+9o_pNxmSq-+m68QhF2Tg@mail.gmail.com>
References: <20180710235044.vjlRV%akpm@linux-foundation.org>
	<87lgai9bt5.fsf@concordia.ellerman.id.au>
	<20180711133737.GA29573@techadventures.net>
	<CAGM2reYsSi5kDGtnTQASnp1v49T8Y+9o_pNxmSq-+m68QhF2Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: osalvador@techadventures.net, mpe@ellerman.id.au, broonie@kernel.org, mhocko@suse.cz, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, mm-commits@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, bhe@redhat.com, aneesh.kumar@linux.ibm.com, khandual@linux.vnet.ibm.com

On Wed, 11 Jul 2018 09:55:59 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> On Wed, Jul 11, 2018 at 9:37 AM Oscar Salvador
> <osalvador@techadventures.net> wrote:
> >
> > On Wed, Jul 11, 2018 at 10:49:58PM +1000, Michael Ellerman wrote:
> > > akpm@linux-foundation.org writes:
> > > > The mm-of-the-moment snapshot 2018-07-10-16-50 has been uploaded to
> > > >
> > > >    http://www.ozlabs.org/~akpm/mmotm/
> > > ...
> > >
> > > > * mm-sparse-add-a-static-variable-nr_present_sections.patch
> > > > * mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
> > > > * mm-sparsemem-defer-the-ms-section_mem_map-clearing-fix.patch
> > > > * mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
> > > > * mm-sparse-optimize-memmap-allocation-during-sparse_init.patch
> > > > * mm-sparse-optimize-memmap-allocation-during-sparse_init-checkpatch-fixes.patch
> > >
> > > > * mm-sparse-remove-config_sparsemem_alloc_mem_map_together.patch
> > >
> > > This seems to be breaking my powerpc pseries qemu boots.
> > >
> > > The boot log with some extra debug shows eg:
> > >
> > >   $ make pseries_le_defconfig
> >
> > Could you please share the config?
> > I was not able to find such config in the kernel tree.

(top-posting repaired so I can reply to your email, add other people
and not confuse the heck out of them.  Please don't)

> I am OK, if this patch is removed from Baoquan's series. But, I would
> still like to get rid of CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER, I
> can work on this in my sparse_init re-write series. ppc64 should
> really fallback safely to small chunks allocs, and if it does not
> there is some existing bug. Michael please send the config that you
> used.

OK, I shall drop
mm-sparse-remove-config_sparsemem_alloc_mem_map_together.patch for now.
