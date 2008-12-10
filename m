Date: Wed, 10 Dec 2008 06:09:38 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
Message-ID: <20081210050938.GF8434@wotan.suse.de>
References: <20081129195357.813D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081208205842.53F8.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081208220016.53FB.KOSAKI.MOTOHIRO@jp.fujitsu.com> <493D82A6.9070104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <493D82A6.9070104@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 08, 2008 at 03:25:10PM -0500, Rik van Riel wrote:
> KOSAKI Motohiro wrote:
> 
> >+	for (o = order; o < MAX_ORDER; o++) {
> >+		if (z->free_area[o].nr_free)
> >+			return 1;
> 
> Since page breakup and coalescing always manipulates .nr_free,
> I wonder if it would make sense to pack the nr_free variables
> in their own cache line(s), so we have fewer cache misses when
> going through zone_watermark_ok() ?

For order-0 allocations, they should not be touched at all. For
higher order allocations in performance critical paths, we should
try to fix those to use order-0 ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
