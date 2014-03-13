Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f43.google.com (mail-oa0-f43.google.com [209.85.219.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC676B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 12:51:25 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id g12so1341279oah.30
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 09:51:25 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id w10si3058867obx.120.2014.03.13.09.51.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 09:51:24 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 13 Mar 2014 10:51:24 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 999401FF003E
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 10:51:20 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2DGpK6E10879302
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 17:51:20 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2DGpK9r011842
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 10:51:20 -0600
Date: Thu, 13 Mar 2014 09:51:00 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140313165100.GD22247@linux.vnet.ibm.com>
References: <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.10.1402071150090.15168@nuc>
 <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210191321.GD1558@linux.vnet.ibm.com>
 <20140211074159.GB27870@lge.com>
 <alpine.DEB.2.10.1402121612270.8183@nuc>
 <20140217065257.GD3468@lge.com>
 <alpine.DEB.2.10.1402181033480.28964@nuc>
 <20140224050851.GB14814@lge.com>
 <alpine.DEB.2.10.1402241353070.20839@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402241353070.20839@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 24.02.2014 [13:54:35 -0600], Christoph Lameter wrote:
> On Mon, 24 Feb 2014, Joonsoo Kim wrote:
> 
> > > It will not common get there because of the tracking. Instead a per cpu
> > > object will be used.
> > > > get_partial_node() always fails even if there are some partial slab on
> > > > memoryless node's neareast node.
> > >
> > > Correct and that leads to a page allocator action whereupon the node will
> > > be marked as empty.
> >
> > Why do we need to request to a page allocator if there is partial slab?
> > Checking whether node is memoryless or not is really easy, so we don't need
> > to skip this. To skip this is suboptimal solution.
> 
> The page allocator action is also used to determine to which other node we
> should fall back if the node is empty. So we need to call the page
> allocator when the per cpu slab is exhaused with the node of the
> memoryless node to get memory from the proper fallback node.

Where do we stand with these patches? I feel like no resolution was
really found...

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
