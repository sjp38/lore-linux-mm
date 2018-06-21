Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3354B6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 04:33:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j8-v6so1729062wrh.18
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 01:33:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w27-v6si2526722edl.174.2018.06.21.01.33.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jun 2018 01:33:00 -0700 (PDT)
Date: Thu, 21 Jun 2018 10:32:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/4] Small cleanup for memoryhotplug
Message-ID: <20180621083258.GF10465@dhcp22.suse.cz>
References: <20180601125321.30652-1-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180601125321.30652-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, vbabka@suse.cz, pasha.tatashin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>, Reza Arbab <arbab@linux.vnet.ibm.com>

[Cc Reza Arbab - I remember he was able to hit some bugs in memblock
registration code when I was reworking that area previously]

On Fri 01-06-18 14:53:17, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> 
> Hi,
> 
> I wanted to give it a try and do a small cleanup in the memhotplug's code.
> A lot more could be done, but I wanted to start somewhere.
> I tried to unify/remove duplicated code.
> 
> The following is what this patchset does:
> 
> 1) add_memory_resource() has code to allocate a node in case it was offline.
>    Since try_online_node has some code for that as well, I just made add_memory_resource() to
>    use that so we can remove duplicated code..
>    This is better explained in patch 1/4.
> 
> 2) register_mem_sect_under_node() will be called only from link_mem_sections()
> 
> 3) Get rid of link_mem_sections() in favour of walk_memory_range() with a callback to
>    register_mem_sect_under_node()
> 
> 4) Drop unnecessary checks from register_mem_sect_under_node()
> 
> 
> I have done some tests and I could not see anything broken because of 
> this patchset.
> 
> Oscar Salvador (4):
>   mm/memory_hotplug: Make add_memory_resource use __try_online_node
>   mm/memory_hotplug: Call register_mem_sect_under_node
>   mm/memory_hotplug: Get rid of link_mem_sections
>   mm/memory_hotplug: Drop unnecessary checks from
>     register_mem_sect_under_node
> 
>  drivers/base/memory.c |   2 -
>  drivers/base/node.c   |  52 +++++---------------------
>  include/linux/node.h  |  21 +++++------
>  mm/memory_hotplug.c   | 101 ++++++++++++++++++++++++++------------------------
>  4 files changed, 71 insertions(+), 105 deletions(-)
> 
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
