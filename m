Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD426B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:58:24 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i17so26756700qcy.11
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 11:58:24 -0800 (PST)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id j10si11062550qas.43.2014.02.18.11.58.23
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 11:58:23 -0800 (PST)
Date: Tue, 18 Feb 2014 13:58:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140218172832.GD31998@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1402181356120.2910@nuc>
References: <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com> <20140207054819.GC28952@lge.com> <alpine.DEB.2.10.1402071150090.15168@nuc> <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210191321.GD1558@linux.vnet.ibm.com> <20140211074159.GB27870@lge.com> <20140213065137.GA10860@linux.vnet.ibm.com> <20140217070051.GE3468@lge.com> <alpine.DEB.2.10.1402181051560.1291@nuc> <20140218172832.GD31998@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Tue, 18 Feb 2014, Nishanth Aravamudan wrote:

>
> Well, on powerpc, with the hypervisor providing the resources and the
> topology, you can have cpuless and memoryless nodes. I'm not sure how
> "fake" the NUMA is -- as I think since the resources are virtualized to
> be one system, it's logically possible that the actual topology of the
> resources can be CPUs from physical node 0 and memory from physical node
> 2. I would think with KVM on a sufficiently large (physically NUMA
> x86_64) and loaded system, one could cause the same sort of
> configuration to occur for a guest?

Ok but since you have a virtualized environment: Why not provide a fake
home node with fake memory that could be anywhere? This would avoid the
whole problem of supporting such a config at the kernel level.

Do not have a fake node that has no memory.

> In any case, these configurations happen fairly often on long-running
> (not rebooted) systems as LPARs are created/destroyed, resources are
> DLPAR'd in and out of LPARs, etc.

Ok then also move the memory of the local node somewhere?

> I might look into it, as it might have sped up testing these changes.

I guess that will be necessary in order to support the memoryless nodes
long term.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
