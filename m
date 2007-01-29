Date: Mon, 29 Jan 2007 19:19:24 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
In-Reply-To: <20070129190806.GA14353@elte.hu>
Message-ID: <Pine.LNX.4.64.0701291916420.10401@blonde.wat.veritas.com>
References: <1169993494.10987.23.camel@lappy> <20070128142925.df2f4dce.akpm@osdl.org>
 <20070129190806.GA14353@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Ingo Molnar wrote:
> 
> For every 64-bit Fedora box there's more than seven 32-bit boxes. I 
> think 32-bit is going to live with us far longer than many thought, so 
> we might as well make it work better. Both HIGHMEM and HIGHPTE is the 
> default on many distro kernels, which pushes the kmap infrastructure 
> quite a bit.

But HIGHPTE uses kmap_atomic (in mainline: does -rt use kmap there?)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
