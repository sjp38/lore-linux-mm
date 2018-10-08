Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 246816B0005
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 09:56:33 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id z11-v6so5941301wma.4
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 06:56:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4-v6sor5527133wru.48.2018.10.08.06.56.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 06:56:31 -0700 (PDT)
Date: Mon, 8 Oct 2018 15:56:29 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH v3 0/5] Do not touch pages/zones during hot-remove
 path
Message-ID: <20181008135629.GA10959@techadventures.net>
References: <20181002150029.23461-1-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002150029.23461-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com

On Tue, Oct 02, 2018 at 05:00:24PM +0200, Oscar Salvador wrote:
> Oscar Salvador (5):
>   mm/memory_hotplug: Add nid parameter to arch_remove_memory
>   mm/memory_hotplug: Create add/del_device_memory functions
>   mm/memory_hotplug: Check for IORESOURCE_SYSRAM in
>     release_mem_region_adjustable
>   mm/memory_hotplug: Move zone/pages handling to offline stage
>   mm/memory-hotplug: Rework unregister_mem_sect_under_nodes
> 
>  arch/ia64/mm/init.c            |   6 +-
>  arch/powerpc/mm/mem.c          |  13 +---
>  arch/s390/mm/init.c            |   2 +-
>  arch/sh/mm/init.c              |   6 +-
>  arch/x86/mm/init_32.c          |   6 +-
>  arch/x86/mm/init_64.c          |  10 +--
>  drivers/base/memory.c          |   9 ++-
>  drivers/base/node.c            |  38 ++--------
>  include/linux/memory.h         |   2 +-
>  include/linux/memory_hotplug.h |  17 +++--
>  include/linux/node.h           |   7 +-
>  kernel/memremap.c              |  50 +++++---------
>  kernel/resource.c              |  15 ++++
>  mm/memory_hotplug.c            | 153 ++++++++++++++++++++++++++---------------
>  mm/sparse.c                    |   4 +-
>  15 files changed, 169 insertions(+), 169 deletions(-)
> 
> -- 
> 2.13.6

If there are no further comments, I will send this as a patchset without RFC
later this week.
Since [1] already landed in mmotm, I will pull out the dependency for [2], and
change both devm/HMM code.

[1] https://patchwork.kernel.org/cover/10617699/
[2] https://patchwork.kernel.org/cover/10613425/

Thanks
-- 
Oscar Salvador
SUSE L3
