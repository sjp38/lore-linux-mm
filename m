Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded
	insertions
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20071107201242.390aec38.akpm@linux-foundation.org>
References: <20071108004304.GD3227@wotan.suse.de>
	 <20071107170923.6cf3c389.akpm@linux-foundation.org>
	 <20071108013723.GF3227@wotan.suse.de>
	 <20071107190254.4e65812a.akpm@linux-foundation.org>
	 <20071108031645.GI3227@wotan.suse.de>
	 <20071107201242.390aec38.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 08 Nov 2007 12:57:02 +0100
Message-Id: <1194523022.6289.137.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Wed, 2007-11-07 at 20:12 -0800, Andrew Morton wrote:

> <looks at fs/nfs/write.c>
> 
> again: unreliable, remembers to test for failure, would be better to use
> radix_tree_preload().

http://lkml.org/lkml/2007/10/30/271



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
