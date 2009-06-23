Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B82806B005D
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 03:18:18 -0400 (EDT)
Date: Tue, 23 Jun 2009 09:18:48 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: handle_mm_fault() calling convention cleanup..
Message-ID: <20090623071848.GC21180@wotan.suse.de>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 21, 2009 at 01:42:35PM -0700, Linus Torvalds wrote:
> 
> Just a heads up that I committed the patches that I sent out two months 
> ago to make the fault handling routines use the finer-grained fault flags 
> (FAULT_FLAG_xyzzy) rather than passing in a boolean for "write".

While you've got everyone's attention, may I just remind arch
maintainers to consider using pagefault_out_of_memory() rather
than unconditional kill current in the pagefault OOM case. See
x86.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
