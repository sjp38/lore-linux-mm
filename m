Date: Wed, 27 Feb 2008 10:43:32 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
In-Reply-To: <1204101239.6242.372.camel@lappy>
Message-ID: <Pine.LNX.4.64.0802271041140.20599@sbz-30.cs.Helsinki.FI>
References: <20080220144610.548202000@chello.nl>
 <20080223000620.7fee8ff8.akpm@linux-foundation.org>  <18371.43950.150842.429997@notabene.brown>
  <1204023042.6242.271.camel@lappy>  <18372.64081.995262.986841@notabene.brown>
  <1204099113.6242.353.camel@lappy>  <84144f020802270005p3bfbd04ar9da2875218ef98c4@mail.gmail.com>
  <1204100059.6242.360.camel@lappy> <1204101239.6242.372.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008, Peter Zijlstra wrote:
> Humm, and here I sit staring at the screen. Perhaps I should go get my
> morning juice, but...
> 
>   if (mem_reserve_kmalloc_charge(my_res, sizeof(*foo), 0)) {
>     foo = kmalloc(sizeof(*foo), gfp|__GFP_MEMALLOC)
>     if (!kmem_is_emergency(foo))
>       mem_reserve_kmalloc_charge(my_res, -sizeof(*foo), 0)
>   } else
>     foo = kmalloc(sizeof(*foo), gfp);
> 
> Just doesn't look too pretty..
> 
> And needing to always account the allocation seems wrong.. but I'll take
> poison and see if that wakes up my mind.

Hmm, perhaps this is just hand-waving but why don't you have a 
kmalloc_reserve() function in SLUB that does the accounting properly?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
