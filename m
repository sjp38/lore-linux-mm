Message-ID: <47C7C972.9010408@cs.helsinki.fi>
Date: Fri, 29 Feb 2008 10:59:30 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 3/8] slub: Update statistics handling for variable order
 slabs
References: <20080229044803.482012397@sgi.com> <20080229044818.999367120@sgi.com>
In-Reply-To: <20080229044818.999367120@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Change the statistics to consider that slabs of the same slabcache
> can have different number of objects in them since they may be of
> different order.
> 
> Provide a new sysfs field
> 
> 	total_objects
> 
> which shows the total objects that the allocated slabs of a slabcache
> could hold.
> 
> Update the description of the objects field in the kmem_cache structure.
> Its role is now to be the limit of the maximum number of objects per slab
> if a slab is allocated with the largest possible order.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
