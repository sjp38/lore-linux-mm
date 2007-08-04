From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Apply memory policies to top two highest zones when highest zone is ZONE_MOVABLE
Date: Sat, 4 Aug 2007 10:51:13 +0200
References: <20070802172118.GD23133@skynet.ie> <200708040002.18167.ak@suse.de> <20070804002354.GA2841@skynet.ie>
In-Reply-To: <20070804002354.GA2841@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708041051.14324.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> It only affects hot paths in the NUMA case so non-NUMA users will not care.

For x86-64 most distribution kernels are NUMA these days.

> For NUMA users,  I have posted patches that eliminate multiple zonelists
> altogether which will reduce cache footprint (something like 7K per node on
> x86_64)

How do you get to 7k? We got worst case 3 zones node (normally less);
that's three pointers per GFP level.

> and make things like MPOL_BIND behave in a consistent manner. That 
> would cost on CPU but save on cache which would (hopefully) result in a net
> gain in most cases.

That might be a good tradeoff, but without seeing the patch 
the 7k number sounds very dubious.

> I would like to go with this patch for now just for policies but for
> 2.6.23, we could leave it as "policies only apply to ZONE_MOVABLE when it
> is used" if you really insisted on it. It's less than ideal though for
> sure.

Or disable ZONE_MOVABLE. It seems to be clearly not well thought
out well yet. Perhaps make it dependent on !CONFIG_NUMA.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
