Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BF7B16B004F
	for <linux-mm@kvack.org>; Sat,  4 Jul 2009 16:45:36 -0400 (EDT)
Subject: Re: handle_mm_fault() calling convention cleanup..
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.2.01.0907040937040.3210@localhost.localdomain>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
	 <1246664107.7551.11.camel@pasglop>
	 <alpine.LFD.2.01.0907040937040.3210@localhost.localdomain>
Content-Type: text/plain
Date: Sun, 05 Jul 2009 07:08:38 +1000
Message-Id: <1246741718.7551.22.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sat, 2009-07-04 at 09:44 -0700, Linus Torvalds wrote:

> Just a tiny word of warning: right now, the conversion I did pretty much 
> depended on the fact that even if I missed a spot, it wouldn't actually 
> make any difference. If somebody used "flags" as a binary value (ie like 
> the old "write_access" kind of semantics), things would still all work, 
> because it was still a "zero-vs-nonzero" issue wrt writes.

 .../...

Right. Oh well.. we'll see when I get to it. I have a few higher
priority things on my pile at the moment.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
