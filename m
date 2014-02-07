Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id CEE4E6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:54:01 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id w8so5708810qac.22
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:54:01 -0800 (PST)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id jj3si1803337qcb.67.2014.02.07.09.53.59
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 09:54:00 -0800 (PST)
Date: Fri, 7 Feb 2014 11:53:57 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140207054819.GC28952@lge.com>
Message-ID: <alpine.DEB.2.10.1402071150090.15168@nuc>
References: <20140206020757.GC5433@linux.vnet.ibm.com> <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com> <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com> <20140207054819.GC28952@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, 7 Feb 2014, Joonsoo Kim wrote:

> >
> > It seems like a better approach would be to do this when a node is brought
> > online and determine the fallback node based not on the zonelists as you
> > do here but rather on locality (such as through a SLIT if provided, see
> > node_distance()).
>
> Hmm...
> I guess that zonelist is base on locality. Zonelist is generated using
> node_distance(), so I think that it reflects locality. But, I'm not expert
> on NUMA, so please let me know what I am missing here :)

The next node can be found by going through the zonelist of a node and
checking for available memory. See fallback_alloc().

There is a function node_distance() that determines the relative
performance of a memory access from one to the other node.
The building of the fallback list for every node in build_zonelists()
relies on that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
