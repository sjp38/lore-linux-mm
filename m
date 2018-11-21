Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7D66B2765
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 15:19:35 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id o205so8352298itc.2
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 12:19:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s197-v6sor3227394itb.11.2018.11.21.12.19.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 12:19:34 -0800 (PST)
MIME-Version: 1.0
References: <201811171022.9O8KA7ol%fengguang.wu@intel.com> <20181121181556.GD5704@rapoport-lnx>
In-Reply-To: <20181121181556.GD5704@rapoport-lnx>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 21 Nov 2018 12:19:22 -0800
Message-ID: <CAKgT0Uff+CB=tyaE-0bc9p5ifUizbshx1QuBeOtBQbuPLvbkdw@mail.gmail.com>
Subject: Re: [mmotm:master 47/137] htmldocs: mm/memblock.c:1261: warning:
 Function parameter or member 'out_spfn' not described in '__next_mem_pfn_range_in_zone'
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.ibm.com
Cc: alexander.h.duyck@linux.intel.com, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Wed, Nov 21, 2018 at 10:16 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Hi Alex,
>
> On Sat, Nov 17, 2018 at 10:26:25AM +0800, kbuild test robot wrote:
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   4de8d18fa38298433f161f8780b5e1b0f01a8c17
> > commit: 711bb3ee3832a764cb2ea03e97b7183b938e1f6c [47/137] mm: implement new zone specific memblock iterator
> > reproduce: make htmldocs
> >
> > All warnings (new ones prefixed by >>):
> >
> >    WARNING: convert(1) not found, for SVG to PDF conversion install ImageMagick (https://www.imagemagick.org)
> >    mm/memblock.c:1261: warning: Excess function parameter 'out_start' description in '__next_mem_pfn_range_in_zone'
> >    mm/memblock.c:1261: warning: Excess function parameter 'out_end' description in '__next_mem_pfn_range_in_zone'
> > >> mm/memblock.c:1261: warning: Function parameter or member 'out_spfn' not described in '__next_mem_pfn_range_in_zone'
> > >> mm/memblock.c:1261: warning: Function parameter or member 'out_epfn' not described in '__next_mem_pfn_range_in_zone'
> >    mm/memblock.c:1261: warning: Excess function parameter 'out_start' description in '__next_mem_pfn_range_in_zone'
> >    mm/memblock.c:1261: warning: Excess function parameter 'out_end' description in '__next_mem_pfn_range_in_zone'
>
> Can you please fix those?

Yes. I have a follow-up patch set in the works and that is one of the
things I plan to address.

Thanks.

- Alex
