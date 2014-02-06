Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 98CE56B0036
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:13:58 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id w8so3941030qac.36
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:13:58 -0800 (PST)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id i33si1100085qgf.180.2014.02.06.09.26.17
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 09:26:48 -0800 (PST)
Date: Thu, 6 Feb 2014 11:26:15 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 1/3] slub: search partial list on numa_mem_id(),
 instead of numa_node_id()
In-Reply-To: <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1402061126000.5348@nuc>
References: <20140206020757.GC5433@linux.vnet.ibm.com> <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, 6 Feb 2014, Joonsoo Kim wrote:

> Currently, if allocation constraint to node is NUMA_NO_NODE, we search
> a partial slab on numa_node_id() node. This doesn't work properly on the
> system having memoryless node, since it can have no memory on that node and
> there must be no partial slab on that node.
>
> On that node, page allocation always fallback to numa_mem_id() first. So
> searching a partial slab on numa_node_id() in that case is proper solution
> for memoryless node case.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
