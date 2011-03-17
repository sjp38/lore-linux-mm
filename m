Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6B13F8D0046
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 12:44:04 -0400 (EDT)
Date: Thu, 17 Mar 2011 12:43:54 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110317164354.GA26093@infradead.org>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <AANLkTimeH-hFiqtALfzyyrHiLz52qQj0gCisaJ-taCdq@mail.gmail.com>
 <20110317155139.GA16195@infradead.org>
 <AANLkTikxEQfzFOrc1Kyu+eC8EnTpDfKYHNswLu+0AtZS@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikxEQfzFOrc1Kyu+eC8EnTpDfKYHNswLu+0AtZS@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Mar 17, 2011 at 09:24:28AM -0700, Curt Wohlgemuth wrote:
> Which is indeed part of the patchset I referred to above ("[RFC]
> [PATCH 0/6] Provide cgroup isolation for buffered writes",
> https://lkml.org/lkml/2011/3/8/332 ).

So what about letting us fix normal writeback first and then later look
into cgroups properly.  And to do it properly we'll need to implement
something similar to the I/O less balance dirty pages - be that targeted
writeback from the flusher thread including proper tagging of pages,
or be that writeback from balance_dirty_pages in a why that we keep
multiple processes from writing at the same time.  Although I'd prefer
something that keeps the CG case as close as possible to the normal
code, right now we already have a huge mess with memcg and it's own
handrolled version of direct reclaim which is an even worse stack
hog than the already overly painfull "normal" direct reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
