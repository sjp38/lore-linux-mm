Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B22766B01B7
	for <linux-mm@kvack.org>; Wed, 26 May 2010 13:47:57 -0400 (EDT)
Date: Wed, 26 May 2010 19:47:54 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: writeback hang in current mainline
Message-ID: <20100526174753.GU23411@kernel.dk>
References: <20100526120855.GA30912@lst.de> <20100526122126.GL23411@kernel.dk> <20100526124549.GA32550@lst.de> <20100526125614.GM23411@kernel.dk> <20100526134208.GA2557@lst.de> <20100526134457.GQ23411@kernel.dk> <20100526134557.GR23411@kernel.dk> <20100526135617.GA3216@lst.de> <20100526171815.GT23411@kernel.dk> <20100526174310.GA12286@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526174310.GA12286@lst.de>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26 2010, Christoph Hellwig wrote:
> On Wed, May 26, 2010 at 07:18:15PM +0200, Jens Axboe wrote:
> > OK. From your previous mail:
> > 
> >         For now I would recommend to revert
> >         21c12849fef73efc9a898b6702fe421fd774f515 and
> >         29c795f02e68ecd7bb1374844d3e55e882ac158f,
> >         which makes xfstests run fine for me.
> > 
> > Just to ensure we are on the same page, what commits are these? They are
> > not valid shas in Linus' tree. Did you mean
> 
> Sorry, those were my local revert commits.
> 
> > 
> >         e913fc825dc685a444cb4c1d0f9d32f372f59861
> >         7c8a3554c683f512dbcee26faedb42e4c05f12fa
> 
> Exactly!

Makes sense then. So the change from those commits (with the fixes from
today) ensures that we properly do WB_SYNC_NONE writeback when
sb->s_umount is held instead of just skipping those inodes. The question
is, is that exposing some other bug or is the code still buggy...

You said that you could not get a backtrace when the test hung, were you
able to get anything out of it?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
