Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <29495f1d0705161259p70a1e499tb831889fd2bcebcb@mail.gmail.com>
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
	 <1178728661.5047.64.camel@localhost>
	 <29495f1d0705161259p70a1e499tb831889fd2bcebcb@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 16 May 2007 16:32:06 -0400
Message-Id: <1179347526.5867.44.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>, andyw@uk.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-16 at 12:59 -0700, Nish Aravamudan wrote:


> 
> This completely breaks hugepage allocation on 4-node x86_64 box I have
> here. Each node has <4GB of memory, so all memory is ZONE_DMA and
> ZONE_DMA32. gfp_zone(GFP_HIGHUSER) is ZONE_NORMAL, though. So all
> nodes are not populated by the default initialization to an empty
> nodemask.
> 
> Thanks to Andy Whitcroft for helping me debug this.
> 
> I'm not sure how to fix this -- but I ran into while trying to base my
> sysfs hugepage allocation patches on top of yours.
> 
> Thoughts?

I'm looking at this now on a 2 socket x86_64 blade with 2GB/node.  Just
noticed that I'm not seeing any nodes in the node_populated_map.
Haven't figured out how to fix it yet.  Stand by...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
