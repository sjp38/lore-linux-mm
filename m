Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 882546B0078
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 04:55:26 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o169tMSp017066
	for <linux-mm@kvack.org>; Sat, 6 Feb 2010 09:55:23 GMT
Received: from pzk29 (pzk29.prod.google.com [10.243.19.157])
	by wpaz33.hot.corp.google.com with ESMTP id o169tKxP002201
	for <linux-mm@kvack.org>; Sat, 6 Feb 2010 01:55:21 -0800
Received: by pzk29 with SMTP id 29so5258612pzk.17
        for <linux-mm@kvack.org>; Sat, 06 Feb 2010 01:55:20 -0800 (PST)
Date: Sat, 6 Feb 2010 01:55:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [3/4] SLAB: Separate node initialization into separate
 function
In-Reply-To: <20100206072746.GP29555@one.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002060153250.17897@chino.kir.corp.google.com>
References: <201002031039.710275915@firstfloor.org> <20100203213914.D8654B1620@basil.firstfloor.org> <alpine.DEB.2.00.1002051324370.2376@chino.kir.corp.google.com> <20100206072746.GP29555@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Feb 2010, Andi Kleen wrote:

> > in the series; slab_node_prepare() is called in that previous patch by a 
> > memory hotplug callback without holding cache_chain_mutex (it's taken by 
> > the cpu hotplug callback prior to calling cpuup_prepare() currently).  So 
> > slab_node_prepare() should note that we require the mutex and the memory 
> > hotplug callback should take it in the previous patch.
> 
> AFAIK the code is correct. If you feel the need for additional
> documentation feel free to send patches yourself.
> 

Documentation?  You're required to take cache_chain_mutex before calling 
slab_node_prepare() in your memory hotplug notifier, it iterates 
cache_chain.  Please look again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
