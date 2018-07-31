Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 989706B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 16:50:06 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id d10-v6so12812558wrw.6
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 13:50:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14-v6sor912281wmf.7.2018.07.31.13.50.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 13:50:05 -0700 (PDT)
Date: Tue, 31 Jul 2018 22:50:03 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Message-ID: <20180731205003.GA3277@techadventures.net>
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
 <20180731144157.GA1499@techadventures.net>
 <20180731144545.fh5syvwcecgvqul6@xakep.localdomain>
 <20180731145125.GB1499@techadventures.net>
 <CAGM2reZSZHdWECr8-7pj6j=CtjWVF2oKC9SwHhMuOsDkigdzgA@mail.gmail.com>
 <20180731150115.GC1499@techadventures.net>
 <CAGM2reZ+KhsuFhOVvJzRkQO=66TosvxDW0BYAXNf8Gw8zoRQXQ@mail.gmail.com>
 <CAGM2reaniWqEJ1hArMoreyGn5M+eSYge+wYYMxTrRHth-hxzOQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reaniWqEJ1hArMoreyGn5M+eSYge+wYYMxTrRHth-hxzOQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Tue, Jul 31, 2018 at 11:23:33AM -0400, Pavel Tatashin wrote:
> Yes we free meminit when no CONFIG_MEMORY_HOTPLUG
> See here:
> http://src.illumos.org/source/xref/linux-master/include/asm-generic/vmlinux.lds.h#107

Oh, I got the point now.
Somehow I missed that we were freeing up the memory when CONFIG_MEMORY_HOTPLUG
was not in place.

So your patch makes sense to me now, sorry.

Since my patchset [1] + cleanup patch [2] remove almost all __paginginit,
leaving only pgdat_init_internals() and zone_init_internals(), I think
it would be great if you base your patch on top of that.
Or since the patchset has some cleanups already, I could add your patch
into it (as we did for the zone_to/set_nid() patch) and send a v6 with it.

What do you think?

[1] https://patchwork.kernel.org/patch/10548861/
[2] <20180731101752.GA473@techadventures.net>

Thanks
-- 
Oscar Salvador
SUSE L3
