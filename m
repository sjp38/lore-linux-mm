Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
	nonlinear)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1173275532.6374.183.camel@twins>
References: <20070307102106.GB5555@wotan.suse.de>
	 <1173263085.6374.132.camel@twins> <20070307103842.GD5555@wotan.suse.de>
	 <1173264462.6374.140.camel@twins> <20070307110035.GE5555@wotan.suse.de>
	 <1173268086.6374.157.camel@twins> <20070307121730.GC18704@wotan.suse.de>
	 <1173271286.6374.166.camel@twins> <20070307130851.GE18704@wotan.suse.de>
	 <1173273562.6374.175.camel@twins>  <20070307133649.GF18704@wotan.suse.de>
	 <1173275532.6374.183.camel@twins>
Content-Type: text/plain
Date: Wed, 07 Mar 2007 15:34:27 +0100
Message-Id: <1173278067.6374.188.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-03-07 at 14:52 +0100, Peter Zijlstra wrote:

> True. We could even guesstimate the nonlinear dirty pages by subtracting
> the result of page_mkclean() from page_mapcount() and force an
> msync(MS_ASYNC) on said mapping (or all (nonlinear) mappings of the
> related file) when some threshold gets exceeded.

Almost, but not quite, we'd need to extract another value from the
page_mkclean() run, the actual number of mappings encountered. The
return value only sums the number of dirty mappings encountered.

s390 would already work I guess.

Certainly doable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
