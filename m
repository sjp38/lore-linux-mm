Date: Fri, 13 Jul 2007 09:58:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: -mm merge plans -- anti-fragmentation
In-Reply-To: <469751E9.7060904@shadowen.org>
Message-ID: <Pine.LNX.4.64.0707130951260.21777@schroedinger.engr.sgi.com>
References: <20070710102043.GA20303@skynet.ie> <20070712122925.192a6601.akpm@linux-foundation.org>
 <469751E9.7060904@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, kenchen@google.com, jschopp@austin.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007, Andy Whitcroft wrote:

> I would like to see ZONE_MOVABLE and lumpy considered for 2.6.23.

Agree. ZONE_MOVABLE is a way to guarantee a reclaimable memory area which 
is beneficial for the antifrag approach (and it will help to get more 
reliable allocations of higher order pages in SLUB if one chooses to 
use these...).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
