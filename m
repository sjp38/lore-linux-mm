Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 903336B026D
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 09:14:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o5-v6so2198184edq.15
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 06:14:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18-v6si3515535edj.72.2018.07.04.06.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 06:14:06 -0700 (PDT)
Date: Wed, 4 Jul 2018 15:14:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
Message-ID: <20180704131404.GR22503@dhcp22.suse.cz>
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530685696-14672-4-git-send-email-rppt@linux.vnet.ibm.com>
 <CAMuHMdWEHSz34bN-U3gHW972w13f_Jrx_ObEsP3w8XZ1Gx65OA@mail.gmail.com>
 <20180704075410.GF22503@dhcp22.suse.cz>
 <89f48f7a-6cbf-ac9a-cacc-cd3ca79f8c66@suse.cz>
 <20180704123627.GM22503@dhcp22.suse.cz>
 <CAMuHMdVuLd=y4Wk6ghFZ8YV_1Z9kvh588VkwBMwxScxateMu1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdVuLd=y4Wk6ghFZ8YV_1Z9kvh588VkwBMwxScxateMu1g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed 04-07-18 15:05:08, Geert Uytterhoeven wrote:
> Hi Michal,
> 
> On Wed, Jul 4, 2018 at 2:36 PM Michal Hocko <mhocko@kernel.org> wrote:
> > [CC Andrew - email thread starts
> > http://lkml.kernel.org/r/1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com]
> >
> > OK, so here we go with the full patch.
> >
> > From 0e8432b875d98a7a0d3f757fce2caa8d16a8de15 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Wed, 4 Jul 2018 14:31:46 +0200
> > Subject: [PATCH] memblock: do not complain about top-down allocations for
> >  !MEMORY_HOTREMOVE
> >
> > Mike Rapoport is converting architectures from bootmem to noboodmem
> 
> nobootmem

fixed

> 
> > allocator. While doing so for m68k Geert has noticed that he gets
> > a scary looking warning
> > WARNING: CPU: 0 PID: 0 at mm/memblock.c:230
> > memblock_find_in_range_node+0x11c/0x1be
> > memblock: bottom-up allocation failed, memory hotunplug may be affected
> 
> > The warning is basically saying that a top-down allocation can break
> > memory hotremove because memblock allocation is not movable. But m68k
> > doesn't even support MEMORY_HOTREMOVE is there is no point to warn
> 
> so there is

fixed

> > about it.
> >
> > Make the warning conditional only to configurations that care.
> 
> Still, I'm wondering if the warning is really that unlikely on systems
> that support
> hotremove. Or is it due to the low amount of RAM on m68k boxes?

Most likely yes. If you want to have full NUMA nodes hot-removable then
the BIOS/FW is supposed to mark them hotplug and then we rely on the
available memory on the low physical memory ranges (usually on not 0)
to cover all early boot allocations. Hack? Sure thing like the whole
memory hotremove, if you ask me.
-- 
Michal Hocko
SUSE Labs
