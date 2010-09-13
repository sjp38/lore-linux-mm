Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EA8D76B00F9
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 05:40:33 -0400 (EDT)
Date: Mon, 13 Sep 2010 17:40:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 15/17] mm: lower soft dirty limits on memory pressure
Message-ID: <20100913094027.GA30919@localhost>
References: <20100912154945.758129106@intel.com>
 <20100912155204.944256600@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100912155204.944256600@intel.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

>  		if (PageDirty(page)) {
> +
> +			if (file && scanning_global_lru(sc)) {

Oops "file" does not exist in linux-next. Could use
"page_is_file_cache(page)" instead to avoid the compile error.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
