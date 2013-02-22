Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id AB5D06B0007
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 11:10:28 -0500 (EST)
Date: Fri, 22 Feb 2013 16:10:27 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: correctly bootstrap boot caches
In-Reply-To: <5127928A.20000@parallels.com>
Message-ID: <0000013d02ab8230-de441d64-395f-4c87-89e7-3f2cd2209680-000000@email.amazonses.com>
References: <1361529030-17462-1-git-send-email-glommer@parallels.com> <0000013d026b4e5f-1b3deecb-7e37-4476-a27b-3a7db8c1f0a8-000000@email.amazonses.com> <51278A12.4000504@parallels.com> <0000013d028eec8e-012456de-9b98-4bcb-9427-2fbee58ecc74-000000@email.amazonses.com>
 <5127928A.20000@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, 22 Feb 2013, Glauber Costa wrote:

> At this point, we are already slab_state == PARTIAL, while
> init_kmem_cache_nodes will only differentiate against slab_state == DOWN.

kmem_cache_node creation runs before PARTIAL and kmem_cache runs
after. So there would be 2 kmem_cache_node structures allocated. Ok so
that would use cpu slabs and therefore remove pages from the partial list.
Pushing that back using the flushing should fix this. But I thought there
was already code that went through the cpu slabs to address this?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
