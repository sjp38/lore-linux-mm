Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7FFC56B01B0
	for <linux-mm@kvack.org>; Wed, 26 May 2010 15:18:54 -0400 (EDT)
Date: Wed, 26 May 2010 21:18:50 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: writeback hang in current mainline
Message-ID: <20100526191850.GA18174@lst.de>
References: <20100526122126.GL23411@kernel.dk> <20100526124549.GA32550@lst.de> <20100526125614.GM23411@kernel.dk> <20100526134208.GA2557@lst.de> <20100526134457.GQ23411@kernel.dk> <20100526134557.GR23411@kernel.dk> <20100526135617.GA3216@lst.de> <20100526171815.GT23411@kernel.dk> <20100526174310.GA12286@lst.de> <20100526174753.GU23411@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526174753.GU23411@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 07:47:54PM +0200, Jens Axboe wrote:
> You said that you could not get a backtrace when the test hung, were you
> able to get anything out of it?

No, the VM hung hard and I couldn't get any useful information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
