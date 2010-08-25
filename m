Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE346B01F0
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 12:47:07 -0400 (EDT)
Date: Wed, 25 Aug 2010 09:45:59 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for August 25 (mm/slub)
Message-Id: <20100825094559.bc652afe.randy.dunlap@oracle.com>
In-Reply-To: <20100825132057.c8416bef.sfr@canb.auug.org.au>
References: <20100825132057.c8416bef.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010 13:20:57 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20100824:


2 separate slub build errors/warnings:

mm/slub.c:1732: error: implicit declaration of function 'slab_pre_alloc_hook'
mm/slub.c:1751: error: implicit declaration of function 'slab_post_alloc_hook'
mm/slub.c:1881: error: implicit declaration of function 'slab_free_hook'
mm/slub.c:1886: error: implicit declaration of function 'slab_free_hook_irq'


and in different builds:

mm/slub.c:1898: note: expected 'struct kmem_cache *' but argument is of type 'struct kmem_cache **'
mm/slub.c:1756: note: expected 'struct kmem_cache *' but argument is of type 'struct kmem_cache **'

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
