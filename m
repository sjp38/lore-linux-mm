Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A85356002CC
	for <linux-mm@kvack.org>; Sat, 22 May 2010 04:35:52 -0400 (EDT)
Message-ID: <4BF79761.5000402@cs.helsinki.fi>
Date: Sat, 22 May 2010 11:35:45 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH v2] slub: move kmem_cache_node into it's own cacheline
References: <20100521214135.23902.55360.stgit@gitlad.jf.intel.com>
In-Reply-To: <20100521214135.23902.55360.stgit@gitlad.jf.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: cl@linux.com, linux-mm@kvack.org, alex.shi@intel.com, yanmin_zhang@linux.intel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>

Alexander Duyck wrote:
> This patch is meant to improve the performance of SLUB by moving the local
> kmem_cache_node lock into it's own cacheline separate from kmem_cache.
> This is accomplished by simply removing the local_node when NUMA is enabled.
> 
> On my system with 2 nodes I saw around a 5% performance increase w/
> hackbench times dropping from 6.2 seconds to 5.9 seconds on average.  I
> suspect the performance gain would increase as the number of nodes
> increases, but I do not have the data to currently back that up.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Thanks for the fix, Alexander!

Yanmin and Alex, can I have your Tested-by or Acked-by please so we can 
close "[Bug #15713] hackbench regression due to commit 9dfc6e68bfe6e" 
after this patch is merged?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
