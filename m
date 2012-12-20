Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id A36D96B007D
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 15:43:54 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fa1so2350994pad.21
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 12:43:53 -0800 (PST)
Date: Thu, 20 Dec 2012 12:43:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/sparse: don't check return value of alloc_bootmem
 calls
In-Reply-To: <50D376E9.9030507@oracle.com>
Message-ID: <alpine.DEB.2.00.1212201238460.29839@chino.kir.corp.google.com>
References: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com> <1356030701-16284-30-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.00.1212201218590.29839@chino.kir.corp.google.com> <50D376E9.9030507@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 20 Dec 2012, Sasha Levin wrote:

> So what we really need is to update the documentation of __alloc_bootmem_node, I'll send
> a patch that does that instead.
> 

It panics iff slab is not available to allocate from yet, otherwise it's 
just a wrapper around kmalloc().  This emits a warning to the kernel log, 
though, so __alloc_bootmem_node() should certainly not be called that late 
in the boot sequence.

Since __alloc_bootmem_node_nopanic() is the way to avoid the panic, I 
think the change that should be made here so to panic even when the 
kmalloc() fails in __alloc_bootmem_node(), __alloc_bootmem_node_high(), 
and __alloc_bootmem_low_node().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
