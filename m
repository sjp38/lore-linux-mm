Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id B53426B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:41:40 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id e16so18608543qcx.21
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 13:41:40 -0800 (PST)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id h3si2213154qah.158.2014.02.13.13.41.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 13:41:40 -0800 (PST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 13 Feb 2014 16:41:39 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C13F0C90042
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:41:34 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1DLfbiq9896258
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 21:41:37 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1DLfaO3002415
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:41:37 -0500
Date: Thu, 13 Feb 2014 13:41:31 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] powerpc: enable CONFIG_HAVE_MEMORYLESS_NODES
Message-ID: <20140213214131.GB12409@linux.vnet.ibm.com>
References: <20140128183457.GA9315@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140128183457.GA9315@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Anton Blanchard <anton@samba.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On 28.01.2014 [10:34:57 -0800], Nishanth Aravamudan wrote:
> Anton Blanchard found an issue with an LPAR that had no memory in Node
> 0. Christoph Lameter recommended, as one possible solution, to use
> numa_mem_id() for locality of the nearest memory node-wise. However,
> numa_mem_id() [and the other related APIs] are only useful if
> CONFIG_HAVE_MEMORYLESS_NODES is set. This is only the case for ia64
> currently, but clearly we can have memoryless nodes on ppc64. Add the
> Kconfig option and define it to be the same value as CONFIG_NUMA.
> 
> On the LPAR in question, which was very inefficiently using slabs, this
> took the slab consumption at boot from roughly 7GB to roughly 4GB.

Err, this should have been

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

!

Sorry about that Ben!
    
> ---
> Ben, the only question I have wrt this change is if it's appropriate to
> change it for all powerpc configs (that have NUMA on)?
> 
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 25493a0..bb2d5fe 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -447,6 +447,9 @@ config NODES_SHIFT
>  	default "4"
>  	depends on NEED_MULTIPLE_NODES
>  
> +config HAVE_MEMORYLESS_NODES
> +	def_bool NUMA
> +
>  config ARCH_SELECT_MEMORY_MODEL
>  	def_bool y
>  	depends on PPC64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
