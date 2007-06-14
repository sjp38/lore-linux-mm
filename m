Date: Thu, 14 Jun 2007 08:57:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
In-Reply-To: <1181836247.5410.85.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706140852150.29460@schroedinger.engr.sgi.com>
References: <20070612032055.GQ3798@us.ibm.com>  <1181660782.5592.50.camel@localhost>
 <20070612172858.GV3798@us.ibm.com>  <1181674081.5592.91.camel@localhost>
 <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
 <1181677473.5592.149.camel@localhost>  <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
  <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
 <20070613175802.GP3798@us.ibm.com> <1181758874.6148.73.camel@localhost>
 <Pine.LNX.4.64.0706131550520.32399@schroedinger.engr.sgi.com>
 <1181836247.5410.85.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, Lee Schermerhorn wrote:

> The point of all this is that, as you've pointed out, the original NUMA
> and memory policy designs assumed a fairly symmetric system
> configuration with all nodes populated with [similar amounts?] of
> roughly equivalent memory.  That probably describes a majority of NUMA
> systems, so the system should handle this well, as a default.  We still
> need to be able to handle the less symmetric configs--with boot
> parameters, sysctls, cpusets, ...--that specify non-default behavior,
> and cause the generic code to do the right thing.  Certainly, the
> generic code can't "fall over and die" in the presence of memoryless
> nodes or other "interesting" configurations.

The hugepage distribution issues have to be handled by the hugepage code. 
There is no point in adding inconsistencies in the definition of a 
memoryless node to satisfy hugepage distribution issues on one platform.

The memoryless node handling addresses one particular assymmetry: No 
memory vs. some memory. The fine grained stuff that relates to particular 
page types (like I do not want hugepages on my DMA node...) have to be 
handled by the management of that particular page type. Here we need some 
control over huge page distribution. There is already another case where 
we may need to control the nodes that slab uses for its allocations. The 
slab node restrictions have to be handled by the slab code. Same thing for 
hugepages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
