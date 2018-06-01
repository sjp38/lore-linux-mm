Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE1C96B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 07:25:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o15-v6so634477wmf.1
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 04:25:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o10-v6sor19705673wra.54.2018.06.01.04.25.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Jun 2018 04:25:31 -0700 (PDT)
Date: Fri, 1 Jun 2018 13:25:30 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 0/3] Small cleanup for hotplugmem
Message-ID: <20180601112530.GA21638@techadventures.net>
References: <20180528081352.GA14293@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180528081352.GA14293@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org

On Mon, May 28, 2018 at 10:13:52AM +0200, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Hi guys,
> 
> I wanted to give it a chance a do a small cleanup in the hotplug memory code.
> A lot more could be done, but I wanted to start somewhere.
> I tried to unify/remove duplicated code.
> 
> Here I have just done three things
> 
> 1) add_memory_resource() had code to allocate a node in case it was offline.
>    Since try_online_node already does that, I just made add_memory_resource() to
>    use that function.
>    This is better explained in patch 1/3.
> 
> 2) register_mem_sect_under_node() will be called only from link_mem_sections
> 
> 3) Get rid of link_mem_sections() in favour of walk_memory_range with a callback to
>    register_mem_sect_under_node()
> 
> I am posting this as a RFC because I could not see that these patches break anything,
> but expert eyes might see something that I am missing here.
> 
> Oscar Salvador (3):
>   mm/memory_hotplug: Make add_memory_resource use __try_online_node
>   mm/memory_hotplug: Call register_mem_sect_under_node
>   mm/memory_hotplug: Get rid of link_mem_sections
> 
>  drivers/base/memory.c |   2 -
>  drivers/base/node.c   |  47 +++++------------------
>  include/linux/node.h  |  21 +++++------
>  mm/memory_hotplug.c   | 101 ++++++++++++++++++++++++++------------------------
>  4 files changed, 71 insertions(+), 100 deletions(-)
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> 
> -- 
> 2.13.6
> 

Since there have not been any concerns so far, I will send v1 of this patchset.

Thanks

Oscar Salvador
