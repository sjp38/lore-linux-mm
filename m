Date: Wed, 17 Aug 2005 17:43:59 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: pagefault scalability patches
Message-Id: <20050817174359.0efc7a6a.akpm@osdl.org>
In-Reply-To: <20050817151723.48c948c7.akpm@osdl.org>
References: <20050817151723.48c948c7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org, hugh@veritas.com, clameter@engr.sgi.com, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> I have vague feelings of ickiness with the patches wrt:
> 
>  a) general increase of complexity
> 
>  b) the fact that they only partially address the problem: anonymous page
>     faults are addressed, but lots of other places aren't.
> 
>  c) the fact that they address one particular part of one particular
>     workload on exceedingly rare machines.

d) the fact that some architectures will be using atomic pte ops and
   others will be using page_table_lock in core MM code.

   Using different locking/atomicity schemes in different architectures
   has obvious complexity and test coverage drawbacks.

   Is it still the case that some architectures must retain the
   page_table_lock approach because they use it to lock other arch-internal
   things?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
