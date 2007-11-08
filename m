Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded
	insertions
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20071108203727.GA14254@wotan.suse.de>
References: <20071108004304.GD3227@wotan.suse.de>
	 <20071107170923.6cf3c389.akpm@linux-foundation.org>
	 <20071108013723.GF3227@wotan.suse.de>
	 <20071107190254.4e65812a.akpm@linux-foundation.org>
	 <20071108031645.GI3227@wotan.suse.de>
	 <20071107201242.390aec38.akpm@linux-foundation.org>
	 <1194523022.6289.137.camel@twins>  <20071108203727.GA14254@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 08 Nov 2007 21:47:43 +0100
Message-Id: <1194554863.20832.15.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Thu, 2007-11-08 at 21:37 +0100, Nick Piggin wrote:
> On Thu, Nov 08, 2007 at 12:57:02PM +0100, Peter Zijlstra wrote:
> > On Wed, 2007-11-07 at 20:12 -0800, Andrew Morton wrote:
> > 
> > > <looks at fs/nfs/write.c>
> > > 
> > > again: unreliable, remembers to test for failure, would be better to use
> > > radix_tree_preload().
> > 
> > http://lkml.org/lkml/2007/10/30/271
> 
> Ah, missed that. See my subsequent patch too, slightly different. It only
> preloads if a request isn't already found (is this a good idea?, if it wasn't
> relatively common, they'd just be checking for -EEXIST in the insertion?).
> 
> Anyway we can also simplify the code because the insertion can't fail with a
> preload.

Yeah, saw that, didn't get round to verifying the logic. Patch looked
good on first glance.

> NFS can also use GFP_NOFS for the preload (at least, for upstream).

Agreed, the NOIO comes from me swapping over it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
