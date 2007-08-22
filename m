Date: Wed, 22 Aug 2007 15:40:23 -0700 (PDT)
Message-Id: <20070822.154023.20890574.davem@davemloft.net>
Subject: Re: [PATCH] Limit the maximum size of merged slab caches
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0708221518200.17370@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0708221518200.17370@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 22 Aug 2007 15:19:19 -0700 (PDT)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> We always switch off the debugging bits of slabs that are too large
> for free pointer relocationi (256k, 512k). This means that we may create
> kmem_cache structures that look as if they are satisfying the requirements
> for merging even if slub_debug is set. Sysfs handling may think they are
> mergeable and thus creates unique ids that may then clash.
> 
> [Patches in the works are soon going to make that limit obsolete]
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
