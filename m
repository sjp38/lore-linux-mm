Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id C24CC6B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 03:38:45 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so1473677pbc.28
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 00:38:45 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id yh9si257166pab.121.2014.02.06.00.37.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 00:38:25 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so1421140pab.15
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 00:37:55 -0800 (PST)
Date: Thu, 6 Feb 2014 00:37:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 1/3] slub: search partial list on numa_mem_id(),
 instead of numa_node_id()
In-Reply-To: <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1402060037210.21148@chino.kir.corp.google.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com> <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, 6 Feb 2014, Joonsoo Kim wrote:

> Currently, if allocation constraint to node is NUMA_NO_NODE, we search
> a partial slab on numa_node_id() node. This doesn't work properly on the
> system having memoryless node, since it can have no memory on that node and
> there must be no partial slab on that node.
> 
> On that node, page allocation always fallback to numa_mem_id() first. So
> searching a partial slab on numa_node_id() in that case is proper solution
> for memoryless node case.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 

Acked-by: David Rientjes <rientjes@google.com>

I think you'll need to send these to Andrew since he appears to be picking 
up slub patches these days.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
