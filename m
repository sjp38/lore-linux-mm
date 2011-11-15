Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0CAD16B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 13:19:05 -0500 (EST)
Date: Tue, 15 Nov 2011 19:19:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch v2 4/4]thp: improve order in lru list for split huge page
Message-ID: <20111115181901.GK4414@redhat.com>
References: <1321340661.22361.297.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321340661.22361.297.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>

On Tue, Nov 15, 2011 at 03:04:21PM +0800, Shaohua Li wrote:
> Put the tail subpages of an isolated hugepage under splitting in the
> lru reclaim head as they supposedly should be isolated too next.
> 
> Queues the subpages in physical order in the lru for non isolated
> hugepages under splitting. That might provide some theoretical cache
> benefit to the buddy allocator later.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Perfect all 4 patches. You've been reading my mind because I was
thinking it'd be good to merge these 4 which are strightforward
before going into 5/5.

I didn't run them yet, but I queued them too merging your new submit
and they certainly look good.

Thanks a lot,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
