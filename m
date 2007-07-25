Date: Tue, 24 Jul 2007 22:05:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
In-Reply-To: <46A6D5E1.70407@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0707242200380.4070@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <46A6D5E1.70407@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007, Nick Piggin wrote:

> > Doesnt this mean that ZONE_MOVABLE is incompatible with CONFIG_NUMA?
> 
> I guess it has similar problems as ZONE_HIGHMEM etc. I think the
> zoned allocator and NUMA was there first, so it might be more
> correct to say that mempolicies are incompatible with them :)

Highmem is only used on i386 NUMA and works fine on NUMAQ. The current 
zone types are carefully fitted to existing NUMA systems.
 
> But I thought you had plans to fix mempolicies to do zones better?

No sure where you got that from. I repeatedly suggested that more zones be 
removed because of this one and other issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
