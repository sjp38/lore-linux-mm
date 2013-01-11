Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 4E07A6B006C
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 04:30:52 -0500 (EST)
Date: Fri, 11 Jan 2013 09:30:49 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130111093049.GL13304@suse.de>
References: <20130110194212.GJ13304@suse.de>
 <20130111005105.GA15023@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130111005105.GA15023@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Jan 11, 2013 at 12:51:05AM +0000, Eric Wong wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> > mm: compaction: Partially revert capture of suitable high-order page
> 
> <snip>
>  
> > Reported-by: Eric Wong <normalperson@yhbt.net>
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Thanks, my original use case and test works great after several hours!
> 
> Tested-by: Eric Wong <normalperson@yhbt.net>
> 

Thanks very much Eric. I've resent the patch to Andrew so it should make
its way to mainline. It'll fail to apply to 3.7-stable but I should get
a notification from Greg when that happens and fix it up.

> Unfortunately, I also hit a new bug in 3.8 (not in 3.7.x).  based on Eric
> Dumazet's observations, sk_stream_wait_memory may be to blame.
> Fortunately this is easier to reproduce (I've cc-ed participants
> on this thread already): <20130111004915.GA15415@dcvr.yhbt.net>

It looks like the relevant fix for this has already been written by Eric
Dumazet and picked up by David Miller.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
