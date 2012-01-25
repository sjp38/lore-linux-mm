Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id EB73B6B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 05:31:52 -0500 (EST)
Date: Wed, 25 Jan 2012 11:31:43 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v4 -mm] make swapin readahead skip over holes
Message-ID: <20120125103143.GB7694@cmpxchg.org>
References: <20120124131351.05309a2a@annuminas.surriel.com>
 <20120124141400.6d33b7c4@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120124141400.6d33b7c4@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Adrian Drzewieki <z@drze.net>

On Tue, Jan 24, 2012 at 02:14:00PM -0500, Rik van Riel wrote:
> Ever since abandoning the virtual scan of processes, for scalability
> reasons, swap space has been a little more fragmented than before.
> This can lead to the situation where a large memory user is killed,
> swap space ends up full of "holes" and swapin readahead is totally
> ineffective.
> 
> On my home system, after killing a leaky firefox it took over an
> hour to page just under 2GB of memory back in, slowing the virtual
> machines down to a crawl.
> 
> This patch makes swapin readahead simply skip over holes, instead
> of stopping at them.  This allows the system to swap things back in
> at rates of several MB/second, instead of a few hundred kB/second.
> 
> The checks done in valid_swaphandles are already done in 
> read_swap_cache_async as well, allowing us to remove a fair amount
> of code.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
