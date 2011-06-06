Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0730B6B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 08:38:59 -0400 (EDT)
Date: Mon, 6 Jun 2011 14:38:51 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110606123851.GA12887@random.random>
References: <20110601214018.GC7306@suse.de>
 <20110601233036.GZ19505@random.random>
 <20110602010352.GD7306@suse.de>
 <20110602132954.GC19505@random.random>
 <20110602145019.GG7306@suse.de>
 <20110602153754.GF19505@random.random>
 <20110603020920.GA26753@suse.de>
 <20110603144941.GI7306@suse.de>
 <20110603154554.GK2802@random.random>
 <20110606103924.GD5247@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110606103924.GD5247@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Mon, Jun 06, 2011 at 11:39:24AM +0100, Mel Gorman wrote:
> Well spotted.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> 
> Minor nit. swapper_space is rarely referred to outside of the swap
> code. Might it be more readable to use
> 
> 	/*
> 	 * swapcache is accounted as NR_FILE_PAGES but it is not
> 	 * accounted as NR_SHMEM
> 	 *
> 	if (PageSwapBacked(page) && !PageSwapCache(page))

I thought the comparison on swapper_space would be faster as it was
immediate vs register in CPU, instead of forcing a memory
access. Otherwise I would have used the above. Now the test_bit is
written in C and lockless so it's not likely to be very different
considering the cacheline is hot in the CPU but it's still referencing
memory instead register vs immediate comparison.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
