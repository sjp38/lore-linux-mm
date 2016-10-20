Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE186B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 18:59:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h24so37166605pfh.0
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 15:59:33 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id h5si39132295pal.201.2016.10.20.15.59.31
        for <linux-mm@kvack.org>;
        Thu, 20 Oct 2016 15:59:32 -0700 (PDT)
Date: Fri, 21 Oct 2016 09:59:29 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC] fs/proc/meminfo: introduce Unaccounted statistic
Message-ID: <20161020225929.GP23194@dastard>
References: <20161020121149.9935-1-vbabka@suse.cz>
 <20161020133358.GN14609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161020133358.GN14609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On Thu, Oct 20, 2016 at 03:33:58PM +0200, Michal Hocko wrote:
> On Thu 20-10-16 14:11:49, Vlastimil Babka wrote:
> [...]
> > Hi, I'm wondering if people would find this useful. If you think it is, and
> > to not make performance worse, I could also make sure in proper submission
> > that values are not read via global_page_state() multiple times etc...
> 
> I definitely find this information useful and hate to do the math all
> the time but on the other hand this is quite fragile and I can imagine
> we can easily forget to add something there and provide a misleading
> information to the userspace. So I would be worried with a long term
> maintainability of this.

This will result in valid memory usage by subsystems like the XFS
buffer cache being reported as "unaccounted". Given this cache
(whose size is shrinker controlled) can grow to gigabytes in size
under various metadata intensive workloads, there's every chance
that such reporting will make users incorrectly think they have a
massive memory leak....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
