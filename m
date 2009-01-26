Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 413AA6B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 04:07:27 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator (try 2)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1232959706.21504.7.camel@penberg-laptop>
References: <20090123154653.GA14517@wotan.suse.de>
	 <1232959706.21504.7.camel@penberg-laptop>
Content-Type: text/plain
Date: Mon, 26 Jan 2009 10:07:20 +0100
Message-Id: <1232960840.4863.7.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-01-26 at 10:48 +0200, Pekka Enberg wrote:
> Christoph has expressed concerns over latency issues of SLQB, I suppose
> it would be interesting to hear if it makes any difference to the
> real-time folks.

I'll 'soon' take a stab at converting SLQB for -rt. Currently -rt is
SLAB only.

Then again, anything that does allocation is per definition not bounded
and not something we can have on latency critical paths -- so on that
respect its not interesting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
