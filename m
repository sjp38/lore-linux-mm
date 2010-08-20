Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C005C6B02E4
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 05:19:12 -0400 (EDT)
Date: Fri, 20 Aug 2010 05:19:04 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100820091904.GB20138@infradead.org>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
 <20100819143710.GA4752@infradead.org>
 <20100819235553.GB22747@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100819235553.GB22747@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 07:55:53AM +0800, Wu Fengguang wrote:
> Since migration and pageout still set nonblocking for ->writepage, we
> may keep them in the near future, until VM does not start IO on itself.

Why does pageout() and memory migration need to be even more
non-blocking than the already non-blockig WB_SYNC_NONE writeout?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
