Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E23676B0007
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 02:15:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id z11-v6so1941344wma.4
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 23:15:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t124-v6sor54048wmf.84.2018.08.15.23.15.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Aug 2018 23:15:53 -0700 (PDT)
Date: Thu, 16 Aug 2018 08:15:52 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 3/4] mm/memory_hotplug: Make
 register_mem_sect_under_node a cb of walk_memory_range
Message-ID: <20180816061552.GA15875@techadventures.net>
References: <20180622111839.10071-1-osalvador@techadventures.net>
 <20180622111839.10071-4-osalvador@techadventures.net>
 <20180815152135.4f755e25c865af2054cfaf02@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815152135.4f755e25c865af2054cfaf02@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, vbabka@suse.cz, pavel.tatashin@microsoft.com, Jonathan.Cameron@huawei.com, arbab@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 15, 2018 at 03:21:35PM -0700, Andrew Morton wrote:
> On Fri, 22 Jun 2018 13:18:38 +0200 osalvador@techadventures.net wrote:
> 
> > From: Oscar Salvador <osalvador@suse.de>
> > 
> > link_mem_sections() and walk_memory_range() share most of the code,
> > so we can use convert link_mem_sections() into a dummy function that calls
> > walk_memory_range() with a callback to register_mem_sect_under_node().
> > 
> > This patch converts register_mem_sect_under_node() in order to
> > match a walk_memory_range's callback, getting rid of the
> > check_nid argument and checking instead if the system is still
> > boothing, since we only have to check for the nid if the system
> > is in such state.
> > 
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> > Suggested-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> 
> We have two tested-by's bu no reviewers or ackers?
 
Pavel, would you be so kind to review this patch?
It is the only patch from the patchset which did not get a 
review.

Thanks!
-- 
Oscar Salvador
SUSE L3
