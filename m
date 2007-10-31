From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 05/33] mm: kmem_estimate_pages()
Date: Wed, 31 Oct 2007 14:43:17 +1100
References: <20071030160401.296770000@chello.nl> <20071030160911.281698000@chello.nl>
In-Reply-To: <20071030160911.281698000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710311443.18143.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> Provide a method to get the upper bound on the pages needed to allocate
> a given number of objects from a given kmem_cache.
>

Fair enough, but just to make it a bit easier, can you provide a
little reason of why in this patch (or reference the patch number
where you use it, or put it together with the patch where you use
it, etc.).

Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
