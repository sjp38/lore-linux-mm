Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 43A656B0035
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:16:50 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id gq1so1255495obb.35
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 15:16:50 -0800 (PST)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id ds9si1743550obc.21.2014.02.19.15.16.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 15:16:49 -0800 (PST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 19 Feb 2014 18:16:49 -0500
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3A8D738C804A
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:16:47 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1JNGlPQ7340526
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 23:16:47 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1JNGklE023323
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:16:46 -0500
Date: Wed, 19 Feb 2014 15:16:41 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH 0/3] powerpc: support memoryless nodes
Message-ID: <20140219231641.GA413@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nish Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org

We have seen several issues recently on powerpc LPARs with memoryless
node NUMA configurations, e.g. (an extreme case):

numactl --hardware
available: 2 nodes (0,3)
node 0 cpus:
node 0 size: 0 MB
node 0 free: 0 MB
node 3 cpus: 0 1 2 3
node 3 size: 8142 MB
node 3 free: 7765 MB
node distances:
node   0   3 
  0:  10  20 
  3:  20  10 

powerpc doesn't set CONFIG_HAVE_MEMORYLESS_NODES, so we are missing out
on a lot of the core-kernel support necessary. This series attempts to
fix this by enabling the config option, which requires a few other
changes as well.

1/3: mm: return NUMA_NO_NODE in local_memory_node if zonelists are not
setup
2/3: powerpc: enable CONFIG_HAVE_PERCPU_NUMA_NODE_ID
3/3: powerpc: enable CONFIG_HAVE_MEMORYLESS_NODES

I have tested this series with Christoph's patch (currently being
discussed): http://www.spinics.net/lists/linux-mm/msg69452.html

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
