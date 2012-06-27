Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 833FA6B009C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:10:54 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2410207dak.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:10:53 -0700 (PDT)
Date: Wed, 27 Jun 2012 15:10:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/3] mm/sparse: optimize sparse_index_alloc
In-Reply-To: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1206271510390.22985@chino.kir.corp.google.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, dave@linux.vnet.ibm.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Thu, 28 Jun 2012, Gavin Shan wrote:

> With CONFIG_SPARSEMEM_EXTREME, the two level of memory section
> descriptors are allocated from slab or bootmem. When allocating
> from slab, let slab/bootmem allocator to clear the memory chunk.
> We needn't clear that explicitly.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
