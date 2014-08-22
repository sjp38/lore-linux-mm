Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 91CD36B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 17:52:59 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so10110482qaj.7
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 14:52:59 -0700 (PDT)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id u3si24574301qab.24.2014.08.22.14.52.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Aug 2014 14:52:58 -0700 (PDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 22 Aug 2014 17:52:58 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 8261CC90043
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 17:52:46 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s7MLqsMq8847704
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 21:52:54 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7MLqrfR000369
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 17:52:54 -0400
Date: Fri, 22 Aug 2014 14:52:38 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH v3 1/4] topology: add support for node_to_mem_node()
 to determine the fallback node
Message-ID: <20140822215238.GH13999@linux.vnet.ibm.com>
References: <20140814001301.GI11121@linux.vnet.ibm.com>
 <20140814001422.GJ11121@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1408140934290.25902@gentwo.org>
 <20140814200656.GP11121@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140814200656.GP11121@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

Hi Christoph,

On 14.08.2014 [13:06:56 -0700], Nishanth Aravamudan wrote:
> On 14.08.2014 [09:35:37 -0500], Christoph Lameter wrote:
> > On Wed, 13 Aug 2014, Nishanth Aravamudan wrote:
> > 
> > > +++ b/include/linux/topology.h
> > > @@ -119,11 +119,20 @@ static inline int numa_node_id(void)
> > >   * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
> > >   */
> > >  DECLARE_PER_CPU(int, _numa_mem_);
> > > +extern int _node_numa_mem_[MAX_NUMNODES];
> > 
> > Why are these variables starting with an _ ?
> > Maybe _numa_mem was defined that way because it is typically not defined.
> > We dont do this in other situations.
> 
> That's how it was in Joonsoo's patch and I was trying to minimize the
> changes from his version (beyond making it compile). I can of course
> update it to not have a prefixing _ if that's preferred.

Upon reflection, did you mean all of these variables? Would you rather I
submitted a follow-on patch that removed the prefix _? Note that
_node_numa_mem_ is also not defined if !MEMORYLESS_NODES.

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
