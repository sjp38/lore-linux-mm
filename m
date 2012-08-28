Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C79166B0068
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 14:06:03 -0400 (EDT)
Date: Tue, 28 Aug 2012 15:05:39 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v9 3/5] virtio_balloon: introduce migration primitives to
 balloon pages
Message-ID: <20120828180539.GB1750@t510.redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
 <a1ceca79d95bc7de2a6b62a2e565b95286dbdf75.1345869378.git.aquini@redhat.com>
 <20120826074244.GC19551@redhat.com>
 <20120827194713.GA6517@t510.redhat.com>
 <20120828155410.GE2903@redhat.com>
 <20120828173713.GA1750@t510.redhat.com>
 <20120828175716.GA4595@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120828175716.GA4595@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Aug 28, 2012 at 08:57:16PM +0300, Michael S. Tsirkin wrote:
> Sorry I do not understand what you are saying here. So find
> a different locking strategy.
> 
> For example something like:
> 
>          wait_event(vb->config_change,
> 		({ 
> 		   lock
> 		   if (target <= (num_pages - isolated_pages))
> 			   leak balloon
> 		   cond = target <= (num_pages - isolated_pages));
> 		   unlock;
> 		   cond;
> 		})
> 		)
> 
> seems to have no issues?

Ok, I see what you mean. I'll change it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
