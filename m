Date: Wed, 7 Mar 2007 16:01:02 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307150102.GH18704@wotan.suse.de>
References: <1173264462.6374.140.camel@twins> <20070307110035.GE5555@wotan.suse.de> <1173268086.6374.157.camel@twins> <20070307121730.GC18704@wotan.suse.de> <1173271286.6374.166.camel@twins> <20070307130851.GE18704@wotan.suse.de> <1173273562.6374.175.camel@twins> <20070307133649.GF18704@wotan.suse.de> <1173275532.6374.183.camel@twins> <1173278067.6374.188.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1173278067.6374.188.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 07, 2007 at 03:34:27PM +0100, Peter Zijlstra wrote:
> On Wed, 2007-03-07 at 14:52 +0100, Peter Zijlstra wrote:
> 
> > True. We could even guesstimate the nonlinear dirty pages by subtracting
> > the result of page_mkclean() from page_mapcount() and force an
> > msync(MS_ASYNC) on said mapping (or all (nonlinear) mappings of the
> > related file) when some threshold gets exceeded.
> 
> Almost, but not quite, we'd need to extract another value from the
> page_mkclean() run, the actual number of mappings encountered. The
> return value only sums the number of dirty mappings encountered.
> 
> s390 would already work I guess.
> 
> Certainly doable.

But if we restrict it to root only, and have a note in the man page
about it, then it really isn't worth cluttering up the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
