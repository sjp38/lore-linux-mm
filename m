Date: Sun, 28 Jan 2007 15:54:29 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
Message-ID: <20070128155429.GA26855@infradead.org>
References: <1169993494.10987.23.camel@lappy> <20070128144933.GD16552@infradead.org> <20070128151700.GA7644@elte.hu> <20070128152858.GA23410@infradead.org> <20070128154806.GA10615@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070128154806.GA10615@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 28, 2007 at 04:48:06PM +0100, Ingo Molnar wrote:
> i'm sorry, but do you realize that files_lock is a global lock, 
> triggered by /every single/ file close?

Please check which thread you're in before you start such lengthy rants.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
