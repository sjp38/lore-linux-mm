Date: Thu, 7 Jun 2007 19:47:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
In-Reply-To: <20070607180108.0eeca877.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com>
References: <20070607011701.GA14211@linux-sh.org>
 <20070607180108.0eeca877.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007, Andrew Morton wrote:

> Well I took silence as assent.

Well, grudgingly. How far are we willing to go to support these asymmetric 
setups? The NUMA code initially was designed for mostly symmetric systems 
with roughly the same amount of memory on each node. The farther we go 
from this the more options we will have to add special casing to deal with 
these imbalances.

With memoryless nodes we already have one issue that will ripple through 
the kernel likely requiring numerous modifications and special casing. 
Then we now have the ZONE_DMA issues reording the zonelists. Now we will 
support systems with 1MB size nodes? We will need to modify the slab 
allocators to only allocate on special processors?


 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
