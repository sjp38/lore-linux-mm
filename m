Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE676B0035
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:09:32 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so23919584qae.38
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 13:09:32 -0800 (PST)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id z6si11216680qan.31.2014.02.18.13.09.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 13:09:31 -0800 (PST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 18 Feb 2014 16:09:31 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 19C3638C804D
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:09:29 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1IL9Su86750694
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 21:09:29 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1IL9S7Y005333
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:09:28 -0500
Date: Tue, 18 Feb 2014 13:09:23 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140218210923.GA28170@linux.vnet.ibm.com>
References: <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.10.1402071150090.15168@nuc>
 <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210191321.GD1558@linux.vnet.ibm.com>
 <20140211074159.GB27870@lge.com>
 <20140213065137.GA10860@linux.vnet.ibm.com>
 <20140217070051.GE3468@lge.com>
 <alpine.DEB.2.10.1402181051560.1291@nuc>
 <20140218172832.GD31998@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402181356120.2910@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402181356120.2910@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 18.02.2014 [13:58:20 -0600], Christoph Lameter wrote:
> On Tue, 18 Feb 2014, Nishanth Aravamudan wrote:
> 
> >
> > Well, on powerpc, with the hypervisor providing the resources and the
> > topology, you can have cpuless and memoryless nodes. I'm not sure how
> > "fake" the NUMA is -- as I think since the resources are virtualized to
> > be one system, it's logically possible that the actual topology of the
> > resources can be CPUs from physical node 0 and memory from physical node
> > 2. I would think with KVM on a sufficiently large (physically NUMA
> > x86_64) and loaded system, one could cause the same sort of
> > configuration to occur for a guest?
> 
> Ok but since you have a virtualized environment: Why not provide a fake
> home node with fake memory that could be anywhere? This would avoid the
> whole problem of supporting such a config at the kernel level.

We use the topology provided by the hypervisor, it does actually reflect
where CPUs and memory are, and their corresponding performance/NUMA
characteristics.

> Do not have a fake node that has no memory.
> 
> > In any case, these configurations happen fairly often on long-running
> > (not rebooted) systems as LPARs are created/destroyed, resources are
> > DLPAR'd in and out of LPARs, etc.
> 
> Ok then also move the memory of the local node somewhere?

This happens below the OS, we don't control the hypervisor's decisions.
I'm not sure if that's what you are suggesting.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
