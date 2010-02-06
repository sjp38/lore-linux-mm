Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7456B0047
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 02:27:48 -0500 (EST)
Date: Sat, 6 Feb 2010 08:27:46 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [3/4] SLAB: Separate node initialization into separate function
Message-ID: <20100206072746.GP29555@one.firstfloor.org>
References: <201002031039.710275915@firstfloor.org> <20100203213914.D8654B1620@basil.firstfloor.org> <alpine.DEB.2.00.1002051324370.2376@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002051324370.2376@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> As Christoph mentioned, this patch is out of order with the previous one 

Ok.

> in the series; slab_node_prepare() is called in that previous patch by a 
> memory hotplug callback without holding cache_chain_mutex (it's taken by 
> the cpu hotplug callback prior to calling cpuup_prepare() currently).  So 
> slab_node_prepare() should note that we require the mutex and the memory 
> hotplug callback should take it in the previous patch.

AFAIK the code is correct. If you feel the need for additional
documentation feel free to send patches yourself.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
