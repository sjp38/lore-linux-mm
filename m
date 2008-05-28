Date: Wed, 28 May 2008 20:40:06 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Re: bad pmd ffff810000207238(9090909090909090).
Message-ID: <20080528184006.GA14585@elte.hu>
References: <483CBCDD.10401@lugmen.org.ar> <Pine.LNX.4.64.0805281922530.7959@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805281922530.7959@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Fede <fedux@lugmen.org.ar>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Jan Engelhardt <jengelh@medozas.de>, Willy Tarreau <w@1wt.eu>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh@veritas.com> wrote:

> [PATCH] x86: fix bad pmd ffff810000207xxx(9090909090909090)
> 
> OGAWA Hirofumi and Fede have reported rare pmd_ERROR messages: 
> mm/memory.c:127: bad pmd ffff810000207xxx(9090909090909090).
> 
> Initialization's cleanup_highmap was leaving alignment filler behind 
> in the pmd for MODULES_VADDR: when vmalloc's guard page would occupy a 
> new page table, it's not allocated, and then module unload's vfree 
> hits the bad 9090 pmd entry left over.

applied, nice catch!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
