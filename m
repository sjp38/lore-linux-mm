Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5B26B0031
	for <linux-mm@kvack.org>; Sun,  9 Feb 2014 20:09:36 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so5533002pbb.6
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 17:09:36 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id d4si13304745pao.186.2014.02.09.17.09.30
        for <linux-mm@kvack.org>;
        Sun, 09 Feb 2014 17:09:35 -0800 (PST)
Date: Mon, 10 Feb 2014 10:09:36 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140210010936.GA12574@lge.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
 <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.02.1402080154140.9668@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402080154140.9668@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Sat, Feb 08, 2014 at 01:57:39AM -0800, David Rientjes wrote:
> On Fri, 7 Feb 2014, Joonsoo Kim wrote:
> 
> > > It seems like a better approach would be to do this when a node is brought 
> > > online and determine the fallback node based not on the zonelists as you 
> > > do here but rather on locality (such as through a SLIT if provided, see 
> > > node_distance()).
> > 
> > Hmm...
> > I guess that zonelist is base on locality. Zonelist is generated using
> > node_distance(), so I think that it reflects locality. But, I'm not expert
> > on NUMA, so please let me know what I am missing here :)
> > 
> 
> The zonelist is, yes, but I'm talking about memoryless and cpuless nodes.  
> If your solution is going to become the generic kernel API that determines 
> what node has local memory for a particular node, then it will have to 
> support all definitions of node.  That includes nodes that consist solely 
> of I/O, chipsets, networking, or storage devices.  These nodes may not 
> have memory or cpus, so doing it as part of onlining cpus isn't going to 
> be generic enough.  You want a node_to_mem_node() API for all possible 
> node types (the possible node types listed above are straight from the 
> ACPI spec).  For 99% of people, node_to_mem_node(X) is always going to be 
> X and we can optimize for that, but any solution that relies on cpu online 
> is probably shortsighted right now.
> 
> I think it would be much better to do this as a part of setting a node to 
> be online.

Okay. I got your point.
I will change it to rely on node online if this patch is really needed.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
