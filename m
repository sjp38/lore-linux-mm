Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id B4ECF6B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 11:03:10 -0400 (EDT)
Date: Wed, 21 Mar 2012 10:03:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Patch workqueue: create new slab cache instead of hacking
In-Reply-To: <1332341381.7893.17.camel@edumazet-glaptop>
Message-ID: <alpine.DEB.2.00.1203210959500.21932@router.home>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com> <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com> <20120320154619.GA5684@google.com> <4F6944D9.5090002@cn.fujitsu.com> <CAOS58YPydFUap4HjuRATxza6VZgyrXmQHVxR83G7GRJL50ZTRQ@mail.gmail.com>
 <alpine.DEB.2.00.1203210910450.20482@router.home> <1332341381.7893.17.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 Mar 2012, Eric Dumazet wrote:

> Creating a dedicated cache for few objects ? Thats a lot of overhead, at
> least for SLAB (no merges of caches)

Its some overhead for SLAB (a lot is what? If you tune down the per cpu
caches it should be a couple of pages) but its none for SLUB. Maybe we
need to add the merge logic to SLAB?

Or maybe we can extract a common higher handling level for kmem_cache
from all slab allocators and make merging standard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
