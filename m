Date: Tue, 2 Nov 2004 15:04:26 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
Message-Id: <20041102150426.4102e225.akpm@osdl.org>
In-Reply-To: <41880E0A.3000805@us.ibm.com>
References: <4187FA6D.3070604@us.ibm.com>
	<20041102220720.GV3571@dualathlon.random>
	<41880E0A.3000805@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: andrea@novell.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

Dave Hansen <haveblue@us.ibm.com> wrote:
>
> Andrea Arcangeli wrote:
> > Still I recommend investigating _why_ debug_pagealloc is violating the
> > API. It might not be necessary to wait for the pageattr universal
> > feature to make DEBUG_PAGEALLOC work safe.
> 
> This makes the DEBUG_PAGEALLOC stuff symmetric enough to boot for me, 
> and it's pretty damn simple.  Any ideas for doing this without bloating 
> 'struct page', even in the debugging case?

You could use a bit from page->flags.  But CONFIG_DEBUG_PAGEALLOC uses so
much additional memory nobody would notice anyway.

hm.  Or maybe page->mapcount is available on these pages.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
