Date: Thu, 20 Mar 2003 15:20:45 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] anobjrmap 3/6 unchained
Message-ID: <20030320232045.GC1240@holomorphy.com>
References: <Pine.LNX.4.44.0303202310440.2743-100000@localhost.localdomain> <Pine.LNX.4.44.0303202314190.2743-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0303202314190.2743-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 20, 2003 at 11:15:06PM +0000, Hugh Dickins wrote:
> Removed nr_reverse_maps, ReverseMaps: easily reverted if that
> poses a vmstat or meminfo compatibility problem, or someone is
> still interested in that number; but objrmap wasn't maintaining
> it, and if they don't occupy space, is it worth showing?
> Besides, look at page_dup_rmap for copy_page_range: I don't
> want to clutter that with inc_page_state(nr_reverse_maps).

It was mostly to determine space savings and internal fragmentation
on the pte_chain objects. It also helps get some notion of internal
fragmentation on pagetables. It's of low importance; delete at will.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
