Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7485B6B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 03:36:52 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id x23so21794682lfi.0
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 00:36:52 -0700 (PDT)
Received: from mail-lf0-f66.google.com (mail-lf0-f66.google.com. [209.85.215.66])
        by mx.google.com with ESMTPS id z67si649190lfa.13.2016.10.21.00.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Oct 2016 00:36:50 -0700 (PDT)
Received: by mail-lf0-f66.google.com with SMTP id x23so4153590lfi.1
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 00:36:50 -0700 (PDT)
Date: Fri, 21 Oct 2016 09:36:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] fs/proc/meminfo: introduce Unaccounted statistic
Message-ID: <20161021073648.GG6045@dhcp22.suse.cz>
References: <20161020121149.9935-1-vbabka@suse.cz>
 <20161020133358.GN14609@dhcp22.suse.cz>
 <20161020225929.GP23194@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161020225929.GP23194@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On Fri 21-10-16 09:59:29, Dave Chinner wrote:
> On Thu, Oct 20, 2016 at 03:33:58PM +0200, Michal Hocko wrote:
> > On Thu 20-10-16 14:11:49, Vlastimil Babka wrote:
> > [...]
> > > Hi, I'm wondering if people would find this useful. If you think it is, and
> > > to not make performance worse, I could also make sure in proper submission
> > > that values are not read via global_page_state() multiple times etc...
> > 
> > I definitely find this information useful and hate to do the math all
> > the time but on the other hand this is quite fragile and I can imagine
> > we can easily forget to add something there and provide a misleading
> > information to the userspace. So I would be worried with a long term
> > maintainability of this.
> 
> This will result in valid memory usage by subsystems like the XFS
> buffer cache being reported as "unaccounted".

I would argue that the file is more intended for developers than regular
users. Most of those counters simply require a deep knowledge of the MM
subsystem to interpret them correctly (yeah we have seen many reports
that the free memory is too low but we always managed to explain...).

So to me this is more a convenience thing for developers than anything
else. But my worry about maintainability still stands. People who are
adding new counters might easily forget to update this part, so I am not
actually sure it is a good idea long term. Getting a misleading data is
worse than pushing developers to do the math and scratch their heads
about what should be included IMHO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
