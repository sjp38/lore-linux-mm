Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C8BAB6B01B1
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 22:38:58 -0400 (EDT)
Date: Tue, 23 Mar 2010 19:38:37 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
	pressure
Message-ID: <20100324023837.GH4359@suse.de>
References: <20100315130935.f8b0a2d7.akpm@linux-foundation.org> <20100322235053.GD9590@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100322235053.GD9590@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 22, 2010 at 11:50:54PM +0000, Mel Gorman wrote:
> 2. TTY using high order allocations more frequently
> 	fix title: ttyfix
> 	fixed in mainline? yes, in 2.6.34-rc2
> 	affects: 2.6.31 to 2.6.34-rc1
> 
> 	2.6.31 made pty's use the same buffering logic as tty.	Unfortunately,
> 	it was also allowed to make high-order GFP_ATOMIC allocations. This
> 	triggers some high-order reclaim and introduces some stalls. It's
> 	fixed in 2.6.34-rc2 but needs back-porting.

It will go to the other stable kernels for their next round of releases
now that it is in Linus's tree.

> Next Steps
> ==========
> 
> Jens, any problems with me backporting the async/sync fixes from 2.6.31 to
> 2.6.30.x (assuming that is still maintained, Greg?)?

No, .30 is no longer being maintained.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
