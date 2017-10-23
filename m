Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 846876B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 08:52:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 78so2590557wmb.15
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 05:52:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c133si3331374wmd.133.2017.10.23.05.52.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 05:52:15 -0700 (PDT)
Date: Mon, 23 Oct 2017 14:52:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171023125213.whdiev6bjxr72gow@dhcp22.suse.cz>
References: <ad310dfbfb86ef4f1f9a173cad1a030e879d572e.1508536900.git.sharath.k.bhat@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ad310dfbfb86ef4f1f9a173cad1a030e879d572e.1508536900.git.sharath.k.bhat@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Fri 20-10-17 16:32:09, Sharath Kumar Bhat wrote:
> Currently when booted with the 'movable_node' kernel command-line the user
> can not have both the functionality of 'movable_node' and at the same time
> specify more movable memory than the total size of hotpluggable memories.
> 
> This is a problem because it limits the total amount of movable memory in
> the system to the total size of hotpluggable memories and in a system the
> total size of hotpluggable memories can be very small or all hotpluggable
> memories could have been offlined. The 'movable_node' parameter was aimed
> to provide the entire memory of hotpluggable NUMA nodes to applications
> without any kernel allocations in them. The 'movable_node' option will be
> useful if those hotpluggable nodes have special memory like MCDRAM as in
> KNL which is a high bandwidth memory and the user would like to use all of
> it for applications. But in doing so the 'movable_node' command-line poses
> this limitation and does not allow the user to specify more movable memory
> in addition to the hotpluggable memories.
> 
> With this change the existing 'movablecore=' and 'kernelcore=' command-line
> parameters can be specified in addition to the 'movable_node' kernel
> parameter. This allows the user to boot the kernel with an increased amount
> of movable memory in the system and still have only movable memory in
> hotpluggable NUMA nodes.

I really detest making the already cluttered kernelcore* handling even
more so. Why cannot your MCDRAM simply announce itself as hotplugable?
Also it is not really clear to me how can you control that only your
specific memory type gets into movable zone.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
