Date: Sun, 28 Jan 2007 22:40:02 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] mm: mremap correct rmap accounting
Message-Id: <20070128224002.3e7da788.akpm@osdl.org>
In-Reply-To: <45BD6A7B.7070501@yahoo.com.au>
References: <45B61967.5000302@yahoo.com.au>
	<Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
	<45BD6A7B.7070501@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007 14:31:07 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> When mremap()ing virtual addresses, some architectures (read: MIPS) switches
> underlying pages if encountering ZERO_PAGE(old_vaddr) != ZERO_PAGE(new_vaddr).
> 
> The problem is that the refcount and mapcount remain on the old page, while
> the actual pte is switched to the new one. This would counter underruns and
> confuse the rmap code.

umm, that sounds fairly fatal.  For how long has this bug been present?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
