Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id D4D796B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:50:02 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id w8so5702211qac.36
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:50:02 -0800 (PST)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id e9si4063297qas.29.2014.02.07.09.50.00
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 09:50:01 -0800 (PST)
Date: Fri, 7 Feb 2014 11:49:57 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 3/3] slub: fallback to get_numa_mem() node if we want
 to allocate on memoryless node
In-Reply-To: <20140207054119.GA28952@lge.com>
Message-ID: <alpine.DEB.2.10.1402071147390.15168@nuc>
References: <20140206020757.GC5433@linux.vnet.ibm.com> <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com> <1391674026-20092-3-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.10.1402061127001.5348@nuc> <20140207054119.GA28952@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, 7 Feb 2014, Joonsoo Kim wrote:

> > This check wouild need to be something that checks for other contigencies
> > in the page allocator as well. A simple solution would be to actually run
> > a GFP_THIS_NODE alloc to see if you can grab a page from the proper node.
> > If that fails then fallback. See how fallback_alloc() does it in slab.
> >
>
> Hello, Christoph.
>
> This !node_present_pages() ensure that allocation on this node cannot succeed.
> So we can directly use numa_mem_id() here.

Yes of course we can use numa_mem_id().

But the check is only for not having any memory at all on a node. There
are other reason for allocations to fail on a certain node. The node could
have memory that cannot be reclaimed, all dirty, beyond certain
thresholds, not in the current set of allowed nodes etc etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
