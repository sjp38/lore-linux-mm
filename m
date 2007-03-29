Date: Thu, 29 Mar 2007 10:49:15 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc][patch 2/2] mips: reinstate move_pte
In-Reply-To: <20070329075847.GB6852@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703291048430.6730@woody.linux-foundation.org>
References: <20070329075805.GA6852@wotan.suse.de> <20070329075847.GB6852@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com
List-ID: <linux-mm.kvack.org>


On Thu, 29 Mar 2007, Nick Piggin wrote:
> 
> Restore move_pte for MIPS, so that any given virtual address vaddr that maps
> a ZERO_PAGE will map ZERO_PAGE(vaddr).

Why does this matter? Why do we even care about the page counts? I thought 
we long since agreed that reserved pages don't need to have page counts.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
