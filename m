Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 652A46B0038
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 16:07:10 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so6124293igb.4
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 13:07:10 -0700 (PDT)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id l3si11774055igx.12.2014.08.14.13.07.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 13:07:09 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 14 Aug 2014 14:07:08 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7755B19D8041
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 14:06:54 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s7EK75mi19005504
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 22:07:05 +0200
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7EK74Bt013515
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 14:07:05 -0600
Date: Thu, 14 Aug 2014 13:06:56 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH v3 1/4] topology: add support for node_to_mem_node()
 to determine the fallback node
Message-ID: <20140814200656.GP11121@linux.vnet.ibm.com>
References: <20140814001301.GI11121@linux.vnet.ibm.com>
 <20140814001422.GJ11121@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1408140934290.25902@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408140934290.25902@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On 14.08.2014 [09:35:37 -0500], Christoph Lameter wrote:
> On Wed, 13 Aug 2014, Nishanth Aravamudan wrote:
> 
> > +++ b/include/linux/topology.h
> > @@ -119,11 +119,20 @@ static inline int numa_node_id(void)
> >   * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
> >   */
> >  DECLARE_PER_CPU(int, _numa_mem_);
> > +extern int _node_numa_mem_[MAX_NUMNODES];
> 
> Why are these variables starting with an _ ?
> Maybe _numa_mem was defined that way because it is typically not defined.
> We dont do this in other situations.

That's how it was in Joonsoo's patch and I was trying to minimize the
changes from his version (beyond making it compile). I can of course
update it to not have a prefixing _ if that's preferred.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
