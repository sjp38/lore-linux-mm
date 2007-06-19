Date: Tue, 19 Jun 2007 11:48:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 00/10] NUMA: Memoryless Node support V1
Message-Id: <20070619114805.a3ad8576.akpm@linux-foundation.org>
In-Reply-To: <20070618191956.411091458@sgi.com>
References: <20070618191956.411091458@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007 12:19:56 -0700
clameter@sgi.com wrote:

> This patch is addressing various issues with NUMA as a result of memory
> less nodes being used. I think this is only a start fixing the most obvious
> things, there may be more where this came from. I'd appreciate if someone
> with a system with memoryless nodes could do systematic testing to see that
> all the NUMA functionality works properly. Nishanth has done some testing
> but he seems to be farily new to this.
> 
> The patchset is also part of my upload queue at
> http://ftp.kernel.org/pub/linux/kernel/people/christoph/2.6.22-rc4-mm2
> 
> I know that some people are doing work based on this patchset. Will update
> the patches in that location if more fixes are submitted.

OK, I'll duck version 1 for now.  Am hugely backlogged at present and I'm
mainly looking for simple-and-safe fixes.

Plus I'm generally going more slowly and deliberately in the vague hope
that others will follow suit.

> I hope Andrew
> will get a new mm version out soon.

umm, maybe, it depends on how much crap I merge today.  I'll be spending
the rest of the week overseas, so I guess I'd better try.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
