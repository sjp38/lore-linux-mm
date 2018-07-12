Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 158EF6B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 01:24:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v9-v6so7792127pfn.6
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 22:24:47 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id o8-v6si14893819pgl.534.2018.07.11.22.24.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Jul 2018 22:24:45 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: Boot failures with "mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER" on powerpc (was Re: mmotm 2018-07-10-16-50 uploaded)
In-Reply-To: <CAOXBz7ixEK85S-029XrM4+g4fxtSY6_tke0gcQ-hOXFCb7wcZg@mail.gmail.com>
References: <20180710235044.vjlRV%akpm@linux-foundation.org> <87lgai9bt5.fsf@concordia.ellerman.id.au> <20180711133737.GA29573@techadventures.net> <CAGM2reYsSi5kDGtnTQASnp1v49T8Y+9o_pNxmSq-+m68QhF2Tg@mail.gmail.com> <CAOXBz7ixEK85S-029XrM4+g4fxtSY6_tke0gcQ-hOXFCb7wcZg@mail.gmail.com>
Date: Thu, 12 Jul 2018 15:24:38 +1000
Message-ID: <87efg981rd.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador.vilardaga@gmail.com>, Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, broonie@kernel.org, mhocko@suse.cz, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, mm-commits@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, bhe@redhat.com, aneesh.kumar@linux.ibm.com, khandual@linux.vnet.ibm.com

Oscar Salvador <osalvador.vilardaga@gmail.com> writes:
> El dc., 11 jul. 2018 , 15:56, Pavel Tatashin <pasha.tatashin@oracle.com> va
> escriure:
>
>> I am OK, if this patch is removed from Baoquan's series. But, I would
>> still like to get rid of CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER, I
>> can work on this in my sparse_init re-write series. ppc64 should
>> really fallback safely to small chunks allocs, and if it does not
>> there is some existing bug. Michael please send the config that you
>> used.
>>
>> Thank you,
>> Pavel
>> On Wed, Jul 11, 2018 at 9:37 AM Oscar Salvador
>> <osalvador@techadventures.net> wrote:
>> >
>> > On Wed, Jul 11, 2018 at 10:49:58PM +1000, Michael Ellerman wrote:
>> > > akpm@linux-foundation.org writes:
>> > > > The mm-of-the-moment snapshot 2018-07-10-16-50 has been uploaded to
>> > > >
>> > > >    http://www.ozlabs.org/~akpm/mmotm/
>> > > ...
>> > >
>> > > > * mm-sparse-add-a-static-variable-nr_present_sections.patch
>> > > > * mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
>> > > > * mm-sparsemem-defer-the-ms-section_mem_map-clearing-fix.patch
>> > > > *
>> mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
>> > > > * mm-sparse-optimize-memmap-allocation-during-sparse_init.patch
>> > > > *
>> mm-sparse-optimize-memmap-allocation-during-sparse_init-checkpatch-fixes.patch
>> > >
>> > > > * mm-sparse-remove-config_sparsemem_alloc_mem_map_together.patch
>> > >
>> > > This seems to be breaking my powerpc pseries qemu boots.
>> > >
>> > > The boot log with some extra debug shows eg:
>> > >
>> > >   $ make pseries_le_defconfig
>> >
>> > Could you please share the config?
>> > I was not able to find such config in the kernel tree.
>>
>>
> I just roughly check, but if I checked the right place,
> vmemmap_populated() checks for the section to contain the flags we are
> setting in sparse_init_one_section().

Yes.

> But with this patch, we populate first everything, and then we call
> sparse_init_one_section() in sparse_init().
> As I said I could be mistaken because I just checked the surface.

Yeah I think that's correct.

This might just be a bug in our code, let me look at it a bit.

cheers
