Date: Thu, 11 Apr 2002 16:47:10 -0500
From: Art Haas <ahaas@neosoft.com>
Subject: Re: [PATCH] radix-tree pagecache for 2.4.19-pre5-ac3
Message-ID: <20020411214710.GA8947@debian>
References: <20020407164439.GA5662@debian> <20020410205947.GG21206@holomorphy.com> <20020410220842.GA14573@debian> <20020411183959.GE23767@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020411183959.GE23767@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2002 at 11:39:59AM -0700, William Lee Irwin III wrote:
> On Wed, Apr 10, 2002 at 05:08:42PM -0500, Art Haas wrote:
> > Sorry to hear that. I haven't had any trouble on my machine, but
> > it's an old machine (200MHz Pentium), and I run desktop stuff, so
> > the load the patch is exposed to on this machine must not be enough
> > to trip things up. 
> > I think you've dropped an "=". Maybe this is the cause of the
> > other trouble you were seeing?
> 
> No, it appears to be because all pagecache locking was removed from vmscan.c
> Acquisitions and releases of pagecache_lock must be converted to the
> analogous acquisitions and releases of the mapping->page_lock, with proper
> movement of the points it's acquired and released for the per-mapping lock.
> Testing with Cerberus on SMP machines helps find these issues.
> 
> The following hunks might need a bit more critical examination.
> 
> [ ... snip part of patch ... ]

I'll take any and all blame for the changes in vmscan.c that cause
problems.  I'm running on a machine with a single processor, and don't
have access to an SMP machine to test things on, so problems
arising on such machines would likely slip past me. :-(

I did go download Cerberus today, and started looking at what it
does, how to run it, etc.

I'll go dig into vmscan.c again. Thank you for your continued
efforts on reviewing and fixing the radix-tree patch.

-- 
They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety.
 -- Benjamin Franklin, Historical Review of Pennsylvania, 1759
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
