Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35C736B026B
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:56:04 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id b185-v6so31103189qkg.19
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:56:04 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id d75-v6si6514819qkb.390.2018.07.11.06.56.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 06:56:03 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6BDrrjq130814
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:56:02 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2120.oracle.com with ESMTP id 2k2p7dxa35-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:56:01 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6BDu0B6003932
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:56:00 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6BDtx71000473
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:56:00 GMT
Received: by mail-oi0-f49.google.com with SMTP id n84-v6so49372695oib.9
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:55:59 -0700 (PDT)
MIME-Version: 1.0
References: <20180710235044.vjlRV%akpm@linux-foundation.org>
 <87lgai9bt5.fsf@concordia.ellerman.id.au> <20180711133737.GA29573@techadventures.net>
In-Reply-To: <20180711133737.GA29573@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 11 Jul 2018 09:55:59 -0400
Message-ID: <CAGM2reYsSi5kDGtnTQASnp1v49T8Y+9o_pNxmSq-+m68QhF2Tg@mail.gmail.com>
Subject: Re: Boot failures with "mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER"
 on powerpc (was Re: mmotm 2018-07-10-16-50 uploaded)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: mpe@ellerman.id.au, Andrew Morton <akpm@linux-foundation.org>, broonie@kernel.org, mhocko@suse.cz, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, mm-commits@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, bhe@redhat.com, aneesh.kumar@linux.ibm.com, khandual@linux.vnet.ibm.com

I am OK, if this patch is removed from Baoquan's series. But, I would
still like to get rid of CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER, I
can work on this in my sparse_init re-write series. ppc64 should
really fallback safely to small chunks allocs, and if it does not
there is some existing bug. Michael please send the config that you
used.

Thank you,
Pavel
On Wed, Jul 11, 2018 at 9:37 AM Oscar Salvador
<osalvador@techadventures.net> wrote:
>
> On Wed, Jul 11, 2018 at 10:49:58PM +1000, Michael Ellerman wrote:
> > akpm@linux-foundation.org writes:
> > > The mm-of-the-moment snapshot 2018-07-10-16-50 has been uploaded to
> > >
> > >    http://www.ozlabs.org/~akpm/mmotm/
> > ...
> >
> > > * mm-sparse-add-a-static-variable-nr_present_sections.patch
> > > * mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
> > > * mm-sparsemem-defer-the-ms-section_mem_map-clearing-fix.patch
> > > * mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
> > > * mm-sparse-optimize-memmap-allocation-during-sparse_init.patch
> > > * mm-sparse-optimize-memmap-allocation-during-sparse_init-checkpatch-fixes.patch
> >
> > > * mm-sparse-remove-config_sparsemem_alloc_mem_map_together.patch
> >
> > This seems to be breaking my powerpc pseries qemu boots.
> >
> > The boot log with some extra debug shows eg:
> >
> >   $ make pseries_le_defconfig
>
> Could you please share the config?
> I was not able to find such config in the kernel tree.
> --
> Oscar Salvador
> SUSE L3
>
