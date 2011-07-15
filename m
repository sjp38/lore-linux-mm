Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AEED46B004A
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 11:27:45 -0400 (EDT)
Date: Fri, 15 Jul 2011 11:27:38 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/14] Swap-over-NBD without deadlocking v5
Message-ID: <20110715152738.GA2276@infradead.org>
References: <1308575540-25219-1-git-send-email-mgorman@suse.de>
 <20110706165146.be7ab61b.akpm@linux-foundation.org>
 <20110707094737.GG15285@suse.de>
 <20110707125831.GA15412@infradead.org>
 <20110715141021.GZ7529@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110715141021.GZ7529@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Jul 15, 2011 at 03:10:21PM +0100, Mel Gorman wrote:
> Any objection to the swap-over-NBD stuff going ahead to get part of the
> complexity out of the way?

Sure, that's what I was advocating for.  The filesystem interfaces in
the current swap over nbd patches on the other hand are complete crap
and need to be redone, but we've already discussed that a lot of times.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
