Date: Fri, 18 May 2007 11:24:20 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 5/8] mm: remove legacy cruft
Message-ID: <20070518102420.GB7658@infradead.org>
References: <200705180737.l4I7b81u010766@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705180737.l4I7b81u010766@shell0.pdx.osdl.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 12:37:08AM -0700, akpm@linux-foundation.org wrote:
> Remove legacy filemap_nopage and all of the .populate API cruft.

Ah, okay.  I take my last mail back :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
