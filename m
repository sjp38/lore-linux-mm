Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EF89C6002CC
	for <linux-mm@kvack.org>; Wed, 26 May 2010 08:45:53 -0400 (EDT)
Date: Wed, 26 May 2010 14:45:49 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: writeback hang in current mainline
Message-ID: <20100526124549.GA32550@lst.de>
References: <20100526111326.GA28541@lst.de> <20100526112125.GJ23411@kernel.dk> <20100526114018.GA30107@lst.de> <20100526114950.GK23411@kernel.dk> <20100526120855.GA30912@lst.de> <20100526122126.GL23411@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526122126.GL23411@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 02:21:26PM +0200, Jens Axboe wrote:
> Ugh ok I see it, I had the caller_frees reverted. Try this :-)

This seems to fix it.  Running some more tests now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
