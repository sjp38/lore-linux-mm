Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9CF66B026C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:03:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q26-v6so879835wmc.0
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 07:03:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6-v6sor1205117wmh.17.2018.07.19.07.03.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 07:03:29 -0700 (PDT)
Date: Thu, 19 Jul 2018 16:03:27 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 3/5] mm/page_alloc: Optimize free_area_init_core
Message-ID: <20180719140327.GB10988@techadventures.net>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-4-osalvador@techadventures.net>
 <20180719134417.GC7193@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719134417.GC7193@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu, Jul 19, 2018 at 03:44:17PM +0200, Michal Hocko wrote:
> On Thu 19-07-18 15:27:38, osalvador@techadventures.net wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> > 
> > In free_area_init_core we calculate the amount of managed pages
> > we are left with, by substracting the memmap pages and the pages
> > reserved for dma.
> > With the values left, we also account the total of kernel pages and
> > the total of pages.
> > 
> > Since memmap pages are calculated from zone->spanned_pages,
> > let us only do these calculcations whenever zone->spanned_pages is greather
> > than 0.
> 
> But why do we care? How do we test this? In other words, why is this
> worth merging?
 
Uhm, unless the values are going to be updated, why do we want to go through all
comparasions/checks?
I thought it was a nice thing to have the chance to skip that block unless we are going to
update the counters.

Again, if you think this only adds complexity and no good, I can drop it.

Thanks
-- 
Oscar Salvador
SUSE L3
