Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 73A666B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:49:26 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id x13so26577349qcv.33
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 13:49:26 -0800 (PST)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id e60si11143844qgf.82.2014.02.18.13.49.25
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 13:49:25 -0800 (PST)
Date: Tue, 18 Feb 2014 15:49:22 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140218210923.GA28170@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1402181547210.3973@nuc>
References: <20140207054819.GC28952@lge.com> <alpine.DEB.2.10.1402071150090.15168@nuc> <alpine.DEB.2.10.1402071245040.20246@nuc> <20140210191321.GD1558@linux.vnet.ibm.com> <20140211074159.GB27870@lge.com> <20140213065137.GA10860@linux.vnet.ibm.com>
 <20140217070051.GE3468@lge.com> <alpine.DEB.2.10.1402181051560.1291@nuc> <20140218172832.GD31998@linux.vnet.ibm.com> <alpine.DEB.2.10.1402181356120.2910@nuc> <20140218210923.GA28170@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Tue, 18 Feb 2014, Nishanth Aravamudan wrote:

> We use the topology provided by the hypervisor, it does actually reflect
> where CPUs and memory are, and their corresponding performance/NUMA
> characteristics.

And so there are actually nodes without memory that have processors?
Can the hypervisor or the linux arch code be convinced to ignore nodes
without memory or assign a sane default node to processors?

> > Ok then also move the memory of the local node somewhere?
>
> This happens below the OS, we don't control the hypervisor's decisions.
> I'm not sure if that's what you are suggesting.

You could also do this from the powerpc arch code by sanitizing the
processor / node information that is then used by Linux.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
