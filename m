Date: Tue, 6 Mar 2007 05:07:34 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/2] mm: rework isolate_lru_page
Message-ID: <20070306040734.GD1912@wotan.suse.de>
References: <20070305161655.GC8128@wotan.suse.de> <20070305165406.6fbf7489.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070305165406.6fbf7489.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 05, 2007 at 04:54:06PM -0800, Andrew Morton wrote:
> 
> I'm doing a patch massacre on the -mm tree in an attempt to stabilise
> things.  Given that the move-mlocked-and-anon-pages-off-the-lru work
> appears to be upgraded, and given that another mm developer is actually
> looking at them, I dropped 'em.
> 
> The remains are at http://userweb.kernel.org/~akpm/dropped-patches/

OK. make-try_to_unmap-return-a-special-exit-code.patch I think can
also be put in that same series, can't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
