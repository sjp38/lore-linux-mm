Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 2DAAB8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 17:23:47 -0400 (EDT)
Date: Fri, 11 May 2012 17:23:39 -0400 (EDT)
Message-Id: <20120511.172339.2007927803884694483.davem@davemloft.net>
Subject: Re: [PATCH 00/17] Swap-over-NBD without deadlocking V10
From: David Miller <davem@davemloft.net>
In-Reply-To: <20120511154540.GV11435@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
	<20120511.010445.1020972261904383892.davem@davemloft.net>
	<20120511154540.GV11435@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Fri, 11 May 2012 16:45:40 +0100

> From my point of view, the ideal would be that all the patches go
> through akpm's tree or yours but that probably will cause merge
> difficulties.
> 
> Any recommendations?

I know there will be networking side conflicts very soon, it's not a
matter of 'if' but 'when'.

But the trick is that I bet the 'mm' and 'slab' folks are in a similar
situation.

In any event I'm more than happy to take it all in my tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
