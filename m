Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7036B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 17:03:31 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so982947pbb.20
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:03:30 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id k7si948083pbl.41.2014.02.19.14.03.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 14:03:30 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so973848pbb.6
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:03:21 -0800 (PST)
Date: Wed, 19 Feb 2014 14:03:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <alpine.DEB.2.10.1402181356120.2910@nuc>
Message-ID: <alpine.DEB.2.02.1402191400400.31921@chino.kir.corp.google.com>
References: <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com> <20140207054819.GC28952@lge.com> <alpine.DEB.2.10.1402071150090.15168@nuc> <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210191321.GD1558@linux.vnet.ibm.com> <20140211074159.GB27870@lge.com> <20140213065137.GA10860@linux.vnet.ibm.com> <20140217070051.GE3468@lge.com> <alpine.DEB.2.10.1402181051560.1291@nuc> <20140218172832.GD31998@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402181356120.2910@nuc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Tue, 18 Feb 2014, Christoph Lameter wrote:

> Ok but since you have a virtualized environment: Why not provide a fake
> home node with fake memory that could be anywhere? This would avoid the
> whole problem of supporting such a config at the kernel level.
> 

By acpi, the abstraction of a NUMA node can include any combination of 
cpus, memory, I/O resources, networking, or storage devices.  This allows 
two memoryless nodes, for example, to have different proximity to memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
