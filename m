Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68FA96B0005
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 17:33:38 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id b83-v6so3903771itg.1
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:33:38 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id g14-v6si2436498itg.27.2018.07.31.14.33.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 14:33:36 -0700 (PDT)
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
 <20180731144157.GA1499@techadventures.net>
 <20180731144545.fh5syvwcecgvqul6@xakep.localdomain>
 <20180731145125.GB1499@techadventures.net>
 <CAGM2reZSZHdWECr8-7pj6j=CtjWVF2oKC9SwHhMuOsDkigdzgA@mail.gmail.com>
 <20180731150115.GC1499@techadventures.net>
 <CAGM2reZ+KhsuFhOVvJzRkQO=66TosvxDW0BYAXNf8Gw8zoRQXQ@mail.gmail.com>
 <CAGM2reaniWqEJ1hArMoreyGn5M+eSYge+wYYMxTrRHth-hxzOQ@mail.gmail.com>
 <20180731205003.GA3277@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <34d9fff4-cc29-8c6e-42c9-48c4467b6a74@oracle.com>
Date: Tue, 31 Jul 2018 17:33:27 -0400
MIME-Version: 1.0
In-Reply-To: <20180731205003.GA3277@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de



On 07/31/2018 04:50 PM, Oscar Salvador wrote:
> On Tue, Jul 31, 2018 at 11:23:33AM -0400, Pavel Tatashin wrote:
>> Yes we free meminit when no CONFIG_MEMORY_HOTPLUG
>> See here:
>> http://src.illumos.org/source/xref/linux-master/include/asm-generic/vmlinux.lds.h#107
> 
> Oh, I got the point now.
> Somehow I missed that we were freeing up the memory when CONFIG_MEMORY_HOTPLUG
> was not in place.
> 
> So your patch makes sense to me now, sorry.
> 
> Since my patchset [1] + cleanup patch [2] remove almost all __paginginit,
> leaving only pgdat_init_internals() and zone_init_internals(), I think
> it would be great if you base your patch on top of that.
> Or since the patchset has some cleanups already, I could add your patch
> into it (as we did for the zone_to/set_nid() patch) and send a v6 with it.
> 
> What do you think?

Sure, please go ahead include it in v6. Let me know if you need any help. Thank you for this work, I really like how this improves hotplug/memory-init code.

Pavel

> 
> [1] https://patchwork.kernel.org/patch/10548861/
> [2] <20180731101752.GA473@techadventures.net>
> 
> Thanks
> 
