Date: Fri, 2 Apr 2004 20:54:10 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040402205410.A7194@infradead.org>
References: <20040402001535.GG18585@dualathlon.random> <Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain> <20040402011627.GK18585@dualathlon.random> <20040401173649.22f734cd.akpm@osdl.org> <20040402020022.GN18585@dualathlon.random> <20040402104334.A871@infradead.org> <20040402164634.GF21341@dualathlon.random> <20040402195927.A6659@infradead.org> <20040402192941.GP21341@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040402192941.GP21341@dualathlon.random>; from andrea@suse.de on Fri, Apr 02, 2004 at 09:29:41PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2004 at 09:29:41PM +0200, Andrea Arcangeli wrote:
> page->private indicates:
> 
> >>> (0xc0772380L-0xc07721ffL)/32
> 12L
> 
> that's the 12th page in the array.
> 
> can you check in the asm (you should look at address c0048c7c) if it's
> the first bug that triggers?
> 
> 	if (page[1].index != order)
> 		bad_page(__FUNCTION__, page);

No, it's the second one (and yes, I get lots of theses backtraces, unless
I counted wrongly 19 this time)

> the whole compound thing is very screwed in the above scenario.
> 
> Do you have CONFIG_DEBUG_PAGEALLOC enabled?

no. it's not available on ppc32.

> could be compound never worked right on ppc, dunno. You could try to
> backout the patch gfp-no-compound and to recompile with hugetlbfs
> enabled (can you enable it on PPC?).

no, there's no hugetlb support on ppc32.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
