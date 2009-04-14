Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 258995F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 03:09:02 -0400 (EDT)
Date: Tue, 14 Apr 2009 09:09:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 2/2] Move FAULT_FLAG_xyz into handle_mm_fault() callers
Message-ID: <20090414070904.GB23528@wotan.suse.de>
References: <604427e00904081302m7b29c538u7781cd8f4dd576f2@mail.gmail.com> <20090409230205.310c68a7.akpm@linux-foundation.org> <20090410073042.GB21149@localhost> <alpine.LFD.2.00.0904100835150.4583@localhost.localdomain> <alpine.LFD.2.00.0904100904250.4583@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0904100904250.4583@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?iso-8859-1?B?VPZy9ms=?= Edwin <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 10, 2009 at 09:09:53AM -0700, Linus Torvalds wrote:
> 
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Fri, 10 Apr 2009 09:01:23 -0700
> 
> This allows the callers to now pass down the full set of FAULT_FLAG_xyz
> flags to handle_mm_fault().  All callers have been (mechanically)
> converted to the new calling convention, there's almost certainly room
> for architectures to clean up their code and then add FAULT_FLAG_RETRY
> when that support is added.

I like these patches, no objections.

BTW. I had been even toying with allocating the struct vm_fault structure
further up, and filling in various bits as we we call down. Haven't put
much time into that, but this patch goes one step toward that.. but
arguably this patch is most useful because it allows more "flags" to be
passed down.  Probably not much more flexibility can be gained from
passing down the rest of the vm_fault structure (but I might still try
it again in the hope of a readability improvement).

> 
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> ---
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
