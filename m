Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4E9836B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 10:56:20 -0500 (EST)
Date: Fri, 18 Nov 2011 09:56:15 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC]numa: improve I/O performance by optimizing numa interleave
 allocation
In-Reply-To: <1321600332.22361.309.camel@sli10-conroe>
Message-ID: <alpine.DEB.2.00.1111180954200.2242@router.home>
References: <1321600332.22361.309.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, ak@linux.intel.com, Jens Axboe <axboe@kernel.dk>, lee.schermerhorn@hp.com

On Fri, 18 Nov 2011, Shaohua Li wrote:

> So can we make both interleave fairness and continuous allocation happy?

Maybe.

> Simplily we can adjust the round robin algorithm. We switch to another node
> after several (N) allocation happens. If N isn't too big, we can still get
> fair allocation. And we get N continuous pages. I use N=8 in below patch.
> I thought 8 isn't too big for modern NUMA machine. Applications which use
> interleave are unlikely run short time, so I thought fairness still works.

People are already complaining that the 4k interleaving is too coarse.
Bioses can often interleave on a cacheline level. A smaller size balances
the load better over multiple nodes. Large sizes can result in imbalances
since f.e. a whole array may end up on one node. Maybe make it tunable
by expanding the numa_policy structure to include a size parameter?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
