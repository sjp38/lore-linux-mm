Date: Mon, 7 Nov 2005 22:22:24 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH]: Cleanup of __alloc_pages
Message-Id: <20051107222224.3b4f2a84.pj@sgi.com>
In-Reply-To: <43703EFB.1010103@yahoo.com.au>
References: <20051107174349.A8018@unix-os.sc.intel.com>
	<20051107175358.62c484a3.akpm@osdl.org>
	<1131416195.20471.31.camel@akash.sc.intel.com>
	<43701FC6.5050104@yahoo.com.au>
	<20051107214420.6d0f6ec4.pj@sgi.com>
	<43703EFB.1010103@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: rohit.seth@intel.com, akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick wrote:
> Because it is on the other side of an &&, which evaulates to a
> constant zero when !CONFIG_CPUSETS.

Ah so.

> Having __GFP_HIGH as its own flag gives some more flexibility. I
> don't think it has a downside?

With respect to GFP_ATOMIC, __GFP_HIGH has no flexibility, as they are
#defined to be the same thing.

With respect to __GFP_WAIT, if we only ever use it exactly when
we don't use __GFP_HIGH aka GFP_ATOMIC, then there is a definite
downside.  My old brain doesn't fold constants nearly as reliably or
rapidly as a compiler.  Every apparent degree of freedom that is unused
wastes a few of my remaining precious neurons understanding it.
It directly leads to such bugs as the one I noted in my last reply,
when I realized that checking cpusets in the 'ignoring mins' case
was bogus.

__GFP_HIGH has a second cost - it is easily confused with __GFP_HIGHMEM.

> That would be good. I'll send off a fresh patch with the
> ALLOC_WATERMARKS fixed after Rohit gets around to looking over
> it.

Good.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
