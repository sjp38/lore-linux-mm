Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2E76B0036
	for <linux-mm@kvack.org>; Sun, 18 May 2014 22:39:13 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so5084870pad.2
        for <linux-mm@kvack.org>; Sun, 18 May 2014 19:39:12 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id tf4si17651873pab.11.2014.05.18.19.39.11
        for <linux-mm@kvack.org>;
        Sun, 18 May 2014 19:39:12 -0700 (PDT)
Date: Mon, 19 May 2014 11:41:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/3] slub: search partial list on numa_mem_id(),
 instead of numa_node_id()
Message-ID: <20140519024140.GD19615@js1304-P5Q-DELUXE>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
 <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140516233735.GH8941@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140516233735.GH8941@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, May 16, 2014 at 04:37:35PM -0700, Nishanth Aravamudan wrote:
> On 06.02.2014 [17:07:04 +0900], Joonsoo Kim wrote:
> > Currently, if allocation constraint to node is NUMA_NO_NODE, we search
> > a partial slab on numa_node_id() node. This doesn't work properly on the
> > system having memoryless node, since it can have no memory on that node and
> > there must be no partial slab on that node.
> > 
> > On that node, page allocation always fallback to numa_mem_id() first. So
> > searching a partial slab on numa_node_id() in that case is proper solution
> > for memoryless node case.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Acked-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> 
> Joonsoo, would you send this one on to Andrew?

Hello,

Okay. I will do it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
