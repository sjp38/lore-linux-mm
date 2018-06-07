Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFAF36B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 09:32:29 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j8-v6so5398829wrh.18
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 06:32:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor26583200wry.4.2018.06.07.06.32.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 06:32:27 -0700 (PDT)
Date: Thu, 7 Jun 2018 15:32:25 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 0/4] Small cleanup for memoryhotplug
Message-ID: <20180607133225.GA11024@techadventures.net>
References: <20180601125321.30652-1-osalvador@techadventures.net>
 <20180607114245.00001068@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180607114245.00001068@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu, Jun 07, 2018 at 11:42:45AM +0100, Jonathan Cameron wrote:
> On Fri, 1 Jun 2018 14:53:17 +0200
> <osalvador@techadventures.net> wrote:
> 
> > From: Oscar Salvador <osalvador@suse.de>
> > 
> > 
> > Hi,
> > 
> > I wanted to give it a try and do a small cleanup in the memhotplug's code.
> > A lot more could be done, but I wanted to start somewhere.
> > I tried to unify/remove duplicated code.
> > 
> > The following is what this patchset does:
> > 
> > 1) add_memory_resource() has code to allocate a node in case it was offline.
> >    Since try_online_node has some code for that as well, I just made add_memory_resource() to
> >    use that so we can remove duplicated code..
> >    This is better explained in patch 1/4.
> > 
> > 2) register_mem_sect_under_node() will be called only from link_mem_sections()
> > 
> > 3) Get rid of link_mem_sections() in favour of walk_memory_range() with a callback to
> >    register_mem_sect_under_node()
> > 
> > 4) Drop unnecessary checks from register_mem_sect_under_node()
> > 
> > 
> > I have done some tests and I could not see anything broken because of 
> > this patchset.
> Works fine with the patch set for arm64 I'm intermittently working on.
> Or at least I don't need to make any additional changes on top of what I currently
> have!
> 
> Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Thanks for having tested it Jonathan ;-)!

> 
> Thanks,
> 
> Jonathan
> > 
> > Oscar Salvador (4):
> >   mm/memory_hotplug: Make add_memory_resource use __try_online_node
> >   mm/memory_hotplug: Call register_mem_sect_under_node
> >   mm/memory_hotplug: Get rid of link_mem_sections
> >   mm/memory_hotplug: Drop unnecessary checks from
> >     register_mem_sect_under_node
> > 
> >  drivers/base/memory.c |   2 -
> >  drivers/base/node.c   |  52 +++++---------------------
> >  include/linux/node.h  |  21 +++++------
> >  mm/memory_hotplug.c   | 101 ++++++++++++++++++++++++++------------------------
> >  4 files changed, 71 insertions(+), 105 deletions(-)
> > 
> 
> 
