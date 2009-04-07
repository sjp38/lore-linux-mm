Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 96C085F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 12:03:20 -0400 (EDT)
Date: Tue, 7 Apr 2009 08:50:52 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 11/14] readahead: clean up and simplify the code for
 filemap page fault readahead
In-Reply-To: <20090407115234.998014232@intel.com>
Message-ID: <alpine.LFD.2.00.0904070849570.27889@localhost.localdomain>
References: <20090407115039.780820496@intel.com> <20090407115234.998014232@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Pavel Levshin <lpk@581.spb.su>, wli@movementarian.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>



On Tue, 7 Apr 2009, Wu Fengguang wrote:
>
> From: Linus Torvalds <torvalds@linux-foundation.org>
> 
> This shouldn't really change behavior all that much, but the single
> rather complex function with read-ahead inside a loop etc is broken up
> into more manageable pieces.

Heh. That's an old patch.

Anyway, ACK on the whole series (or at least the pieces of it that were 
cc'd to me). Looks like sane cleanups, and I don't mean just my own old 
patch ;)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
