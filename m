Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 820756B004A
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 04:10:59 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator (try 2)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1232960840.4863.7.camel@laptop>
References: <20090123154653.GA14517@wotan.suse.de>
	 <1232959706.21504.7.camel@penberg-laptop>  <1232960840.4863.7.camel@laptop>
Content-Type: text/plain
Date: Mon, 26 Jan 2009 10:10:51 +0100
Message-Id: <1232961051.4863.10.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-01-26 at 10:07 +0100, Peter Zijlstra wrote:
> On Mon, 2009-01-26 at 10:48 +0200, Pekka Enberg wrote:
> > Christoph has expressed concerns over latency issues of SLQB, I suppose
> > it would be interesting to hear if it makes any difference to the
> > real-time folks.
> 
> I'll 'soon' take a stab at converting SLQB for -rt. Currently -rt is
> SLAB only.
> 
> Then again, anything that does allocation is per definition not bounded
> and not something we can have on latency critical paths -- so on that
> respect its not interesting.

Before someone pipes up, _yes_ I do know about RT allocators and such.

No we don't do that in-kernel, other than through reservation mechanisms
like mempool -- and I'd rather extend that than try and get page reclaim
bounded.

Yes, I also know about folks doing RT paging, and no, I'm not wanting to
hear about that either ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
