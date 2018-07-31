Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB20A6B000D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:51:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c14-v6so1694973wmb.2
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:51:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18-v6sor2851364wrv.44.2018.07.31.07.51.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 07:51:26 -0700 (PDT)
Date: Tue, 31 Jul 2018 16:51:25 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Message-ID: <20180731145125.GB1499@techadventures.net>
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
 <20180731144157.GA1499@techadventures.net>
 <20180731144545.fh5syvwcecgvqul6@xakep.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180731144545.fh5syvwcecgvqul6@xakep.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Tue, Jul 31, 2018 at 10:45:45AM -0400, Pavel Tatashin wrote:
> Here the patch would look like this:
> 
> From e640b32dbd329bba5a785cc60050d5d7e1ca18ce Mon Sep 17 00:00:00 2001
> From: Pavel Tatashin <pasha.tatashin@oracle.com>
> Date: Tue, 31 Jul 2018 10:37:44 -0400
> Subject: [PATCH] mm: remove __paginginit
> 
> __paginginit is the same thing as __meminit except for platforms without
> sparsemem, there it is defined as __init.
> 
> Remove __paginginit and use __meminit. Use __ref in one single function
> that merges __meminit and __init sections: setup_usemap().
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Uhm, I am probably missing something, but with this change, the functions will not be freed up
while freeing init memory, right?

Thanks
-- 
Oscar Salvador
SUSE L3
