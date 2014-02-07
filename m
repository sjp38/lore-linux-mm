Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4640E6B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 00:42:12 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so2796264pbc.28
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 21:42:11 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ds4si3606720pbb.169.2014.02.06.21.42.08
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 21:42:10 -0800 (PST)
Date: Fri, 7 Feb 2014 14:42:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140207054204.GB28952@lge.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
 <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <20140206191131.GB7845@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140206191131.GB7845@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, Feb 06, 2014 at 11:11:31AM -0800, Nishanth Aravamudan wrote:
> > diff --git a/include/linux/topology.h b/include/linux/topology.h
> > index 12ae6ce..66b19b8 100644
> > --- a/include/linux/topology.h
> > +++ b/include/linux/topology.h
> > @@ -233,11 +233,20 @@ static inline int numa_node_id(void)
> >   * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
> >   */
> >  DECLARE_PER_CPU(int, _numa_mem_);
> > +int _node_numa_mem_[MAX_NUMNODES];
> 
> Should be static, I think?

Yes, will update it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
