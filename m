Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 165F66B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:23:21 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id wn1so19188872obc.34
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:23:20 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id sp3si12840612obb.108.2014.02.18.14.23.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:23:20 -0800 (PST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 18 Feb 2014 15:23:19 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2FEF919D8045
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 15:23:16 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1IMMmM351511530
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 23:22:53 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1IMMu2j012606
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 15:22:56 -0700
Date: Tue, 18 Feb 2014 14:22:42 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140218222242.GA10844@linux.vnet.ibm.com>
References: <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210191321.GD1558@linux.vnet.ibm.com>
 <20140211074159.GB27870@lge.com>
 <20140213065137.GA10860@linux.vnet.ibm.com>
 <20140217070051.GE3468@lge.com>
 <alpine.DEB.2.10.1402181051560.1291@nuc>
 <20140218172832.GD31998@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402181356120.2910@nuc>
 <20140218210923.GA28170@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402181547210.3973@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402181547210.3973@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 18.02.2014 [15:49:22 -0600], Christoph Lameter wrote:
> On Tue, 18 Feb 2014, Nishanth Aravamudan wrote:
> 
> > We use the topology provided by the hypervisor, it does actually reflect
> > where CPUs and memory are, and their corresponding performance/NUMA
> > characteristics.
> 
> And so there are actually nodes without memory that have processors?

Virtually (topologically as indicated to Linux), yes. Physically, I
don't think they are, but they might be exhausted, which is we get sort
of odd-appearing NUMA configurations.

> Can the hypervisor or the linux arch code be convinced to ignore nodes
> without memory or assign a sane default node to processors?

I think this happens quite often, so I don't know that we want to ignore
the performance impact of the underlying NUMA configuration. I guess we
could special-case memoryless/cpuless configurations somewhat, but I
don't think there's any reason to do that if we can make memoryless-node
support work in-kernel?

> > > Ok then also move the memory of the local node somewhere?
> >
> > This happens below the OS, we don't control the hypervisor's decisions.
> > I'm not sure if that's what you are suggesting.
> 
> You could also do this from the powerpc arch code by sanitizing the
> processor / node information that is then used by Linux.

I see what you're saying now, thanks!

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
