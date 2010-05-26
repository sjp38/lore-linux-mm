Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1F36B01E2
	for <linux-mm@kvack.org>; Wed, 26 May 2010 09:56:20 -0400 (EDT)
Date: Wed, 26 May 2010 15:56:17 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: writeback hang in current mainline
Message-ID: <20100526135617.GA3216@lst.de>
References: <20100526112125.GJ23411@kernel.dk> <20100526114018.GA30107@lst.de> <20100526114950.GK23411@kernel.dk> <20100526120855.GA30912@lst.de> <20100526122126.GL23411@kernel.dk> <20100526124549.GA32550@lst.de> <20100526125614.GM23411@kernel.dk> <20100526134208.GA2557@lst.de> <20100526134457.GQ23411@kernel.dk> <20100526134557.GR23411@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526134557.GR23411@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 03:45:57PM +0200, Jens Axboe wrote:
> BTW, if you have one more chance to test... Use the latest one, but also
> apply this one:
> 
> http://lkml.org/lkml/2010/5/26/215
> 
> which fixes a silly thinko that's closely related to this logic.

I already had this applied during my test run for your second patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
