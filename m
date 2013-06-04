Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 4C9636B0033
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 19:37:17 -0400 (EDT)
Date: Wed, 5 Jun 2013 08:37:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [v5][PATCH 6/6] mm: vmscan: drain batch list during long
 operations
Message-ID: <20130604233716.GD31006@blaptop>
References: <20130603200202.7F5FDE07@viggo.jf.intel.com>
 <20130603200210.259954C3@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603200210.259954C3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On Mon, Jun 03, 2013 at 01:02:10PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This was a suggestion from Mel:
> 
> 	http://lkml.kernel.org/r/20120914085634.GM11157@csn.ul.ie
> 
> Any pages we collect on 'batch_for_mapping_removal' will have
> their lock_page() held during the duration of their stay on the
> list.  If some other user is trying to get at them during this
> time, they might end up having to wait.
> 
> This ensures that we drain the batch if we are about to perform a
> pageout() or congestion_wait(), either of which will take some
> time.  We expect this to help mitigate the worst of the latency
> increase that the batching could cause.
> 
> I added some statistics to the __remove_mapping_batch() code to
> track how large the lists are that we pass in to it.  With this
> patch, the average list length drops about 10% (from about 4.1 to
> 3.8).  The workload here was a make -j4 kernel compile on a VM
> with 200MB of RAM.
> 
> I've still got the statistics patch around if anyone is
> interested.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
