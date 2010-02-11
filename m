Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 47CC66B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:45:41 -0500 (EST)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id o1BLjcmk032105
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:45:39 -0800
Received: from pxi41 (pxi41.prod.google.com [10.243.27.41])
	by spaceape13.eur.corp.google.com with ESMTP id o1BLj7ua030025
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:45:37 -0800
Received: by pxi41 with SMTP id 41so1174897pxi.27
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:45:35 -0800 (PST)
Date: Thu, 11 Feb 2010 13:45:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
In-Reply-To: <20100211205404.085FEB1978@basil.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002111345210.8809@chino.kir.corp.google.com>
References: <20100211953.850854588@firstfloor.org> <20100211205404.085FEB1978@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, Andi Kleen wrote:

> 
> cache_reap can run before the node is set up and then reference a NULL 
> l3 list. Check for this explicitely and just continue. The node
> will be eventually set up.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
