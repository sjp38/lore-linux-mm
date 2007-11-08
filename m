Date: Thu, 8 Nov 2007 21:37:27 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded insertions
Message-ID: <20071108203727.GA14254@wotan.suse.de>
References: <20071108004304.GD3227@wotan.suse.de> <20071107170923.6cf3c389.akpm@linux-foundation.org> <20071108013723.GF3227@wotan.suse.de> <20071107190254.4e65812a.akpm@linux-foundation.org> <20071108031645.GI3227@wotan.suse.de> <20071107201242.390aec38.akpm@linux-foundation.org> <1194523022.6289.137.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1194523022.6289.137.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Thu, Nov 08, 2007 at 12:57:02PM +0100, Peter Zijlstra wrote:
> On Wed, 2007-11-07 at 20:12 -0800, Andrew Morton wrote:
> 
> > <looks at fs/nfs/write.c>
> > 
> > again: unreliable, remembers to test for failure, would be better to use
> > radix_tree_preload().
> 
> http://lkml.org/lkml/2007/10/30/271

Ah, missed that. See my subsequent patch too, slightly different. It only
preloads if a request isn't already found (is this a good idea?, if it wasn't
relatively common, they'd just be checking for -EEXIST in the insertion?).

Anyway we can also simplify the code because the insertion can't fail with a
preload.

NFS can also use GFP_NOFS for the preload (at least, for upstream).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
