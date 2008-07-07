Date: Mon, 7 Jul 2008 16:54:09 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 12/13] GRU Driver V3 -  export is_uv_system(),
	zap_page_range() & follow_page()
Message-ID: <20080707145408.GE7834@duo.random>
References: <20080703213348.489120321@attica.americas.sgi.com> <20080703213633.890647632@attica.americas.sgi.com> <20080704073926.GA1449@infradead.org> <20080707143916.GA5209@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080707143916.GA5209@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, cl@linux-foundation.org, hugh@veritas.com, akpm@osdl.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, holt@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 07, 2008 at 09:39:16AM -0500, Jack Steiner wrote:
> Can you provide some additional details on the type of kernel API
> that could be exported to provide a pte lookup in atomic context?

mmu notifiers makes page pinning an obsolete thing so we want to get
rid of get_user_pages in KVM page fault fast path too (we want to keep
it in the slow path the same way as GRU does).

I tried to profile it and time spent in get_user_pages is quite
smaller than the time spent on follow_page. So I estimated we'll be
very lucky if getting rid of get_user_pages will even mark a 1%
speedup in real life benchmark, but still we want to optimize things
given this is so easy.

If calling follow_page directly is the right thing I don't know. Let's
say I'll postpone any minor-optimization work in this area to the time
mmu notifiers are merged in .27 as scheduled.

If the export of follow_page was going in before a more accurate
thought on what else we could do, I wouldn't be opposed because
eventually we'll have to export a new function anyway and this is a
one liner change, so it couldn't make life harder later if it goes in.

> I'll gladly make whatever changes are needed but need some pointers on
> the direction I should take....

Same here, and I'll join this more actively to help out as soon as we
can move to the next step (i.e. once mmu notifiers are in mainline).

Thanks everyone!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
