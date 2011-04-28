Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A94526B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:32:16 -0400 (EDT)
Date: Thu, 28 Apr 2011 15:31:55 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/13] Swap-over-NBD without deadlocking
Message-ID: <20110428133154.GA8572@ucw.cz>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1303803414-5937-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

Hi!


> For testing swap-over-NBD, a machine was booted with 2G of RAM with a
> swapfile backed by NBD. 16*NUM_CPU processes were started that create
> anonymous memory mappings and read them linearly in a loop. The total
> size of the mappings were 4*PHYSICAL_MEMORY to use swap heavily under
> memory pressure. Without the patches, the machine locks up within
> minutes and runs to completion with them applied.
> 
> Comments?

Nice!

It  is easy to see why swapping needs these fixes, but... dirty memory
writeout is used for memory clearing, too. Are same changes neccessary
to make that safe?

(Perhaps raise 'max dirty %' for testing?)
								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
