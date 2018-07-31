Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id EEA966B0269
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:45:52 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id b7-v6so13303979qtp.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:45:52 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f129-v6si2122699qkd.136.2018.07.31.07.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 07:45:52 -0700 (PDT)
Date: Tue, 31 Jul 2018 10:45:45 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Message-ID: <20180731144545.fh5syvwcecgvqul6@xakep.localdomain>
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
 <20180731144157.GA1499@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180731144157.GA1499@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On 18-07-31 16:41:57, Oscar Salvador wrote:
> On Tue, Jul 31, 2018 at 08:49:11AM -0400, Pavel Tatashin wrote:
> > Hi Oscar,
> > 
> > Have you looked into replacing __paginginit via __meminit ? What is
> > the reason to keep both?
> Hi Pavel,
> 
> Actually, thinking a bit more about this, it might make sense to remove
> __paginginit altogether and keep only __meminit.
> Looking at the original commit, I think that it was put as a way to abstract it.
> 
> After the patchset [1] has been applied, only two functions marked as __paginginit
> remain, so it will be less hassle to replace that with __meminit.
> 
> I will send a v2 tomorrow to be applied on top of [1].
> 
> [1] https://patchwork.kernel.org/patch/10548861/
> 
> Thanks
> -- 
> Oscar Salvador
> SUSE L3
> 

Here the patch would look like this:
