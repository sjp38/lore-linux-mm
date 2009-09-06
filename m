Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 99E546B0085
	for <linux-mm@kvack.org>; Sun,  6 Sep 2009 14:42:15 -0400 (EDT)
Date: Sun, 6 Sep 2009 20:42:14 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [RFC PATCH] v2 mm: balance_dirty_pages.  reduce calls to
	global_page_state to reduce cache references
Message-ID: <20090906184214.GL18599@kernel.dk>
References: <1252062330.2271.61.camel@castor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1252062330.2271.61.camel@castor>
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, "chris.mason" <chris.mason@oracle.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 04 2009, Richard Kennedy wrote:
> Reducing the number of times balance_dirty_pages calls global_page_state
> reduces the cache references and so improves write performance on a
> variety of workloads.
> 
> 'perf stats' of simple fio write tests shows the reduction in cache
> access.
> Where the test is fio 'write,mmap,600Mb,pre_read' on AMD AthlonX2 with
> 3Gb memory (dirty_threshold approx 600 Mb)
> running each test 10 times, dropping the fasted & slowest values then
> taking 
> the average & standard deviation
> 
> 		average (s.d.) in millions (10^6)
> 2.6.31-rc8	648.6 (14.6)
> +patch		620.1 (16.5)

This patch looks good to me, I have workloads too here where up to 10%
of the time is spent in balance_dirty_pages() because of this. I'll give
this patch a go on the box and test in question tomorrow, but it looks
promising.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
