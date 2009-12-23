Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2A7620002
	for <linux-mm@kvack.org>; Wed, 23 Dec 2009 05:23:47 -0500 (EST)
Date: Wed, 23 Dec 2009 11:23:43 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] slab: initialize unused alien cache entry as NULL at
	alloc_alien_cache().
Message-ID: <20091223102343.GD20539@basil.fritz.box>
References: <4B30BDA8.1070904@linux.intel.com> <alpine.DEB.2.00.0912220945250.12048@router.home> <4B31BE44.1070308@linux.intel.com> <4B31EC7C.7000302@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B31EC7C.7000302@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, andi@firstfloor.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Then, this is a violation of the first statement :
> 
> nr_node_ids = 1 + nid of highest POSSIBLE node.
> 
> If your system allows hotplugging of new nodes, then POSSIBLE nodes should include them
> at boot time.

Agreed, nr_node_ids must be possible nodes.

It should have been set up by the SRAT parser (modulo regressions)

Haicheng, did you verify with printk it's really incorrect at this point?
-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
